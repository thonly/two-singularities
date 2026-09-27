#!/usr/bin/env node
// run-seat-2026-09-27.mjs — the seat runner, SECOND DATED VERSION. It SUPERSEDES `run-seat.mjs` for
// every run from 2026-09-27 on; that file is kept unedited as the record of what governed before
// (this repo's rule: every file committed before the run it governs, never edited — a correction is
// a NEW file).
//
//   node run-seat-2026-09-27.mjs <seat> --maker <openai|gemini|xai|anthropic> [--dry-run] [--max-usd N] [--no-batch]
//
// ⭐ WHAT CHANGED, AND WHY (founder, 2026-09-27: "add it as a new dated runner; use batch to minimize costs"):
//
// 1. ⛔ NO MODEL IS EVER INHERITED FROM /polish. The first runner refused /polish's cheap defaults
//    only for gemini and openai, so the xai and anthropic seats silently took whatever /polish
//    defaulted to — compliant on 2026-09-27 BY ACCIDENT, and one cost decision in /polish away from
//    breaking the protocol's promise (each maker's MOST CAPABLE generally-available model, read from
//    the maker's own docs on the run date). Now POLISH_<MAKER>_MODEL is REQUIRED for all four and is
//    recorded in meta.json. A property, not a rule: a /polish cost change cannot reach the book.
//
// 2. ⭐ --batch IS THE DEFAULT (pass --no-batch to opt out). It changes PRICE and SPEED, never the
//    model: OpenAI runs the SAME model on the flex tier; Anthropic goes through the Message Batches
//    API. xAI and Gemini have no batch path in the transport and run normally. The discount is
//    recorded only when the VENDOR confirms it (/polish SKILL.md §cost).
//
// 3. ⭐ A PENDING BATCH IS RESUMED, NEVER RESUBMITTED. An Anthropic batch is collected by running the
//    SAME command again. The first runner made a NEW round directory on every run, so a second run
//    would have submitted a second batch instead of collecting the first. This runner looks for an
//    existing round of this seat and maker holding `<maker>.batch.json` with no `collected` stamp,
//    and reuses it — prompts and meta untouched.
//
// Everything else is the first runner's, unchanged: THE PROMPTS ARE READ OUT OF the stamped
// `protocol/seat-prompts-2026.md`, never typed here; ⛔ it will not invent a prompt; ⚠️ --maker is
// required and records what the B-Called draw assigned; ⛔ the round directory is named by the
// MACHINE date, never UTC.
import { readFileSync, writeFileSync, mkdirSync, existsSync, readdirSync } from 'node:fs';
import { createHash } from 'node:crypto';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { spawnSync } from 'node:child_process';

const HERE = dirname(fileURLToPath(import.meta.url));
const PROTOCOL = join(HERE, 'protocol', 'seat-prompts-2026.md');
const REVIEW = join(HERE, '..', '..', '.claude', 'skills', 'polish', 'scripts', 'review.mjs');
const SEATS = { SW: 'the critic', H3: 'the engineer', F333: 'the technologist', TH: 'the humanist' };
const MAKERS = ['openai', 'gemini', 'xai', 'anthropic'];


const die = m => { console.error(`run-seat: ${m}`); process.exit(2); };

const argv = process.argv.slice(2);
const seat = argv[0];
let maker = null, passthrough = [];
let batch = true;
for (let i = 1; i < argv.length; i++) {
    if (argv[i] === '--maker') maker = argv[++i];
    else if (argv[i] === '--no-batch') batch = false;
    else if (argv[i] === '--batch') batch = true;
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
if (!model) {
    die(`refusing to run seat ${seat} without an explicit model for ${maker}.\n` +
        `        The protocol asks for that maker's MOST CAPABLE generally-available model on the run date,\n` +
        `        read from the maker's own docs. ⛔ /polish's default is never inherited, for ANY maker.\n` +
        `        Set POLISH_${maker.toUpperCase()}_MODEL explicitly.`);
}

// ⛔ THE MACHINE DATE, NOT UTC. A round directory's name is a stored form that is also the read
// form, and nothing will ever convert it — so it must already be the founder's local date. Caught
// live on 2026-09-19 PDT, when toISOString() named the directory 2026-09-20.
const d = new Date();
const date = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
const TRANSCRIPTS = process.env.RUN_SEAT_TRANSCRIPTS || join(HERE, 'transcripts');   // override exists for the self-test only

// ⭐ Resume a pending batch before making anything new (change 3 above).
const pending = !existsSync(TRANSCRIPTS) ? [] : readdirSync(TRANSCRIPTS)
    .filter(dir => new RegExp(`^\\d{4}-\\d{2}-\\d{2}-${seat}-${maker}-r\\d+$`).test(dir))
    .filter(dir => {
        const f = join(TRANSCRIPTS, dir, `${maker}.batch.json`);
        return existsSync(f) && !JSON.parse(readFileSync(f, 'utf8')).collected;
    }).sort();
if (pending.length > 1) die(`more than one uncollected batch for ${seat}/${maker}: ${pending.join(', ')} — resolve by hand`);

let round, resumed = false;
if (pending.length === 1) {
    round = join(TRANSCRIPTS, pending[0]); resumed = true;
    const m = JSON.parse(readFileSync(join(round, 'meta.json'), 'utf8'));
    if (m.model_requested !== model) die(`the pending batch in ${pending[0]} was submitted for ${m.model_requested}, not ${model} — refusing to mix`);
} else {
    let n = 1;
    do { round = join(TRANSCRIPTS, `${date}-${seat}-${maker}-r${n}`); n++; } while (existsSync(round));
    mkdirSync(round, { recursive: true });
}

if (!resumed) {
// review.mjs reads exactly these three. `paper.md` is the entry brief rather than a paper: this run
// sends the seat THROUGH the Machine Door instead of handing it a bundle, which is the whole point.
writeFileSync(join(round, 'prompt.md'), `${seatPrompt}\n`);
writeFileSync(join(round, 'paper.md'), `${brief}\n`);
writeFileSync(join(round, 'meta.json'), JSON.stringify({
    run: 'pilot-2026', seat, seat_role: SEATS[seat], maker,
    model_requested: model,
    protocol: 'protocol/seat-prompts-2026.md',
    protocol_sha256: protocolSha,
    corpus: {
        'thonly/publications': '191085ac373407cc06e41f35c1cf2282f542cebe',
        'HeartBank/publications': '9452b6eee00b2d63d45400693f7bec8accd060a1'
    },
    genre: 'two-singularities-seat', control: false,
    paper_words: brief.split(/\s+/).length,
    runner: 'run-seat-2026-09-27.mjs',
    batch,
    created: new Date().toISOString()
}, null, 2) + '\n');
}

console.log(`seat:     ${seat} — ${SEATS[seat]}`);
console.log(`maker:    ${maker}${model ? `   model ${model}` : ''}`);
console.log(`protocol: sha256 ${protocolSha.slice(0, 12)}…  (stamped; this is what the seat was asked)`);
console.log(`round:    ${round}${resumed ? '   (RESUMING the pending batch — collecting, not resubmitting)' : ''}`);
console.log(`batch:    ${batch ? 'on (price and speed only; the model is unchanged)' : 'off'}`);

const r = spawnSync('node', [REVIEW, round, '--providers', maker, ...(batch ? ['--batch'] : []), ...passthrough],
    { stdio: 'inherit', env: process.env });
process.exit(r.status ?? 1);
