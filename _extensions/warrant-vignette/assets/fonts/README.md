# Fonts

The Typst template at render time uses these fonts. They must be available
on the rendering machine.

## Document body fonts

These are bundled with most Linux distributions and TeX Live, and ship with
macOS via Homebrew or the TeX install:

- **Liberation Serif** — body text in the affidavit, warrant, and return
- **Liberation Sans** — caption block, "FILED" / date stamp text
- **Liberation Mono** — used inside the FILED stamp face

All three are SIL OFL licensed and freely redistributable.

## Handwriting font

For hand-written content (the time inside the FILED stamp, dates and
times in fill-in fields, the "DAYTIME" specification on the warrant), the
template uses a handwriting font.

**Preferred:** *Caveat* (Google Fonts, SIL OFL).
**Fallback:** Liberation Serif Italic at a small size with a slight
rotation. Less authentic but always available.

Caveat is not bundled with the extension because of repository size and
licensing distribution practice — instead the user installs it system-wide
and the template detects it. If Caveat is missing, the template falls back
to italic serif and emits a build warning.

To install Caveat on macOS:

```bash
brew install --cask font-caveat
```

On Linux:

```bash
mkdir -p ~/.fonts
# download Caveat[wght].ttf from https://fonts.google.com/specimen/Caveat
cp Caveat-VariableFont_wght.ttf ~/.fonts/
fc-cache -f
```

## Stamp display font

The FILED stamp uses Liberation Mono Bold for a stamp-machine feel.
*Special Elite* (Google Fonts, Apache 2.0) would be a closer match to the
distressed-typewriter look real legal stamps use; if the user installs it,
the cairo build script can be re-pointed at it. For now, Liberation Mono
Bold renders cleanly and reads as official.
