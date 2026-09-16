# The RFC 3161 leg

A second, independent timestamp layer beside the OpenTimestamps proofs. It exists
because **the two legs fail for unrelated reasons** — not because one backs up the
other.

|  | OpenTimestamps → Bitcoin | RFC 3161 → a trust authority |
|---|---|---|
| Trust basis | cryptoeconomic; no authority | legal/PKI; a named, supervised authority |
| Recognised by a court today | uncertain, needs explaining | yes, routinely |
| Legal presumption | none | **yes**, for a *qualified* timestamp (eIDAS Art. 41) |
| Expires | never | **yes** — the signing cert has an end date |
| Depends on an organisation surviving | no | yes |
| Cost | free | free |

Bitcoin has permanence and no legal standing. A TSA has legal standing and no
permanence. Adding a *second blockchain* would have added neither property — it
would be the same trust model twice, failing together on the one question that
decides the matter: whether the forum accepts a chain as evidence at all.

## What is actually attested

Not each file. A dated **manifest** — every git-tracked path and its SHA-256 —
signed by three authorities and stamped to Bitcoin.

```
timestamps/manifests/2026-08-15.sha256              the manifest
timestamps/manifests/2026-08-15.sha256.aped-gr.tsr     signed by APED (GR)
timestamps/manifests/2026-08-15.sha256.accv-es.tsr     signed by ACCV (ES)
timestamps/manifests/2026-08-15.sha256.freetsa-de.tsr  signed by FreeTSA (DE)
timestamps/manifests/2026-08-15.sha256.ots             Bitcoin, via OpenTimestamps
```

Two reasons for the manifest rather than one token per file:

1. **It closes a real gap in the `.ots` leg.** `ots stamp` never re-stamps, so a
   *revised* document keeps attesting its superseded text until a human rotates
   the proof to `.rN.ots` by hand. The manifest re-attests the current text of
   everything, weekly, with no human step.
2. **The series is a hash chain.** Each manifest covers all earlier manifests and
   their tokens, so no past manifest can be quietly altered afterwards.

Proving a document is two checkable links: the file's SHA-256 appears in the
manifest, and the manifest is signed. `./tsa-verify.sh <file>` walks both and
reports the earliest manifest attesting that exact text.

## The authorities, and why these three

Three, on **two different legal bases** across **three jurisdictions**.

**`aped-gr` — Hellenic Public Administration Certification Authority (Greece).**
The strongest of the three. eIDAS-**qualified**: its issuing CA is listed in the
official Greek Trusted List — published by EETT, reached from the EU List of
Trusted Lists — as a `QTST` service with status `granted`. Its tokens are
qualified electronic time stamps under Art. 42 and carry the **Art. 41
presumption** of accuracy of date and integrity of data throughout the EU.
Government-operated and free.

**`accv-es` — Agencia de Tecnología y Certificación Electrónica (Valencia, Spain).**
Also qualified, and its root `ACCVRAIZ1` is in the public browser and OS trust
stores — so a token verifies against trust a third party already carries.

**`freetsa-de` — FreeTSA (Germany).** The one with **no terms-of-service problem**.
The commercial free endpoints (DigiCert, Sectigo, GlobalSign, Certum, Apple,
SwissSign — all tested and all working) scope their free service to *code
signing*. Building a decade-long evidentiary record on a service used outside its
stated terms is not a foundation, whatever the server accepts today. FreeTSA is
offered for general use, and it is institutionally independent of both the EU
qualified regime and the commercial CA industry.

## The pinned roots

`ca/*.pem` holds one **trust anchor per authority**. Tokens are requested with
`-cert`, so each token embeds its own signing chain; the pinned root is the only
other thing verification needs. **Verification is fully offline** and keeps
working if every one of these authorities disappears.

| File | Subject | SHA-256 fingerprint | Independently confirmed? |
|---|---|---|---|
| `aped-gr.pem` | `APED Global Root CA` | `10B5F9C2…686AC32F` | ⚠️ **see below** |
| `accv-es.pem` | `ACCVRAIZ1` | `9A6EC012…04384113` | ✅ present in the public OS trust store |
| `freetsa-de.pem` | `Free TSA Root CA` | `A6379E7C…1D18AABC` | ✅ byte-identical to the published `freetsa.org/files/cacert.pem` |

⚠️ **Honest residual — the APED root was captured from the token itself, not from
an independent source.** What *was* confirmed independently is the link that
carries the qualified claim: the **issuing CA** in that chain
(`617DF207…DF1BC662`) appears in the Greek Trusted List with status `granted`.
The self-signed root above it was not separately cross-checked — `pki.aped.gov.gr`
serves a JavaScript-rendered repository page with no direct certificate link, and
the Trusted List pins the issuing CA rather than the root. The practical exposure
is small (a substituted root would have to also produce a chain to a TSL-listed
issuing CA), but it is not zero and it is recorded rather than glossed. **To close
it:** obtain `APED Global Root CA` from APED directly and compare the fingerprint.

Fingerprints are listed here so that any future substitution of a root is
detectable by reading this file rather than by trusting the directory.

## Verifying

```sh
./tsa-verify.sh                      # latest manifest + re-hash the tree
./tsa-verify.sh --all                # every manifest ever written
./tsa-verify.sh path/to/paper.md     # earliest date this exact text can be proven
```

Or by hand, with nothing from this repository but the root:

```sh
openssl ts -verify -data timestamps/manifests/<date>.sha256 \
  -in timestamps/manifests/<date>.sha256.aped-gr.tsr \
  -CAfile timestamps/ca/aped-gr.pem
```

### ⚠️ The trap that will bite in about ten years

A token signed in 2026 is still good evidence in 2040 — but the signing
certificate will have **expired** by then, and `openssl ts -verify` checks
certificate validity at the **current** time by default. It will print
`Verification: FAILED` for entirely the wrong reason.

The correct question is whether the certificate was valid **when it signed**:

```sh
openssl ts -verify ... -attime <the token's own timestamp, as a unix epoch>
```

`tsa-verify.sh` already does this automatically: it tries the plain check first,
and on failure retries pinned to the token's own time, reporting
`OK (cert expired since; valid at signing time)`. This is not a loosening of the
check — it is the right check for archival evidence. **Anyone verifying by hand
must know it**, which is why it is written here rather than left in the script.

## Honest scope

A timestamp proves **this exact text existed no later than that moment**. It
proves nothing about authorship, originality, or the validity of any claim.

**It is not prior art.** Prior art requires *public availability*; a privately
held document is not prior art however well dated. That job belongs to the public
render plus the archive snapshots, and this layer is not an upgrade path to it.
A stamp also **dates forward, never backward** — stamping today can never
establish an earlier date.
