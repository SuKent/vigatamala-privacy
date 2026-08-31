# Vigatamala Blocking Rules

[繁體中文](/rules.zh-Hant) · [简体中文](/rules.zh-Hans) · [English](/rules.en) · [日本語](/rules.ja) · [한국어](/rules.ko)

This is where the ad and tracker blocking rules used by the Vigatamala iOS
browser live.

These two lists are **not bundled with the app** — the user downloads them from
inside it. In other words, the files below *are* the converted artefacts the app
actually consumes, and anyone may download, inspect or reuse them (see the
licence below).

## Downloads

| File | What it is |
|---|---|
| [easylist.json](https://privacy.link2us.link/rules/easylist.json) | EasyList, adapted to the content blocker format |
| [easylist.NOTICE.txt](https://privacy.link2us.link/rules/easylist.NOTICE.txt) | Attribution and upstream copyright notices |
| [easyprivacy.json](https://privacy.link2us.link/rules/easyprivacy.json) | EasyPrivacy, adapted to the content blocker format |
| [easyprivacy.NOTICE.txt](https://privacy.link2us.link/rules/easyprivacy.NOTICE.txt) | Same as above |
| [easylist.json.sig](https://privacy.link2us.link/rules/easylist.json.sig) | Ed25519 signature (verified by the app) |
| [easyprivacy.json.sig](https://privacy.link2us.link/rules/easyprivacy.json.sig) | Same as above |

## What these are

The two JSON files above are **adaptations** of [EasyList](https://easylist.to/)
and EasyPrivacy: we convert the Adblock Plus filter syntax into Apple's Safari
content blocker JSON format. In the process we:

- discard rule types that format cannot express (scriptlet injection, advanced
  options, and so on);
- truncate to 65,000 rules — this is a conservative cap **we chose ourselves**
  (out of regard for compilation time and memory on older devices), not a limit
  of the format. Against today's upstream this cap **is not actually cutting
  anything** (easylist 60,928 rules, easyprivacy 55,895 — both under it).
  WebKit currently rejects a list of more than 150,000 rules at the parsing
  stage, but that number is a WebKit implementation detail (Apple's
  documentation does not state it, and it was only raised from 50,000 at the end
  of 2020), and it was set against a compilation process with a memory budget of
  roughly 150 MB — how many rules will compile and how many are worth compiling
  are not the same question, and we do not intend to go near that line.

So they are **not equivalent** to the upstream lists, and the blocking they
achieve is not identical either. If you want the complete originals, use the
[upstream source](https://easylist.to/) directly.

## Licence

Upstream is dual-licensed under GPLv3 or CC BY-SA 3.0 Unported, at the
recipient's choice. **This adapted version expressly adopts CC BY-SA 3.0
Unported.**

- Attribution: The EasyList authors (https://easylist.to/)
- Full licence text: <https://creativecommons.org/licenses/by-sa/3.0/legalcode>
- The original authors do **not** endorse this adapted version.

The `.NOTICE.txt` beside each rule file preserves the upstream file header's
copyright notices verbatim (Title / Version / Last modified / Commit / Homepage
/ Licence), because content blocker JSON is a bare top-level array with no
comment syntax — there is nowhere inside the file to write them back. Those
NOTICE files also record the upstream version and commit each conversion was
based on, so it can be audited version by version.

**The licence covers the `rules/` directory only**; all rights are reserved for
the rest of this site (the privacy policy and so on).

## Verifying integrity

The rule files are signed with Ed25519 (each `.sig` is the base64 of a 64-byte
raw signature). The Vigatamala app embeds the corresponding public key, and a
mirror source is only used if its signature verifies.

## Reproducing this

`rules/converter/` is a standalone buildable converter (the same source the app
uses; the same input produces byte-identical output):

```bash
cd rules/converter
swift build -c release
.build/release/RuleConverter <input.txt> <output.json> 65000
```

The rules in this repository are synced automatically every day by GitHub
Actions (see `.github/workflows/`), using exactly this converter.
