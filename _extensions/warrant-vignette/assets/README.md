# Asset library

All assets here are fixed across the study. They are the visual
elements that sit on top of every rendered packet: the round court
seal, the rectangular clerk and notary stamps, and the three
signatures. None of them encode case-specific content (case number,
dates, names of suspects, narrative text); that lives in the
per-condition YAML and is overlaid by the Typst layer.

Every asset is generated procedurally by an R script using the
Cairo package's SVG backend. This means:

- The library is reproducible. Re-running the build script
  regenerates the same output (signatures use a name-derived seed
  via `set.seed()`).
- The SVG outputs are font-independent: Cairo embeds glyphs as
  paths, not font references, so Typst will render them identically
  regardless of which fonts are installed at render time.
- PNG copies are written alongside SVGs for quick visual inspection
  and as a fallback for any renderer that does not handle SVG
  cleanly.

## Files

```
seals/
  carter-county-court-clerk-stamp.svg / .png  # clerk's rectangular filed stamp
  carter-county-court-judge-seal.svg / .png   # round judge's signature seal

stamps/
  filed-stamp.svg / .png                # FILED + A.M. ___ P.M. line
  date-stamp.svg / .png                 # date placeholder frame
  notary-stamp-doyle.svg / .png         # M. Doyle notary stamp

signatures/
  sig-hayes.png       # Detective J. Hayes
  sig-patterson.png   # Hon. R. Patterson
  sig-reilly.png      # M. Reilly (notary)

fonts/
  README.md           # font sourcing notes
```

## Regenerating

The asset generators live inside the
[warrantR R package](https://github.com/USER/warrantr) at
`R/build_seals.R`, `R/build_stamps.R`, `R/build_signatures.R`, and
the orchestrator `R/build_assets.R`. From an R session with the
package installed:

```r
library(warrantR)
build_assets()    # rebuilds seals + stamps + signatures and re-inlines
                  # the exhibit block in typst-template.typ

# Or one category at a time:
build_seals()
build_stamps()
build_signatures()
```

Each builder accepts a `target_dir` argument and defaults to the
nearest `_extensions/warrant-vignette/` walking up from the working
directory.

## Required R packages

- `Cairo` for the cairo-backed SVG / PNG output device
- `grid` for text, line, and polygon primitives (base R, no install
  needed)
- `cli` for build-message styling
- `fs` for path helpers

These come in via the warrantR package's `Imports` field and do not
need to be installed separately.

## Design notes

**Clerk's filed stamp (rectangular).** Four-row block stamp inside
a rectangular border. Top to bottom: `FILED` in large stamp
lettering, `CARTER COUNTY COURT` below it, blank space where the
Typst layer overlays the per-case date, and `M. DONOVAN, CLERK
MAGISTRATE` at the bottom. Matches the rectangular rubber-stamp
impression used by the source-document court clerk, in contrast to
a round seal.

**Judge seal (round).** Two concentric rings with `CARTER COUNTY
COURT` along the top arc and `OFFICIAL SEAL` along the bottom arc
(heads outward on the top arc, inward on the bottom so both read
upright when the seal is upright). Small ornamental dots sit at
the 9 and 3 o'clock positions; a five-pointed star sits centered
inside the inner ring in place of the older block-letter "SEAL"
motif, which read more like a logo than a rubber-ink stamp.
Stamped beside the judge's signature on the warrant and affidavit.

**FILED stamp.** Rectangular with stamp-style block lettering. The
pre-printed text reads "FILED A.M. ___ P.M." with an underline in
the time slot. The actual time is written in by the Typst layer
using a handwriting font.

**Date stamp.** A simple sans-serif "MMM DD YYYY" placeholder. The
Typst layer overlays the real date string in the same position;
the underlying asset is just for visual style reference.

**Notary stamp.** Rectangular block with a small capitol-emblem
icon at the left (stepped base, central body, dome, finial) and
three lines of text on the right: jurisdiction (`GENERAL NOTARY`),
notary name (`M. DOYLE`), and commission expiration date.

**Signatures.** Each signature is a stylized scrawl: a serif
italic initial letter followed by a Bezier curve sequence and a
closing flourish. Different name seeds produce visually distinct
scrawls. They are not intended to look like any specific real
person's handwriting; they read as "a generic stylized signature"
at typical document zoom.

## Limitations

- The procedural signature scrawl looks more like an underline-blob
  than a full hand-written name. At document zoom this is fine for
  a stimulus, but a hand-drawn signature image in PNG could be
  substituted later if realism is found wanting at pilot.
- The handwriting font for filled-in dates and times must be
  available to Typst at render time. The
  [fonts/README.md](fonts/README.md) tracks the choices.
