# Seat draw — result

*Computed 2026-09-19, after beacon round 32354251 was emitted. Commitment published beforehand:
`evidence/seat-draw-commitment.md`. `protocol/pilot-2026.md` §1.2 governs.*

## The result

| seat | role | maker |
|---|---|---|
| **SW** | the critic | **OpenAI** |
| **H3** | the engineer | **Anthropic** |
| **F333** | the technologist | **Google DeepMind** |
| **TH** | the humanist | **xAI** |

**Drawn order:** OpenAI → Anthropic → Google DeepMind → xAI

## The inputs, unchanged from the commitment

| field | value |
|---|---|
| commitment (published before the round) | `b8a496e378d8709727a3749c7c014e9f6246ae3c0b99768bee3e503bbb57e580` |
| **commitment recomputed at draw time** | `b8a496e378d8709727a3749c7c014e9f6246ae3c0b99768bee3e503bbb57e580` — **matches** |
| beacon round | 32354251, drand quicknet |
| **randomness** | `0e6fa3b3b33a8ef56228bed16f9a4155671cc7bb2b66316f0d16d9ac3e96a77b` |
| salt | `1c5805b27725bd0ef276b6af35b6e6d2e9e64f43ca5f7ea37a6c8ebebb3e4323` |
| roster, committed order | `Anthropic`, `OpenAI`, `Google DeepMind`, `xAI` |

⭐ **`draw()` recomputes the commitment from the inputs and refuses to proceed if it differs**, so this
result cannot have come from inputs other than the ones published before the seed existed. At push time
the beacon API answered **HTTP 425 Too Early** for this round — drand's own refusal to serve randomness
that did not yet exist.

## What the draw decided, and what it did not

It decided **which maker sits in which seat**. ⛔ It did not decide which model, which is read from each
maker's own documentation at the run and recorded in the transcript header (`protocol/pilot-2026.md` §1.1).

⚠️ **Worth stating plainly, because it is the objection the draw exists to answer:** the substrate
compiling this book is Anthropic's. The seat that examines **alignment and succession — the claims most
pointed at that substrate's own work — went to OpenAI**, and Anthropic drew the engineering seat. Nobody
arranged that, and nobody could have: the seed did not exist when the roster was fixed.

## Recomputing it

```js
import { draw } from "@333eco/primitives/b-called/v2";
const randomness = (await (await fetch(
  "https://api.drand.sh/52db9ba70e0cc0f6eaf7803dd07447a1f5477735fd3f661792ba94600c84e971/public/32354251")).json()).randomness;
console.log(await draw({
  "network": "52db9ba70e0cc0f6eaf7803dd07447a1f5477735fd3f661792ba94600c84e971",
  "round": 32354251,
  "drawId": "two-singularities/pilot-2026/seats",
  "form": "lot",
  "regime": "public",
  "salt": "1c5805b27725bd0ef276b6af35b6e6d2e9e64f43ca5f7ea37a6c8ebebb3e4323",
  "roster": [
    "Anthropic",
    "OpenAI",
    "Google DeepMind",
    "xAI"
  ],
  "admit": 4
}, randomness));
```
