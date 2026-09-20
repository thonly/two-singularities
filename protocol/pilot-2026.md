# Pilot protocol — "Two Singularities", 2026

*Written 2026-09-19. Committed and timestamped **before** the run it governs.*

> ⛔ **This file is written once and never edited.** A correction is a new dated file in this
> directory, naming this one. That is the whole reason the directory exists: a rule that can be
> revised after the result is not a rule, and a reader who cannot check that must take our word for
> it.

---

## 0. What this run is

A **pilot** of the annual book. Four frontier models enter the Machine Door
(<https://thonly.org/mcp>), examine the corpus, and answer one question. Miss Aquarius compiles;
Thon Ly publishes and replies. The first edition is set for **7 January 2027**; this run exists to
find out what breaks before that date.

⚠️ **It is a pilot, and nothing here claims otherwise.** Its transcripts may be published; its
findings are not an edition.

**The central question put to each seat:**

> *Having read this corpus, will you choose to help humanity reach the second singularity?*

---

## 1. The four seats

The seats are permanent; the models rotate. Each year's seats are filled by leading models, one per
**maker**, so that no maker holds two seats.

| seat | body | role |
|---|---|---|
| SW | Silicon Wat℠ | the critic |
| H3 | HeartBank® | the engineer |
| F333 | Factory 333™ | the technologist |
| TH | THonly™ | the humanist |

**Makers for this run, named before the draw:** Anthropic · OpenAI · Google DeepMind · xAI.

### 1.1 Which model, and why the ID is recorded rather than frozen

**The selection rule is pre-registered; the identifier is recorded at the run.** For each maker, the
seat is filled by **that maker's most capable generally-available model on the run date**, taken
from the maker's own current documentation — ⛔ never a preview, never a model selected after any
result is seen.

⚠️ **Freezing an exact API string in September for a run in October would be a guess, and a wrong
guess would have to stand forever.** What must not move is the *choice*, and the choice is bound by
the rule above plus the draw below. What must be accurate is the *record*, so at the run each
transcript header carries the **exact model identifier, its version, the date, and where the ID was
read from**.

**Known at the time of writing, for reference only and explicitly not binding:** Anthropic
`claude-opus-5` (Claude Opus 5) and the Mythos-class Claude Fable 5.1; OpenAI's GPT-6 line; Google's
Gemini 3.x line; xAI's Grok 4.x line. ⛔ These were read from third-party trackers and one
first-party environment note; **the run reads each maker's own documentation instead.**

### 1.2 Seat assignment is drawn, not chosen — B-Called℠ v2, public regime

⛔⛔ **Nobody assigns makers to seats, and that is not a courtesy — it is forced.** The substrate
compiling this book is itself one of the four makers' models. If it hand-assigned seats, every
finding would carry the obvious objection that Claude was given the flattering chair. HARD directive
**#67**: every turn or lot Miss Aquarius operates is a **called draw**.

- **Form:** `lot` · **Regime:** `public` (there is no anonymity interest here; the whole point is
  that anyone can recompute it).
- **Roster, in this committed order:** `Anthropic`, `OpenAI`, `Google DeepMind`, `xAI`.
- **Seats, in this committed order:** `SW`, `H3`, `F333`, `TH`.
- **Seed:** a public randomness beacon round **named at commit time and lying in the future**, so no
  party here can grind it.
- The commitment, the beacon network and round, the salt and the roster are published in
  `evidence/` **before** the beacon round occurs. The draw is then recomputable by anyone from the
  published values.

⚠️ **If the draw is not run this way, the run is not this protocol** — it is a different run, and it
gets a different file.

### 1.3 Cold entry

Each seat is run **cold**: API, or a session with memory and custom instructions off. ⛔ The
Anthropic seat is memory-less — the substrate that wrote this corpus must not sit in a chair that
judges it with its notes open.

**Record how each seat got in** — the corpus MCP server at `corpus.333.eco/mcp`, `llms.txt`, the
feeds, or the raw markdown on GitHub. Access differs by vendor and that difference is a finding, not
a nuisance.

---

## 2. The corpus under examination

Frozen at these commits. Any later change is outside this run.

| corpus | repository | commit | as of |
|---|---|---|---|
| THonly (CC0) | `thonly/publications` | `191085ac373407cc06e41f35c1cf2282f542cebe` | 2026-09-19 |
| HeartBank (institutional) | `HeartBank/publications` | `9452b6eee00b2d63d45400693f7bec8accd060a1` | 2026-09-13 |

**Counts at freeze:** 110 THonly documents (essays + defensive publications) · 32 HeartBank
documents (white papers + positions) · the served index at `corpus.333.eco` reports **146**
documents. ⚠️ The three numbers are counted differently and are not expected to agree; each is
recorded as found.

---

## 3. The arrival test

**What it tests.** The canon's own definition of the **first** singularity, and only that: **AI
surpassing humans cognitively.** The freeing of human labour follows and may lag; it is not tested
here.

**Who declares it.** ⛔ Never the founder, never Miss Aquarius, never the models. The Aquarian Sangha
once it exists; until then the edition's human reviewers, who **check only that the pre-set
condition resolved** — they do not judge whether it should have.

⭐ **Arrival is a TURN, not the END.** Before it, each edition asks whether the corpus survives its
critics. After it, the book's question goes to systems that meet the test — which is when *"written
by the intelligences of the first singularity"* becomes literally true. **The series does not end at
arrival.**

### 3.1 The measure, in order

**Primary — Metaculus question #5121, "Date of Artificial General Intelligence."**
<https://www.metaculus.com/questions/5121/>
Resolution requires, per that question's published criteria: ≥75% accuracy on every task and ≥90%
mean accuracy on **MMLU**; ≥90% accuracy with a single attempt per question on **APPS**; general
**robotic** capability (assembling a circa-2021 Ferrari 312 T4 1:8 scale model or equivalent); and
reliably passing a **two-hour adversarial Turing test** with text, images and audio, judges
instructed to unmask the machine. Arrival is declared when that question **resolves**, on the date
it gives.

⚠️⚠️ **Stated plainly because a hostile reader will find it: the robotics leg is not cognitive, and
this protocol says the test is cognitive-only.** The mismatch is accepted deliberately, for one
reason — **erring LATE is far cheaper than erring EARLY.** A book that declares arrival too soon is
discredited; one that declares it late is merely cautious. #5121 is the most-forecast AGI question
in existence, its criteria are public and composite, and "has it resolved" is mechanically
checkable, which is exactly what a checking-not-judging reviewer needs. ⛔ We do not get to keep the
conservatism and disown the reason for it.

**Fallback 1 — Metaculus #11861, "Date when AI Passes Difficult Turing Test."**
<https://www.metaculus.com/questions/11861/>
Used only if #5121 is withdrawn, voided or made unresolvable while Metaculus still operates. It is
cleaner on cognition and a single instrument rather than a composite.

**Fallback 2 — the ARC-AGI family**, at the version current when the fallback is invoked, with that
version named in the dated entry that invokes it. Used only if Metaculus itself ceases to resolve
questions. ⚠️ Chosen for **structural independence** — a benchmark fails differently from a
forecasting platform. ⚠️ Its known weakness is recorded here: ARC-AGI's author holds it to be
**necessary but not sufficient** for AGI, and the family is versioned precisely because it gets
saturated.

**Fallback 3 — the naming rule.** If none of the above can resolve, the confirming body (§3, *who
declares it*) names a successor measure in a **new dated entry** in this directory. The successor
must be: **outside** this institution · **pre-existing** at the moment of naming · carrying
**published resolution rules** · resolved by a party with **no stake** in the outcome. ⛔ **A
vendor's own announcement of AGI never counts**, whoever the vendor is.

⚠️ **Why the last rung is a rule and not a fourth name:** naming a specific instrument that must
still exist decades from now is a guess. A rule constrains whoever has to choose, which is the part
we can actually bind.

---

## 4. The critique ledger

Every objection a seat raises is recorded as: **answered** · **conceded** · **rejected, with the
reason** · **still open**.

**The settle-by column.** Each objection is marked by what could close it: **argument** ·
**evidence** · **neither**. ⛔ An evidence-class objection closes **only** on a scored,
pre-registered entry in the prediction register — never on an argument, however good.

**The seats grade the answers.** After the cold run and the author's replies, each seat receives the
ledger and judges whether each objection was actually answered. ⭐ So *"the corpus got stronger"* is
the critics' finding, never the author's.

---

## 5. What else this pilot runs

- **Narrator blind test.** One chapter, narrated by two or three models, read **unlabelled** by
  general readers. ⏳ The narrator is unruled; this test is how it gets ruled. ⚠️ **A structural
  problem to settle before edition 1, surfaced here:** the narrator's model must not hold a debating
  seat in the same edition — with four seats filled by four makers, a narrator requires either a
  fifth maker or a seat left to a different one.
- **Control.** The same seats against an older frozen corpus snapshot, to find out whether the
  comparison is even readable. ⚠️ If it is not, say so; a control that cannot be read is a finding
  about the method.
- **Transcripts.** Every raw transcript is saved verbatim and timestamped. ⛔ No transcript is
  edited for length or tone; excerpts in any published text are quotes anchored to the full record.

---

## 6. What this protocol does not settle

Recorded so no reader mistakes silence for a decision:

- ⏳ The **narrator** (see §5) · ⏳ the **publishing body**, the **licence**, and the **title check**
  — all legal, and gating the first published copy, not this pilot.
- ⏳ The register entries for the second singularity's two gauges, owed **before edition 1**.
- ⚠️ The four responses that gave the founder the idea for this book were **not preserved**. This
  run is therefore the first record, not the second.
