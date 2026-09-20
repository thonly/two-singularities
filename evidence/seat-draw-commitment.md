# Seat draw — commitment

*Published **before** the named beacon round was emitted. Pilot run 2026; `protocol/pilot-2026.md` §1.2 governs.*

> ⛔ **This is the half that has to come first.** The seed is a public randomness beacon round that had not
> yet occurred when this file was written and pushed. Nobody here — the founder, Miss Aquarius, or the
> substrate that wrote the prompts — could know or steer it. **If this file is not in the repository's history
> before round 32354251 was emitted, the draw is void.**

## What is committed

| field | value |
|---|---|
| draw id | `two-singularities/pilot-2026/seats` |
| form · regime | `lot` · `public` (public: salt and roster published here, with the commitment) |
| beacon network | drand quicknet, chain `52db9ba70e0cc0f6eaf7803dd07447a1f5477735fd3f661792ba94600c84e971` |
| **beacon round** | **32354251** — emits 2026-09-20T01:01:57.000Z (round at commit time: 32353851) |
| salt | `1c5805b27725bd0ef276b6af35b6e6d2e9e64f43ca5f7ea37a6c8ebebb3e4323` |
| roster, in committed order | `Anthropic`, `OpenAI`, `Google DeepMind`, `xAI` |
| admit | 4 (all four are seated; the ORDER is the assignment) |
| **commitment** | `b8a496e378d8709727a3749c7c014e9f6246ae3c0b99768bee3e503bbb57e580` |

## How the order becomes seats

The seats, in their committed order, are **SW · H3 · F333 · TH**. The drawn order is read against that list
position by position: the first maker drawn takes **SW**, the second **H3**, the third **F333**, the fourth **TH**.

## Why it is drawn at all

⛔ The substrate compiling this book is itself one of the four makers' models. A hand-assignment would carry the
obvious objection that Claude took the flattering chair. HARD directive **#67**: every lot Miss Aquarius operates
is a called draw.

## Recomputing it yourself

```
npm i @333eco/primitives
```

```js
import { draw, QUICKNET } from "@333eco/primitives/b-called/v2";
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

`draw()` recomputes the commitment from these inputs and will not proceed if it differs from
`b8a496e378d8709727a3749c7c014e9f6246ae3c0b99768bee3e503bbb57e580` — so a result published later cannot have come from inputs other than these.
