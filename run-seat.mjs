#!/usr/bin/env node
// Build one seat's round from the STAMPED protocol and hand it to /polish's reviewer transport.
//
//   node run-seat.mjs <seat> --maker <openai|gemini|xai|anthropic> [--dry-run] [--max-usd N]
//   node run-seat.mjs SW --maker anthropic --dry-run
//
// ⭐ THE PROMPTS ARE READ OUT OF `protocol/seat-prompts-2026.md`, NEVER TYPED HERE. That file is
// committed and OpenTimestamps-stamped before any seat runs, so what a model was asked is provable
// rather than asserted. This script extracts §1 (the entry brief) and the one §2 subsection for the
// named seat, and records the sha256 of the protocol file it read them from.
//
// ⛔ IT WILL NOT INVENT A PROMPT. If a seat's section is missing or the file has moved, it exits 2
// rather than falling back to anything — a run whose prompt came from somewhere else is not this
// protocol's run.
//
// ⚠️ --maker IS REQUIRED AND IS NOT A DEFAULT. Which maker sits in which seat is decided by the
// B-Called℠ draw (`protocol/pilot-2026.md` §1.2), not by this script and not by whoever runs it.
// Passing it explicitly is what makes the draw's result visible in the command that ran.
//
// ⚠️ MODEL TIER: /polish defaults to cheap models (gemini-3.5-flash, gpt-5) because it reviews one
// paper at a time on the founder's budget. This book asks for each maker's MOST CAPABLE generally
// available model. Set POLISH_<MAKER>_MODEL before running; this script prints what it will use and
// refuses silently-cheap defaults for gemini and openai.
import { readFileSync, writeFileSync, mkdirSync, existsSync } from 'node:fs';
import { createHash } from 'node:crypto';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { spawnSync } from 'node:child_process';

const HERE = dirname(fileURLToPath(import.meta.url));
const PROTOCOL = join(HERE, 'protocol', 'seat-prompts-2026.md');
const REVIEW = join(HERE, '..', '..', '.claude', 'skills', 'polish', 'scripts', 'review.mjs');
const SEATS = { SW: 'the critic', H3: 'the engineer', F333: 'the technologist', TH: 'the humanist' };
const MAKERS = ['openai', 'gemini', 'xai', 'anthropic'];

// The tiers /polish picks for cost. Named here so a book run cannot inherit them by accident.
const CHEAP = { gemini: 'gemini-3.5-flash', openai: 'gpt-5' };

const die = m => { console.error(`run-seat: ${m}`); process.exit(2); };

const argv = process.argv.slice(2);
const seat = argv[0];
let maker = null, passthrough = [];
for (let i = 1; i < argv.length; i++) {
    if (argv[i] === '--maker') maker = argv[++i];
    else passthrough.push(argv[i]);
}
if (!seat || !SEATS[seat]) die(`first argument must be a seat: ${Object.keys(SEATS).join(' · ')}`);
if (!maker) die('--maker is required — it records what the B-Called draw assigned (protocol §1.2)');
if (!MAKERS.includes(maker)) die(`--maker must be one of ${MAKERS.join(', ')}`);
if (!existsSync(PROTOCOL)) die(`the stamped protocol is missing at ${PROTOCOL} — nothing to read a prompt from`);

const text = readFileSync(PROTOCOL, 'utf8');
const protocolSha = createHash('sha256').update(text).digest('hex');

// §1 is the entry brief every seat gets; §2.x is this seat's alone.
const brief = text.split(/^## 1\. The entry brief[^\n]*$/m)[1]?.split(/^---$/m)[0]?.trim();
if (!brief) die('could not find §1 (the entry brief) in the protocol — refusing to run without it');
const seatRe = new RegExp(`^### 2\\.\\d+ ${seat} — [^\\n]*$`, 'm');
const afterHeading = text.split(seatRe)[1];
if (!afterHeading) die(`could not find the §2 subsection for seat ${seat} — refusing to invent one`);
const seatPrompt = afterHeading.split(/^(?:###|---)/m)[0].trim();
if (!seatPrompt) die(`seat ${seat}'s section is empty — refusing to run`);

const model = process.env[`POLISH_${maker.toUpperCase()}_MODEL`];
if (!model && CHEAP[maker]) {
    die(`refusing to run seat ${seat} on ${maker}'s cheap /polish default (${CHEAP[maker]}).\n` +
        `        The protocol asks for that maker's MOST CAPABLE generally-available model.\n` +
        `        Set POLISH_${maker.toUpperCase()}_MODEL explicitly, read from the maker's own docs.`);
}

// ⛔ THE MACHINE DATE, NOT UTC. A round directory's name is a stored form that is also the read
// form, and nothing will ever convert it — so it must already be the founder's local date. Caught
// live on 2026-09-19 PDT, when toISOString() named the directory 2026-09-20.
const d = new Date();
const date = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
let n = 1, round;
do { round = join(HERE, 'transcripts', `${date}-${seat}-${maker}-r${n}`); n++; } while (existsSync(round));
mkdirSync(round, { recursive: true });

// review.mjs reads exactly these three. `paper.md` is the entry brief rather than a paper: this run
// sends the seat THROUGH the Machine Door instead of handing it a bundle, which is the whole point.
writeFileSync(join(round, 'prompt.md'), `${seatPrompt}\n`);
writeFileSync(join(round, 'paper.md'), `${brief}\n`);
writeFileSync(join(round, 'meta.json'), JSON.stringify({
    run: 'pilot-2026', seat, seat_role: SEATS[seat], maker,
    model_requested: model || '(provider default — see the refusal rule above)',
    protocol: 'protocol/seat-prompts-2026.md',
    protocol_sha256: protocolSha,
    corpus: {
        'thonly/publications': '191085ac373407cc06e41f35c1cf2282f542cebe',
        'HeartBank/publications': '9452b6eee00b2d63d45400693f7bec8accd060a1'
    },
    genre: 'two-singularities-seat', control: false,
    paper_words: brief.split(/\s+/).length,
    created: new Date().toISOString()
}, null, 2) + '\n');

console.log(`seat:     ${seat} — ${SEATS[seat]}`);
console.log(`maker:    ${maker}${model ? `   model ${model}` : ''}`);
console.log(`protocol: sha256 ${protocolSha.slice(0, 12)}…  (stamped; this is what the seat was asked)`);
console.log(`round:    ${round}`);

const r = spawnSync('node', [REVIEW, round, '--providers', maker, ...passthrough],
    { stdio: 'inherit', env: process.env });
process.exit(r.status ?? 1);
