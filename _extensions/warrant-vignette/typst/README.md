# Typst layer: Warrant Vignette Extension

This directory holds the Typst code that lays out the search-warrant
packet documents. The R asset library produces the visual elements
(stamps, seals, signatures); this layer composes them into pages.

## Files

```
typst/
├── typst.toml             # package manifest (registers as @local/warrant-vignette)
├── lib.typ                # main entry: exposes warrant-packet()
├── example.typ            # standalone test driver: compile to verify the stack
├── partials/
│   ├── util.typ           # default-config, merge-config, handwritten, fill-in
│   ├── caption.typ        # state/county/ss: pleading caption
│   ├── header.typ         # top-of-page stamp cluster
│   ├── signature.typ      # detective + judge signature blocks
│   ├── notary.typ         # notary block with strike-through "Judge or"
│   └── footer.typ         # decorative case-id barcode
├── docs/
│   ├── affidavit.typ      # affidavit in support of search warrant
│   ├── warrant.typ        # search warrant
│   ├── return.typ         # return and inventory
│   └── attachment.typ     # attachment cover sheet
└── exhibits/             # CANONICAL, also inlined into ../typst-template.typ
    ├── meta-records.typ   # Meta Platforms (Facebook / Messenger) format
    ├── text-messages.typ  # SMS / iMessage transcript
    ├── browser-history.typ # forensic browser-history / search table
    └── photo-log.typ      # photo grid with captions
```

The four files in `exhibits/` are the canonical source for the
exhibit renderers and are also inlined into `../typst-template.typ`
for the Quarto path. After editing one, run the inliner:

```r
source("_extensions/warrant-vignette/R/build_exhibits.R")
build_exhibits()
```

## Quick test

From this directory:

```bash
typst compile example.typ --root ..
```

The `--root ..` flag points the project root at the warrant-vignette
extension root so the example can reference assets in `../assets/...`.

If the compile succeeds, inspect `example.pdf` against the source
document and note any layout or rotation tweaks needed.

## Library entry point

`lib.typ` exposes `warrant-packet(user-config, document-types, ...)`:

```typst
#import "@local/warrant-vignette:0.1.0": warrant-packet

#warrant-packet(
  user-config: (
    case-number: "CR24-087",
    filed-date: "AUG 12 2024",
    suspect-names: ("[Suspect A]", "[Suspect B]"),
    // ... see example.typ for the full config
  ),
  document-types: ("affidavit", "attachment", "warrant", "return"),
)
```

The full set of supported config keys is defined in
`partials/util.typ` as `default-config`. Per-condition values override
the defaults via `merge-config()`.

## Document types

| Document     | Function       | Pages | Notes                                                               |
| ------------ | -------------- | ----- | ------------------------------------------------------------------- |
| `affidavit`  | `affidavit()`  | 3–5   | Header → caption → opening → items → location → narrative → sigs    |
| `warrant`    | `warrant()`    | 1     | Header → caption → "TO:" → findings → command list → date / time / sig |
| `return`     | `return-doc()` | 1     | Header (with Case # label) → caption → inventory list → sig + notary |
| `attachment` | `attachment()` | 1     | Centered title + descriptive paragraph; rest is white space          |

## Asset paths

The Typst layer takes asset paths as parameters via `user-config`. The
caller (Quarto extension or `example.typ`) is responsible for setting
paths that resolve from the calling file's directory. In `example.typ`
the assets are referenced as `../assets/seals/...` because the example
sits in `typst/` and the assets live in `../assets/`.

When the Quarto extension wrapper (Phase 4) handles this, paths will
be resolved automatically based on the extension installation
directory.

## Exhibits

Attaching an exhibit to a packet works the same way a court document
does. Just include `"exhibit"` in `document-types` and supply
`exhibit-type` plus `exhibit-records` in `user-config`.

```typst
#warrant-packet(
  user-config: (
    // ... fixed metadata ...
    exhibit-type: "meta-records",
    exhibit-starting-page: 1403,
    exhibit-records: (
      (author: "[Suspect A]", account: "100009604664543",
       sent: "2024-04-20 16:47:34 UTC",
       body: "Hey we can get the show on the road the stuff came in"),
      // ...
    ),
  ),
  document-types: ("affidavit", "attachment", "exhibit", "warrant", "return"),
)
```

| `exhibit-type`      | Renderer                       | Aliases                         |
| ------------------- | ------------------------------ | ------------------------------- |
| `meta-records`      | Meta / Facebook records         | `facebook-messages`             |
| `text-messages`     | SMS / iMessage transcript       | `sms`                           |
| `browser-history`   | Forensic browser / search table | `search-history`                |
| `photo-log`         | Photo grid with captions        | `photos`, `evidence-photos`     |

## What's not in this layer

- The Quarto custom-format extension that translates `.qmd` YAML
  metadata into a `warrant-packet()` call (Phase 4).
- The R + magick photocopy post-processor (Phase 5).

## Limitations and known caveats

- Compile-tested status: the code has not been compiled in the
  development sandbox (Typst was not available). Expect to iterate
  on margins, rotations, and exact stamp positions on first compile.
- The handwriting font Caveat is preferred for fill-in fields. If it
  isn't installed system-wide, the template falls back to Liberation
  Serif Italic. Fill-in fields will look different than the source
  document until Caveat is available.
- The barcode is decorative, not a real Code 39 symbology. The bars
  encode positions derived from the case-id string but won't scan.
