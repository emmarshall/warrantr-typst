# Test the warrant-vignette extension

This folder is the smoke-test workspace for the extension. It
contains a self-contained copy of the extension plus the eight
example `.qmd` entry points so each render path can be exercised
without touching a downstream consumer project.

## Layout

```
warrantr-typst/
├── _extensions/
│   └── warrant-vignette/      # the extension, already installed
├── affidavit-only.qmd         # render: affidavit pages only
├── arrest-warrant-only.qmd    # render: arrest warrant only
├── exhibit-only.qmd           # render: attachment + text-message exhibit
├── exhibit-browser.qmd        # render: attachment + browser-history exhibit
├── exhibit-photos.qmd         # render: attachment + photo-log exhibit
├── return-only.qmd            # render: return-and-inventory only
├── warrant-only.qmd           # render: search warrant only
└── test-warrant.qmd           # render: full packet
```

The extension is already in `_extensions/warrant-vignette/`, so no
`quarto add` step is needed.

## Three render paths

### 1. Typst standalone (fastest sanity check)

```bash
cd _extensions/warrant-vignette
typst compile typst/example.typ --root .
```

Open `typst/example.pdf`. If the layout looks roughly right (stamps,
seals, and signatures present), the Typst layer compiles. If this
errors, the issue is Typst-side and the next two paths won't help.

### 2. Quarto render (verifies the extension wiring)

From this folder:

```bash
quarto render test-warrant.qmd
```

Produces `test-warrant.pdf`, a clean (no photocopy effect) render
of the full five-document packet.

### 3. Full pipeline with photocopy

In R, from this folder, with the warrantR package installed
(`pak::pak("emmarshall/warrantR")`):

```r
library(warrantR)

render_warrant(
  qmd_path = "test-warrant.qmd",
  output_pdf = "stim/test-warrant.pdf",
  output_pages_dir = "stim/test-warrant_pages",
  photocopy_level = "moderate",
  seed = 4747
)
```

Outputs:

```
stim/
├── test-warrant_clean.pdf      # untouched Quarto/Typst render
├── test-warrant.pdf            # aged version
└── test-warrant_pages/
    ├── page_001.png
    ├── page_002.png
    └── ...
```

## Required setup

```r
# in R, once
install.packages("pak")
pak::pak("emmarshall/warrantR")
```

The package pulls in the runtime deps it needs (Cairo, cli, fs,
magick, etc.) automatically.

Optional handwriting font for the fill-in fields:

```bash
brew install --cask font-caveat   # macOS
```

## Editing exhibit renderers

The four exhibit renderers (`meta-records`, `text-messages`,
`browser-history`, `photo-log`) live in two places that must stay in
sync: the standalone Typst path imports them from
`_extensions/warrant-vignette/typst/exhibits/*.typ`, and the Quarto
path needs the same definitions inlined into
`_extensions/warrant-vignette/typst-template.typ` (because Quarto's
template-partials mechanism splices the template into the project
root, where relative imports do not resolve).

The `typst/exhibits/*.typ` files are CANONICAL. After editing one of
them, regenerate the inlined block in the template using the
warrantr package:

```r
library(warrantR)
build_exhibits()
```

`build_exhibits()` replaces the region between
`// EXHIBITS-AUTO-START` and `// EXHIBITS-AUTO-END` markers in
`typst-template.typ` with the contents of the canonical files (with
the `merge-config` import line stripped, since the template provides
`merge-config` locally). It is idempotent; re-running with no source
changes makes no edits.

If you forget to re-run it, the standalone Typst render (path 1
above) will pick up your change but the Quarto render (path 2) will
silently use the old inlined version.

## When something breaks

Try the paths in order. The first one to fail localizes the bug:

| Path fails | Most likely cause |
|---|---|
| 1 (Typst) | Typst syntax, asset paths, font missing, `--root` flag |
| 2 (Quarto) | Field-name mismatch in `typst-template.typ`, extension manifest |
| 3 (R) | magick `image_draw` calls, `quarto` not on PATH, missing R package |

File issues at <https://github.com/emmarshall/warrantr-typst/issues>
or, for the R package side, at
<https://github.com/emmarshall/warrantR/issues>.
