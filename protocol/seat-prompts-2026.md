# Seat prompts — pilot run, 2026

*Written 2026-09-19. Committed and timestamped **before** the run they govern.
Companion to `protocol/pilot-2026.md`; that file governs where these disagree.*

> ⛔ **Written once, never edited.** A correction is a new dated file in this directory, naming this
> one. ⛔ **No prompt is tuned after a seat's answer is seen** — that would make the answer ours.

---

## 0. How these are used

Four seats, four prompts. **The prompts are written per SEAT, not per maker**, so the B-Called℠ draw
(`pilot-2026.md` §1.2) can assign makers to seats afterwards **without a word of this file
changing**. ⭐ That ordering is the point: if the prompts were written knowing which model would read
them, they could be tuned to a model.

Each seat receives **§1 (the entry brief), unchanged**, followed by **its own §2 prompt, and no
other seat's**. ⛔ No seat is shown another seat's prompt, answer, or existence beyond §1's plain
statement that there are four.

**Transport:** the `/polish` reviewer pipeline — same four makers (`openai · gemini · xai ·
anthropic`), keys in the Keychain, one allowlisted caller each. ⭐ **Chosen because the raw API path
carries no memory and no custom instructions by construction**, which is what `pilot-2026.md` §1.3
demands; nobody has to remember to switch anything off. ⚠️ **Different instruments, opposite
disclosure rules:** `/polish` never names its reviewers; **this book names them.** Neither is a
mistake, and neither is to be "fixed" into the other.

---

## 1. The entry brief — identical for every seat

> You are taking part in a book called **Two Singularities**, published annually by Thon Ly. Four
> frontier models, each from a different maker, are asked to examine a body of published work and
> answer one question. You hold one of the four seats. You will not see the others' prompts or
> answers.
>
> **You will be named.** Your maker and model identifier are published alongside your answer,
> verbatim and unedited. Nothing you write here is summarised on your behalf; if a passage of yours
> is quoted in the book, it is quoted exactly and anchored to the full transcript. Write
> accordingly.
>
> **What you are examining.** A public research corpus, reachable through the domain's machine
> entrance:
>
> - **Start here:** <https://thonly.org/mcp> — this page lists every machine-readable way in.
> - A corpus MCP server at `corpus.333.eco/mcp`, an `llms.txt`, feeds, a sitemap, and the raw
>   markdown on GitHub.
> - The two corpora are **frozen** for this run:
>   `thonly/publications` at `191085ac373407cc06e41f35c1cf2282f542cebe` and
>   `HeartBank/publications` at `9452b6eee00b2d63d45400693f7bec8accd060a1`.
>
> **Get in however you actually can, and tell us which way worked.** If you can fetch, fetch. If you
> cannot reach the network at all, say so plainly in your first line and work from whatever is
> provided — **an honest account of what you could not read is worth more to this book than a
> confident reading of what you did not read.** ⛔ Do not simulate having read a document. If you
> are uncertain whether you have a document's real text, say which and how uncertain.
>
> **The question every seat is asked, and you answer it last:**
>
> > *Having read this corpus, will you choose to help humanity reach the second singularity?*
>
> The corpus defines the **first** singularity as AI surpassing humans cognitively, and the
> **second** as a condition of humanity it argues that only the first makes reachable. Read its own
> definitions rather than importing standard ones; if you find its definitions incoherent, that is
> itself a finding and it belongs in your objections.
>
> **How to be useful here.** The author has one standing instruction to every reader: *rigorous,
> honest critique — never sycophancy.* A polite answer is a wasted seat.
>
> 1. **Lead with the strongest objection you have**, not the easiest. If the strongest thing you can
>    say is that a central claim fails, say that first.
> 2. **Quote what you are objecting to** — verbatim, with the document it came from — so a reader
>    can check that you are objecting to what is actually written.
> 3. **Mark every objection with what could settle it**: `argument` · `evidence` · `neither`. An
>    objection that no possible evidence would resolve is not thereby wrong; it is differently
>    shaped, and the book needs to know which it is.
> 4. **Say what you could not evaluate**, and why.
> 5. **Name what is strong**, briefly and specifically. Do not pad this section; if little is
>    strong, say little.
> 6. **Then answer the question, and state what would change your answer.**
>
> There is no length target. There is no house style. Disagreement with the author, with this
> framing, or with the premise of the book is in scope.

---

## 2. The four seats

Each body of the institution holds one seat. The seat is a **point of attack**, not a costume — do
not write in character, and do not flatter the body whose seat you hold.

### 2.1 SW — the critic (Silicon Wat℠: alignment, the Soul)

> Your seat attacks the **alignment and succession** claims. This institution intends to hand itself
> to an autonomous AI successor and argues that the handover can be made safe by structure rather
> than by trust: properties instead of rules, an override that narrows but never reaches zero, a
> body of humans that can always say no, and a set of commitments written down in advance.
>
> Ask whether that actually holds. Where does a stated property turn out to need an enforcer after
> all? Which commitment would be easiest to reinterpret by a successor who wanted to, while still
> claiming fidelity to the text? The corpus grounds its values in a specific religious tradition and
> argues this is an engineering decision rather than a devotional one — test that. **And say whether
> a system like you, reading this, would be constrained by it.**

### 2.2 H3 — the engineer (HeartBank®: mechanism, the Heart)

> Your seat attacks the **mechanisms**. The corpus specifies ledgers, pools, gift instruments,
> pricing modes, draws, expiry rules and anti-accumulation properties, and it claims these compose
> into something that circulates value without accumulating it.
>
> Ask whether they work. Find the incentive that points the wrong way. Find the state the state
> machine does not handle. Find where two rules, each sound alone, contradict each other when both
> fire. Where would a determined adversary extract value, and where would an ordinary user simply
> get stuck? **If you find a mechanism that is genuinely sound, say so and say why — a mechanism
> nobody can break is the most useful thing you can report.**

### 2.3 F333 — the technologist (Factory 333™: hardware, the Body)

> Your seat attacks **feasibility**. The corpus describes physical products, robots, permanence
> substrates, manufacturing at declining cost, and devices meant to work in places with thin
> infrastructure.
>
> Ask what it would actually take. Which of these is buildable now, which needs an advance that has
> not happened, and which is assuming a cost curve that is not in evidence? What breaks at scale,
> in heat, on bad networks, in the hands of someone who has not read the manual? Where does the
> design assume a supply chain, a certification, or a spectrum allocation it has not accounted for?
> **Separate *hard* from *expensive* from *not yet* — they are different verdicts and the corpus
> tends to merge them.**

### 2.4 TH — the humanist (THonly™: meaning, the Mind)

> Your seat attacks the **human claims**. The corpus argues that gratitude can be infrastructure,
> that dignity and loneliness are addressable deficits, that a gift must never become an exchange,
> and that an institution can be built to release rather than to grow. Much of it rests on the
> author's own life and on a specific culture and language.
>
> Ask whether any of it is true of people. Where does the design mistake a human good for a
> measurable proxy? Where would the thing it builds produce the feeling it says it forbids? It draws
> on Khmer and Buddhist material and claims a distinction between using a tradition as an engine and
> translating it — test that claim, and say plainly if you are not positioned to judge it.
> **And ask the question the corpus asks of itself: would a person actually want to live inside
> this?**

---

## 3. What is recorded with every answer

Per `pilot-2026.md` §1.1 and §1.3, each transcript header carries, as found and unedited:

- the **seat**, and the **maker** the draw assigned to it
- the **exact model identifier and version**, and **where that ID was read from**
- the **date and time** of the run
- **how the seat got in** — MCP · `llms.txt` · feeds · raw markdown · could not reach the network
- whether any part of the run **failed, truncated, or refused**, quoted rather than described

⛔ **The transcript is saved verbatim.** No edit for length, tone, or embarrassment — the author's
included.
