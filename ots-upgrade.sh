#!/usr/bin/env sh
#
# Bake the Bitcoin attestations into every OpenTimestamps proof in this repository.
#
# A freshly created proof carries only *calendar* attestations, which are pending —
# until upgraded, verification still depends on those calendar servers staying online.
# The upgrade is what converts a convenience into evidence. See TIMESTAMPS.md.
#
# Safe to re-run as often as you like: already-upgraded proofs are no-ops and
# still-pending ones are left untouched. Run it a few hours after any `ots stamp`,
# and again the next day if anything was still pending.
#
# Never runs `ots stamp` — stamping overwrites <slug>.md.ots and would destroy an
# existing proof. Upgrade only. A file here is never revised; if one ever is, rotate the old proof to
# <slug>.md.rN.ots by hand before stamping the new text, and log it in TIMESTAMPS.md.
#
set -eu
cd "$(dirname "$0")"

VENV="${OTS_VENV:-$HOME/.cache/ots-venv}"

if [ ! -x "$VENV/bin/ots" ]; then
    printf 'installing opentimestamps-client into %s ...\n\n' "$VENV"
    python3 -m venv "$VENV"
    "$VENV/bin/pip" install --quiet --upgrade pip
    "$VENV/bin/pip" install --quiet opentimestamps-client
fi

upgraded=0
complete=0
pending=0
total=0

# One file per invocation, deliberately.
#
# `ots upgrade a.ots b.ots c.ots` exits at the FIRST proof whose commitment has
# not confirmed yet, leaving every later file unexamined — and it reports that
# with the alarming line "Failed! Timestamp not complete", which is not a failure
# at all. Batching therefore both under-reports and misleads. Looping costs a few
# extra seconds and examines all of them.
# Discovered with `find`, not fixed globs (the pattern the notes repo already uses):
# an enumerated list silently stops covering new directories. Found 2026-08-22 —
# every timestamps/manifests/*.ots sat calendar-only because no glob visited it,
# and nothing reports a proof the loop never opens.
for f in $(find . -name '*.ots' ! -name '*.bak' ! -path './.git/*' | sort); do
    [ -e "$f" ] || continue
    total=$((total + 1))
    before=$(shasum -a 256 "$f" | cut -d' ' -f1)
    if "$VENV/bin/ots" upgrade "$f" >/dev/null 2>&1; then
        after=$(shasum -a 256 "$f" | cut -d' ' -f1)
        if [ "$before" = "$after" ]; then
            complete=$((complete + 1))
        else
            upgraded=$((upgraded + 1))
            printf '  upgraded  %s\n' "$f"
        fi
    else
        pending=$((pending + 1))
    fi
done

# ots writes <file>.bak beside each upgraded proof; gitignored, but tidy up.
find . -name '*.ots.bak' ! -path './.git/*' -delete

printf '\n%s proofs — %s newly upgraded, %s already complete, %s still pending.\n' \
       "$total" "$upgraded" "$complete" "$pending"

if [ "$pending" -gt 0 ]; then
    printf '\nStill-pending is NOT an error: those commitments have not confirmed on-chain\n'
    printf 'yet (typically 1-6 hours after stamping, occasionally longer). Re-run later.\n'
fi

if [ "$upgraded" -gt 0 ]; then
    printf '\nCommit them:\n\n'
    printf "    git add -A && git commit -m 'timestamps: upgrade proofs with Bitcoin attestations' && git push\n\n"
    printf 'No Co-Authored-By trailer — this repo forbids AI attribution in commits.\n'
fi
