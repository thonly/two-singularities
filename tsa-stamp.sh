#!/usr/bin/env sh
#
# Attest the whole repository with RFC 3161 trusted timestamps.
#
# This is the SECOND timestamp leg, beside OpenTimestamps. It exists because the
# two legs fail for unrelated reasons:
#
#   OpenTimestamps -> Bitcoin.  No expiry, no authority, no legal presumption.
#                               Worthless if a court will not take a blockchain.
#   RFC 3161       -> a TSA.    Statutory presumption under eIDAS, recognised by
#                               courts today. But its trust anchor EXPIRES, and
#                               it depends on the authority still standing.
#
# Neither is a backup of the other; each covers the other's weakness. Adding a
# second blockchain would have added neither property. See timestamps/README.md.
#
# WHAT IS STAMPED: not each file, but a dated MANIFEST of the whole repository —
# every git-tracked path and its SHA-256. That choice is deliberate and fixes a
# real gap in the .ots leg: `ots stamp` never re-stamps, so a REVISED document
# keeps attesting its old text until a human rotates the proof by hand. A weekly
# manifest re-attests the current text of everything with no human step.
#
# The manifest also covers every PREVIOUS manifest and token, so the series is a
# hash chain: an old manifest cannot be altered without breaking every later one.
#
# Safe to re-run. Two runs in one UTC day overwrite that day's tokens, which is
# harmless — they attest the same manifest.

set -eu
cd "$(dirname "$0")"

DAY="$(date -u +%Y-%m-%d)"
MDIR="timestamps/manifests"
CADIR="timestamps/ca"
MANIFEST="$MDIR/$DAY.sha256"

mkdir -p "$MDIR"

# ── The authorities ───────────────────────────────────────────────────────────
# Three, on two different legal bases and three jurisdictions. Format:
#   short-name | endpoint | trust anchor
#
#   aped-gr    Hellenic Public Administration CA. eIDAS-QUALIFIED: its issuing
#              CA is listed in the Greek Trusted List (published by EETT, reached
#              from the EU LOTL) as a QTST service with status `granted`, so its
#              tokens carry the Art. 41 presumption of accuracy across the EU.
#   accv-es    Agencia de Tecnologia y Certificacion Electronica, Valencia.
#              Qualified, and its root is in the public browser/OS trust stores.
#   freetsa-de The one with NO terms-of-service scope problem. The commercial
#              free TSAs (DigiCert, Sectigo, GlobalSign...) all scope their free
#              endpoints to code signing; relying on a service outside its terms
#              is not a foundation. FreeTSA is offered for general use.
#
# A `for` list, not a piped `while` — a pipeline runs its loop in a subshell and
# the granted/failed counters would be silently discarded at the end of it.
TSAS='aped-gr|https://timestamp.aped.gov.gr/qtss
accv-es|http://tss.accv.es:8318/tsa
freetsa-de|https://freetsa.org/tsr'

sha256_of() {
    if command -v sha256sum >/dev/null 2>&1; then sha256sum "$1" | cut -d' ' -f1
    else shasum -a 256 "$1" | cut -d' ' -f1; fi
}

# ── 1. Build the manifest ─────────────────────────────────────────────────────
# Everything git tracks, except the files this run is about to write. Sorted, so
# the manifest is reproducible: same tree in, same bytes out.
printf '# repository manifest — %s (UTC)\n' "$DAY"        >  "$MANIFEST.tmp"
printf '# sha256  path\n'                                  >> "$MANIFEST.tmp"
git ls-files -z \
  | tr '\0' '\n' \
  | grep -v "^$MDIR/$DAY\." \
  | sort \
  | while IFS= read -r f; do
        [ -f "$f" ] || continue
        printf '%s  %s\n' "$(sha256_of "$f")" "$f"
    done                                                   >> "$MANIFEST.tmp"
# If today's manifest already existed and its CONTENT changed (a file was added or
# edited between two runs on the same day), every sidecar written for the previous
# content is now stale — it attests bytes that no longer exist on disk and would
# verify as FAILED. Discard them so they are regenerated against the new manifest.
# Silently keeping a stale .ots here would be the worst possible failure: a proof
# that looks present and does not verify.
if [ -f "$MANIFEST" ] && ! cmp -s "$MANIFEST" "$MANIFEST.tmp"; then
    printf 'manifest changed since an earlier run today — discarding stale sidecars\n'
    rm -f "$MANIFEST".*.tsr "$MANIFEST.ots"
fi
mv "$MANIFEST.tmp" "$MANIFEST"

files=$(grep -cv '^#' "$MANIFEST" || true)
printf 'manifest %s — %s file(s)\n\n' "$MANIFEST" "$files"

# ── 2. Ask each authority to sign it ──────────────────────────────────────────
# -cert is REQUIRED, not cosmetic: it makes the TSA embed its signing chain in
# the token, so the archived token verifies against a pinned root alone and never
# needs the authority's website to still exist.
openssl ts -query -data "$MANIFEST" -sha256 -cert -out "$MANIFEST.tsq"

granted=0
failed=0
IFS='
'
for entry in $TSAS; do
    unset IFS
    name="${entry%%|*}"; url="${entry##*|}"
    [ -n "$name" ] || continue
    out="$MANIFEST.$name.tsr"
    code=$(curl -s -o "$out" -w '%{http_code}' --max-time 45 \
             -H 'Content-Type: application/timestamp-query' \
             --data-binary "@$MANIFEST.tsq" "$url" 2>/dev/null || echo 000)

    if [ "$code" != "200" ]; then
        printf '  %-11s UNREACHABLE (http %s) — token not written\n' "$name" "$code"
        rm -f "$out"; failed=$((failed + 1)); continue
    fi

    # Verify immediately against the PINNED root. An unverifiable token is worse
    # than none: it looks like evidence and is not. Do not keep it.
    if openssl ts -verify -data "$MANIFEST" -in "$out" \
           -CAfile "$CADIR/$name.pem" >/dev/null 2>&1; then
        gt=$(openssl ts -reply -in "$out" -text 2>/dev/null \
             | sed -n 's/^Time stamp: //p')
        printf '  %-11s OK    %s\n' "$name" "$gt"
        granted=$((granted + 1))
    else
        printf '  %-11s REPLY DID NOT VERIFY against %s — discarded\n' "$name" "$CADIR/$name.pem"
        rm -f "$out"; failed=$((failed + 1))
    fi
done

rm -f "$MANIFEST.tsq"

printf '\n%s authority token(s) written, %s unavailable.\n' "$granted" "$failed"

# One authority down is why there are three. All three down means the manifest
# has no PKI attestation at all this run, and that must not pass silently.
if [ "$granted" -eq 0 ]; then
    printf '\nNo authority could be reached. The manifest is written but UNATTESTED\n'
    printf 'on the RFC 3161 leg. Re-run before committing.\n' >&2
    exit 1
fi

# ── 3. Bitcoin too, if the ots client is here ─────────────────────────────────
# Cross-links the two trust models onto one artifact: the same manifest is
# attested by Bitcoin AND by the authorities, and each corroborates the other.
if [ ! -f "$MANIFEST.ots" ]; then
    OTS=""
    if command -v ots >/dev/null 2>&1; then OTS=ots
    elif [ -x "${OTS_VENV:-$HOME/.cache/ots-venv}/bin/ots" ]; then
        OTS="${OTS_VENV:-$HOME/.cache/ots-venv}/bin/ots"
    fi
    if [ -n "$OTS" ]; then
        "$OTS" stamp "$MANIFEST" >/dev/null 2>&1 \
            && printf '  %-11s stamped (pending — upgrade in a few hours)\n' "bitcoin" \
            || printf '  %-11s stamp failed (not fatal)\n' "bitcoin"
    else
        printf '  %-11s skipped — ots client not installed\n' "bitcoin"
    fi
fi

printf '\nVerify any time with:  ./tsa-verify.sh\n'
printf 'Commit them:\n\n'
printf "    git add -A && git commit -m 'timestamps: RFC 3161 manifest for %s' && git push\n\n" "$DAY"
printf 'No Co-Authored-By trailer — this repo forbids AI attribution in commits.\n'
