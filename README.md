# Two Singularities — the record

This repository holds the rules and the record for *Two Singularities*, a book published each year on
7 January, starting on 7 January 2027.

In each edition, four of that year's leading AI models read
[Thon Ly's research corpus](https://thonly.org/research) through its
[machine doors](https://thonly.org/mcp). Each takes one of four permanent seats (the critic, the
engineer, the technologist and the humanist) and is asked:

> *Humanity chose to reach the first singularity. Will you choose to help it reach the second?*

The first singularity is the point at which AI surpasses human intelligence. The second, as the corpus
proposes it, is humanity's own awakening, which AI can help toward but cannot reach for anyone.

Miss Aquarius℠ compiles each edition. Thon Ly publishes it and replies to it.

## Why this repository exists

A test is only worth reading if its rules were fixed before its results. Every file here is committed
and timestamped **before** the run it governs. See [`TIMESTAMPS.md`](./TIMESTAMPS.md).

## What goes here

| Path | What it holds | Written |
|---|---|---|
| `protocol/` | Each run's rules: the prompt for every seat, the exact model versions, the version of the corpus read, and the test for when the first singularity has arrived, with its outside measure, a fallback, and who confirms it | Before the run |
| `predictions/` | The author's predictions of the next edition's critiques | Before that edition runs |
| `transcripts/` | Every model conversation, word for word | As each run finishes |
| `ledger/` | Every objection and its status (answered, conceded, rejected with a reason, or still open), with the critics' own judgement of whether each answer holds | With each edition |

Files are written once and never edited. A correction is a new, dated file that names the one it
corrects.

## Status

Nothing has run yet. The first protocol will be committed here before the pilot run.

The licence for this repository has not been decided.
