#!/usr/bin/env sh
#
# Verify the RFC 3161 leg. Three modes:
#
#   ./tsa-verify.sh                 latest manifest: check its tokens, then check
#                                   every file still matches its recorded hash
#   ./tsa-verify.sh --all           every manifest ever written (tokens only)
#   ./tsa-verify.sh path/to/file.md the earliest manifest that attests this exact
#                                   text — i.e. the date the file can be proven by
#
# Verification never contacts the authorities. It uses the token's embedded chain
# and the roots pinned in timestamps/ca/, so it works offline and keeps working if
# every one of those authorities disappears.

set -eu
cd "$(dirname "$0")"

MDIR="timestamps/manifests"
CADIR="timestamps/ca"

sha256_of() {
    if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | cut -d' ' -f1
    else shasum -a 256 "$1" | cut -d' ' -f1; fi
}

# A token signed in 2026 is still good evidence in 2040 — but the signing cert
# will have expired by then, and `openssl ts -verify` checks cert validity at the
# CURRENT time by default, so it will report FAILED for the wrong reason. The
# correct question is whether the cert was valid WHEN IT SIGNED, so verification
# is re-attempted pinned to the token's own timestamp. This is not a loosening:
# -attime is exactly the right check for archival evidence.
verify_token() {   # $1 = data file, $2 = token, $3 = root pem
    if openssl ts -verify -data "$1" -in "$2" -CAfile "$3" >/dev/null 2>&1; then
        echo "OK"; return 0
    fi
    at=$(openssl ts -reply -in "$2" -text 2>/dev/null | sed -n 's/^Time stamp: //p')
    if [ -n "$at" ]; then
        epoch=$(python3 -c "
import sys,datetime
s='$at'.rsplit(' ',1)[0]
for f in ('%b %d %H:%M:%S %Y','%b  %d %H:%M:%S %Y'):
    try: print(int(datetime.datetime.strptime(s,f).replace(tzinfo=datetime.timezone.utc).timestamp())); break
    except ValueError: pass
" 2>/dev/null || true)
        if [ -n "$epoch" ] && openssl ts -verify -data "$1" -in "$2" -CAfile "$3" \
               -attime "$epoch" >/dev/null 2>&1; then
            echo "OK (cert expired since; valid at signing time)"; return 0
        fi
    fi
    echo "FAILED"; return 1
}

check_manifest() {   # $1 = manifest path
    m="$1"; any=0
    printf '\n%s\n' "$m"
    for t in "$m".*.tsr; do
        [ -e "$t" ] || continue
        name=$(basename "$t" .tsr); name="${name##*.}"
        root="$CADIR/$name.pem"
        if [ ! -f "$root" ]; then
            printf '  %-11s no pinned root at %s — CANNOT VERIFY\n' "$name" "$root"
            continue
        fi
        r=$(verify_token "$m" "$t" "$root") || true
        gt=$(openssl ts -reply -in "$t" -text 2>/dev/null | sed -n 's/^Time stamp: //p')
        printf '  %-11s %-45s %s\n' "$name" "$r" "$gt"
        case "$r" in OK*) any=1 ;; esac
    done
    [ "$any" -eq 1 ] || printf '  (no verifiable authority token)\n'
}

# ── file mode: when can this exact text be proven to have existed? ────────────
if [ $# -eq 1 ] && [ "$1" != "--all" ]; then
    target="$1"
    [ -f "$target" ] || { echo "no such file: $target" >&2; exit 1; }
    want=$(sha256_of "$target")
    echo "$target"
    echo "  sha256 $want"
    found=""
    for m in $(ls "$MDIR"/*.sha256 2>/dev/null | sort); do
        # -F -x: a path may contain regex metacharacters; match the line literally.
        if grep -qxF "$want  $target" "$m" 2>/dev/null; then
            found="$m"; break
        fi
    done
    if [ -z "$found" ]; then
        echo "  NOT attested in any manifest at this hash."
        echo "  Either it changed since the last run, or it was never tracked."
        exit 1
    fi
    echo "  earliest manifest attesting this exact text:"
    check_manifest "$found"
    echo
    echo "  Chain of evidence: this file's SHA-256 appears in the manifest above,"
    echo "  and that manifest is signed by the authorities listed. Both links are"
    echo "  checkable offline."
    exit 0
fi

# ── --all / default ──────────────────────────────────────────────────────────
if [ "${1:-}" = "--all" ]; then
    set -- $(ls "$MDIR"/*.sha256 2>/dev/null | sort)
    [ $# -gt 0 ] || { echo "no manifests yet — run ./tsa-stamp.sh" >&2; exit 1; }
    for m in "$@"; do check_manifest "$m"; done
    exit 0
fi

latest=$(ls "$MDIR"/*.sha256 2>/dev/null | sort | tail -1 || true)
[ -n "$latest" ] || { echo "no manifests yet — run ./tsa-stamp.sh" >&2; exit 1; }
check_manifest "$latest"

# The tokens prove the manifest. This proves the manifest still describes the
# working tree — the half that catches ordinary drift rather than tampering.
printf '\nRe-hashing the tree against %s …\n' "$latest"
missing=0; changed=0; ok=0
# Default IFS, two fields: `p` absorbs the rest of the line, so paths containing
# spaces survive. A custom IFS of two literal spaces would not do that.
while read -r h p; do
    case "$h" in \#*|'') continue ;; esac
    if [ ! -f "$p" ]; then missing=$((missing + 1)); printf '  gone     %s\n' "$p"; continue; fi
    if [ "$(sha256_of "$p")" = "$h" ]; then ok=$((ok + 1))
    else changed=$((changed + 1)); printf '  changed  %s\n' "$p"; fi
done < "$latest"
printf '\n%s unchanged, %s changed, %s gone.\n' "$ok" "$changed" "$missing"
[ $((changed + missing)) -eq 0 ] \
    || printf 'Changed/gone files are normal between runs — the next manifest re-attests them.\n'
