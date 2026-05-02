# warrant-vignette

A Quarto Typst extension that renders mock-up search-warrant and
arrest-warrant packets for psychology-law research vignettes. Each
packet can include some combination of an affidavit, a search
warrant, an arrest warrant, an attachment cover, an evidence exhibit
(Facebook records, text messages, browser history, or photo log), and
a return-and-inventory page. Output is stamped with fictional
jurisdictional seals and signed with stylized procedural signatures,
so the rendered files read as photocopied court documents at typical
on-screen zoom.

The extension was built for Study 1 of the dissertation. The same
case-level fixed metadata (state, county, judge, detective, notary)
is reused across the full condition matrix; per-condition variation
lives in the YAML header of each `.qmd` file.

## Installation

```bash
# from any Quarto project directory
quarto add /path/to/warrant-vignette
```

After install, the extension lives at `_extensions/warrant-vignette/`
inside the consuming project.

### Required fonts

Two fonts must be available to Typst at render time.

**Liberation Serif / Sans / Mono** are the body and stamp typefaces.
They ship with most Linux distributions, TeX Live, and macOS through
Homebrew (`brew install --cask font-liberation`).

**Autograf PERSONAL USE ONLY** is the handwriting-style font used for
all signatures (judge, detective, notary). The font ships inside the
extension at `assets/fonts/Signature/`. Install it system-wide before
the first render:

```bash
# macOS
open _extensions/warrant-vignette/assets/fonts/Signature/AutografPersonalUseOnly-mOBm.ttf
# Click "Install Font" in Font Book.
# Restart your terminal session before rendering.
```

```bash
# Linux
mkdir -p ~/.fonts
cp _extensions/warrant-vignette/assets/fonts/Signature/AutografPersonalUseOnly-mOBm.ttf ~/.fonts/
fc-cache -f
```

Verify with `fc-list | grep -i autograf`. If the font is missing,
signatures fall back to Bradley Hand and then Caveat, in that
order.

### Optional R packages

The R helpers that drive this extension (asset builders, photocopy
post-processor, batch render driver) ship in the companion
[warrantR R package](https://github.com/emmarshall/warrantR):

```r
install.packages("pak")
pak::pak("emmarshall/warrantR")
```

The R package is optional. Quarto rendering produces a clean PDF on
its own.

## Quick start

A vignette `.qmd` declares the format and supplies metadata. The body
is empty; the metadata is the document. A minimal example:

```yaml
---
format: warrant-vignette-typst
document-types: [affidavit, warrant, return]
case-number: "CR24-087"
filed-date: "AUG 12 2024"
state: "Indiana"
county: "Pawnee County"
city: "Pawnee"
detective-name: "Detective B. Macklin"
judge-name: "Hon. Perd Hapley"
suspect-names: ["[Suspect A]"]
search-address: "415 W. Sullivan Street, Pawnee, Pawnee County, Indiana"
items-to-seize:
  - "Electronic information devices..."
narrative-paragraphs:
  - "On 04-26-24 I began an investigation..."
---
```

Render with:

```bash
quarto render condition_01.qmd
```

The output is `condition_01.pdf`.

## Document types

The `document-types` field in YAML picks which document(s) to render.
List order controls the rendering order; each entry gets its own
page break.

| Value             | Output                                          | Pages |
| ----------------- | ----------------------------------------------- | ----- |
| `affidavit`       | Affidavit in Support of Search Warrant          | 2–3   |
| `warrant`         | Search Warrant                                  | 1     |
| `arrest-warrant`  | Arrest Warrant (AO 442 federal-form style)      | 1     |
| `attachment`      | Attachment cover sheet                          | 1     |
| `exhibit`         | Evidence exhibit (format chosen by `exhibit-type`) | 1+ |
| `return`          | Return and Inventory                            | 1     |

`search-warrant` is accepted as an alias for `warrant`.

### Affidavit

Multi-page narrative document. Each page carries the FILED stamp
cluster (date stamp, district court text, rotated clerk filed-copy
stamp) at the top. Body sections: opening identification, items
sought (numbered list), property location, custody and control,
narrative paragraphs, WHEREFORE close, signatures, and a Code-39 style
case-id barcode at the bottom of page 1 only.

### Search warrant

Single-page command document. Same FILED stamp cluster on top. Body
includes the TO line addressing the executing officer, court findings,
the numbered list of items to seize, handwritten DAYTIME / date / time
fill-ins, and a judge signature with the round county seal.

### Arrest warrant

Single-page form modeled on the federal AO 442 layout. No FILED
stamps; instead, a horizontal rule under the AO 442 form ID, then a
centered court name, plaintiff-v-defendant caption with parens column,
ARREST WARRANT title, YOU ARE COMMANDED command, charging-document
checkbox row, narrative paragraphs describing the offense,
signature/date footer, and a "Return" box at the bottom for arrest-
execution metadata. The Return box auto-populates from existing
config fields.

### Attachment cover

Single-page divider with a centered "ATTACHMENT # N" title and a
descriptive paragraph from the `exhibit-description` field. Used as a
cover sheet before the exhibit pages.

### Return and inventory

Single-page post-execution document with a typed "Case #" label in
the top-right (in place of the rotated clerk stamp). Body includes
the sworn statement, the inventory list of seized items, a service
note, the applicant's signature with handwritten title, the SUBSCRIBED
AND SWORN line with a handwritten date, and a notary block at the
bottom (with the "Judge or" prefix struck through, leaving "Notary
Public").

## Exhibit types

The exhibit document renders one of eleven formats depending on the
`exhibit-type` field. All eleven use the same `exhibit-records`
array in YAML, but each format expects different keys per record.

| `exhibit-type`            | Aliases                                   | Format                                                                                |
| ------------------------- | ----------------------------------------- | ------------------------------------------------------------------------------------- |
| `meta-records`            | `facebook-messages`                       | Black "Meta Platforms Business Record" header bar; Author / Sent / Body record blocks |
| `text-messages`           | `sms`                                     | SMS-style transcript with sender, timestamp, body columns; outbound messages tinted   |
| `browser-history`         | `search-history`                          | Tabular forensic extract with timestamp, type, query/URL, title/source columns        |
| `photo-log`               | `photos`, `evidence-photos`               | Chain-of-custody photo grid with optional images; placeholders when no path supplied  |
| `geofence-warrant`        |                                           | Structured geofence warrant attachment with lat/lon, radius, time window, optional map |
| `geofence-anonymized`     | `sensorvault-step1`, `sensorvault-step2`  | Sensorvault Step 1 / 2 per-device location-point table                                |
| `geofence-summary`        |                                           | Per-device aggregate of Sensorvault returns (first/last record, count, radii)         |
| `geofence-subscriber`     | `sensorvault-step3`                       | Sensorvault Step 3 subscriber-information / CSI per de-anonymized account             |
| `account-audit`           |                                           | Google audit record: numbered chronological event log with timestamps                 |
| `location-timeline`       | `maps-timeline`                           | Google Maps Timeline place visits, day-grouped                                        |
| `search-activity`         | `my-activity`                             | Google "My Activity" search & web feed, color-coded by source app                     |

### Meta records

```yaml
exhibit-type: meta-records
exhibit-starting-page: 1403
exhibit-records:
  - {author: "[Suspect A]", account: "100009604664543",
     sent: "2024-04-20 16:47:34 UTC",
     body: "Hey we can get the show on the road..."}
```

### Text messages

```yaml
exhibit-type: text-messages
exhibit-title: TEXT MESSAGE EXTRACT
exhibit-device: "Samsung Galaxy A10e — Serial #..."
exhibit-records:
  - {sender: "[Suspect A]", direction: out,
     timestamp: "2024-04-20 16:47", body: "..."}
```

`direction: out` tints the sender label blue; `direction: in` leaves
it gray. The optional `exhibit-device` line appears under the title
in italics.

### Browser history

```yaml
exhibit-type: browser-history
exhibit-title: BROWSER ACTIVITY EXTRACT
exhibit-records:
  - {timestamp: "2024-04-20 14:30", type: search,
     query: "...", source: "Chrome"}
  - {timestamp: "2024-04-20 14:33", type: visit,
     url: "https://...", title: "...", source: "Chrome"}
```

`type: search` shows the `query` field; `type: visit` (or `download`)
shows the `url`. The `title` field falls back to `source` when no
title is set.

### Photo log

```yaml
exhibit-type: photo-log
exhibit-title: PHYSICAL EVIDENCE PHOTO LOG
exhibit-columns: 2     # number of columns in the grid
exhibit-records:
  - {item-id: "1", path: "evidence/pill-bottle.jpg",
     description: "Pill bottle recovered from upstairs bathroom...",
     timestamp: "2024-04-29 14:30",
     photographer: "Det. B. Macklin"}
```

`path:` is optional. When a record omits it, the renderer drops in a
labeled placeholder rectangle so the grid still reads as a chain-of-
custody appendix even before real photos exist. `description` and
`caption` are interchangeable; `photographer` and `officer` are
interchangeable.

### Geofence warrant

A structured attachment for a Google Sensorvault geofence warrant.
Carries the time window, the lat/long center, the radius in meters,
a free-form narrative, and an optional aerial-view image.

```yaml
exhibit-type: geofence-warrant
exhibit-title: "GEOFENCE SEARCH WARRANT -- GOOGLE LLC"
geofence-window-start: "2024-04-22 16:20 EST"
geofence-window-end:   "2024-04-22 17:20 EST"
geofence-center:       "39.180835, -86.532128"
geofence-radius-m:     150
geofence-narrative: |
  This warrant applies to Google Accounts associated with devices
  located inside the geographical region listed during the time
  window above.
geofence-map-asset: ""   # optional path to an aerial-view image
```

When `geofence-map-asset` is empty the renderer drops in a labeled
placeholder rectangle so the layout reads as expected before a real
satellite image is supplied.

### Geofence anonymized (Sensorvault Step 1 / Step 2)

A multi-page tabular Google production: per-device location points
with anonymized device IDs, timestamps, lat/long, source (GPS /
WiFi / Cell), and Maps Display Radius. A Google-blue header bar
labels the production step.

```yaml
exhibit-type: geofence-anonymized
geofence-step: 1            # 1 or 2 (Step 2 = expanded ±30 min window)
geofence-window-start: "2024-04-22 16:20 EST"
geofence-window-end:   "2024-04-22 17:20 EST"
exhibit-records:
  - {device-id: "-2058716931", timestamp: "2024-04-22 16:30:01 UTC",
     latitude: 39.180812, longitude: -86.532145, source: "GPS",
     display-radius-m: 16}
  - {device-id: "-1844271119", timestamp: "2024-04-22 16:20:30 UTC",
     latitude: 39.180802, longitude: -86.532161, source: "WiFi",
     display-radius-m: 25}
```

`source` accepts any string but the renderer specifically expects
`"GPS"`, `"WiFi"`, or `"Cell"`. Aliases for `exhibit-type`:
`sensorvault-step1`, `sensorvault-step2`.

### Geofence summary

A per-device aggregate of the Sensorvault returns: one row per
anonymized device with first / last record times, total record
count, and the smallest / largest Maps Display Radius observed. A
"Grand Total" footer row sums the record counts.

```yaml
exhibit-type: geofence-summary
exhibit-title: "Summary of Records Received from Google"
exhibit-device: "Pawnee County Court, Case CR24-087"
exhibit-records:
  - {device-id: "-2058716931", first-record-time: "16:30:01",
     last-record-time: "17:19:45", record-count: 42,
     smallest-radius-m: 16, largest-radius-m: 45}
  - {device-id: "-1844271119", first-record-time: "16:20:30",
     last-record-time: "16:22:31", record-count: 25,
     smallest-radius-m: 25, largest-radius-m: 66}
```

### Geofence subscriber (Sensorvault Step 3)

Per-account subscriber-information blocks for the de-anonymized
devices. Each block carries the subscriber name, account number,
optional account-creation date, email addresses, device make /
model / IMEI, phone numbers, and an optional Google Voice number.

```yaml
exhibit-type: geofence-subscriber
exhibit-records:
  - subscriber-name: "[Suspect A]"
    account-number: "104871329500981"
    account-created: "2017-08-20"
    emails:
      - "suspect.a@gmail.com"
    device-make-model: "Samsung Galaxy S9+ (SM-G965U)"
    device-imei: "356938108472119"
    phone-numbers:
      - "+1 765 555 0173"
    google-voice: "+1 765 555 0418"
```

`emails` and `phone-numbers` accept either a YAML list or a
comma-separated string. Alias for `exhibit-type`:
`sensorvault-step3`.

### Account audit

A McGriff-style Google audit record for one Google account: a
numbered chronological log of account events (Account Created, LH
Enabled, Location Reporting Enabled, Device Associated, Device
Disassociated). Set `account-id` to display the subject account
identifier in the subtitle.

```yaml
exhibit-type: account-audit
exhibit-title: "Google LLC Audit Record"
account-id: "104871329500981"
exhibit-records:
  - timestamp: "2017-08-20 14:32:11 UTC"
    event: "Account Created"
    detail: "Subject Account created from IP 73.214.118.42."
  - timestamp: "2018-07-09 04:09:23 UTC"
    event: "LH Enabled (Sensorvault)"
    detail: |
      User opted in to Location History through a device-based
      consent flow.
    device-tag: "8174-2256-0431"
```

### Location timeline

The user-facing Google Maps Timeline / "Your places" export. Place
visits are grouped by date heading; each entry shows place name,
address, arrival and departure times, and an optional confidence
label.

```yaml
exhibit-type: location-timeline
exhibit-title: "Google Maps Timeline -- Place Visits"
exhibit-device: "Subject Account 104871329500981 -- Samsung Galaxy S9+"
exhibit-records:
  - {date: "2024-04-22", place-name: "Home",
     address: "1815 W. Sullivan Street, Pawnee, IN",
     arrival: "08:00", departure: "15:32", confidence: "High"}
  - {date: "2024-04-22", place-name: "Pawnee Federal Credit Union",
     address: "415 W. Sullivan Street, Pawnee, IN",
     arrival: "16:21", departure: "16:55", confidence: "High"}
```

Records sharing the same `date` are visually grouped; the
chronological order is preserved within each day. Alias for
`exhibit-type`: `maps-timeline`.

### Search activity

The Google "My Activity" feed from Google Takeout: a reverse-
chronological list of search queries, visited URLs, and app
actions, each tagged with a source app (Search, Chrome, Maps,
Assistant, ...). Each entry is colored by source app.

```yaml
exhibit-type: search-activity
exhibit-title: "Google My Activity -- Search & Browsing"
account-id: "104871329500981"
exhibit-records:
  - {timestamp: "2024-04-22 09:14", action: "Searched for",
     target: "Pawnee Federal Credit Union hours",
     source-app: "Search"}
  - {timestamp: "2024-04-22 09:18", action: "Visited",
     target: "https://pawneefcu.org/locations",
     source-app: "Chrome"}
  - {timestamp: "2024-04-22 14:05", action: "Used",
     target: "Navigated: Home to 415 W Sullivan St",
     source-app: "Maps"}
  - {timestamp: "2024-04-22 16:03", action: "Used",
     target: "Set timer: 15 minutes",
     source-app: "Assistant"}
```

`action` is a free-form verb phrase like `"Searched for"`,
`"Visited"`, `"Watched"`, or `"Used"`. `source-app` controls the
left-edge stripe color (Search blue, Chrome red, Maps green,
Assistant yellow). Alias for `exhibit-type`: `my-activity`.

## YAML metadata reference

Fields fall into four groups: jurisdiction (fixed across study),
personnel (fixed across study), per-case identifiers, and per-case
content. Every field has a default value; only the ones you want to
override need to appear in your `.qmd`.

### Jurisdiction (fixed)

| Field                  | Default                          | Used by                   |
| ---------------------- | -------------------------------- | ------------------------- |
| `state`                | `[Fictional State]`              | All caption blocks, headers |
| `county`               | `[Fictional County]`             | All caption blocks, headers |
| `city`                 | `[Fictional City]`               | District-court header line |
| `court-name`           | `[Fictional County Court]`       | Arrest-warrant header     |
| `judicial-district`    | `[Nth Judicial District]`        | Arrest-warrant header, judge title |

### Personnel (fixed)

| Field                       | Default                              | Used by                    |
| --------------------------- | ------------------------------------ | -------------------------- |
| `clerk-name`                | `[CLERK]`                            | Clerk filed-copy stamp     |
| `judge-name`                | `[Hon. Judge]`                       | Judge signature, arrest-warrant signing |
| `judge-title-full`          | `[County Judge — Nth District]`      | Search-warrant title block, arrest-warrant footer |
| `detective-name`            | `[Detective]`                        | Affiant identification, applicant block, arresting officer default |
| `detective-badge`           | `#000`                               | Hand-written badge mark above signatures |
| `detective-unit`            | `[Police Investigations Unit]`       | Affiant identification, applicant title, arresting officer title default |
| `detective-division`        | `[Police Division]`                  | Affidavit officer-identification paragraph |
| `detective-years`           | `0`                                  | Affidavit officer-identification paragraph |
| `notary-name`               | `[NOTARY]`                           | Return-and-inventory notary signature |
| `notary-commission-exp`     | `[Comm. Exp. Date]`                  | Notary stamp asset (built into image) |

### Per-case identifiers (variable)

| Field               | Default          | Used by                                  |
| ------------------- | ---------------- | ---------------------------------------- |
| `case-number`       | `[CR00-000]`     | Hand-written case number on every page   |
| `case-id-barcode`   | `[000000000]`    | Decorative barcode at bottom of affidavit page 1 |
| `filed-date`        | `[MMM DD YYYY]`  | Date stamp + parsed for fill-in fields   |
| `filed-time`        | `[H:MM]`         | Hand-written time inside FILED stamp     |
| `warrant-time`      | `[H:MM]`         | Search-warrant "AT __ O'CLOCK" fill-in   |
| `warrant-period`    | `DAYTIME`        | Search-warrant "served during" fill-in   |

The `filed-date` parses into day, month, and year for every fill-in
slot in the packet. Format: `MMM DD YYYY` (e.g. `AUG 12 2024`).

### Substantive content (variable)

| Field                  | Type              | Used by                                  |
| ---------------------- | ----------------- | ---------------------------------------- |
| `search-address`       | string            | Affidavit, search warrant, return        |
| `property-description` | multi-line string | Affidavit location block                 |
| `suspect-names`        | list of strings   | Affidavit custody block, return service note |
| `items-to-seize`       | list of strings   | Affidavit numbered list, search warrant command list |
| `narrative-paragraphs` | list of strings   | Affidavit grounds-for-issuance section   |
| `inventory-items`      | list of strings   | Return-and-inventory numbered list       |

### Arrest-warrant fields

| Field                       | Default                  | Purpose                                |
| --------------------------- | ------------------------ | -------------------------------------- |
| `defendant-name`            | `suspect-names[0]`       | Caption block, YOU ARE COMMANDED slot  |
| `charging-document-type`    | `complaint`              | Which checkbox is ticked (see below)   |
| `charges-description`       | `[]`                     | Multi-paragraph offense narrative      |
| `arrest-received-date`      | parsed `filed-date`      | Return box: warrant-received line      |
| `arrest-date`               | parsed `filed-date`      | Return box: arrest-on line + Date      |
| `arrest-location`           | `city, state`            | Return box: at-city-state line         |
| `arresting-officer-name`    | `detective-name`         | Return box: arresting officer signature |
| `arresting-officer-title`   | `detective-unit`         | Return box: printed name and title     |

Valid `charging-document-type` values: `complaint`, `indictment`,
`superseding-indictment`, `information`, `superseding-information`,
`probation-violation-petition`, `supervised-release-violation-petition`,
`violation-notice`, `order-of-the-court`.

### Exhibit fields

| Field                    | Type            | Notes                                       |
| ------------------------ | --------------- | ------------------------------------------- |
| `exhibit-type`           | string          | Selects renderer (see Exhibit types above)  |
| `exhibit-records`        | list of dicts   | Schema depends on `exhibit-type`            |
| `exhibit-description`    | multi-line str  | Attachment cover sheet paragraph            |
| `exhibit-starting-page`  | int             | Meta-records: starting page-number          |
| `exhibit-title`          | string          | Override the default title strip            |
| `exhibit-device`         | string          | Italic source-device line under the title   |
| `exhibit-columns`        | int             | Photo-log: grid column count (default 2)    |

### Asset overrides (rare)

By default, the stamps and seals reference the bundled assets at
`assets/seals/` and `assets/stamps/`. To swap in custom artwork (a
different jurisdiction's seal, say, or a study-specific notary
stamp), point the relevant asset field at your replacement file. All
paths are resolved from the user-project root after install.

| Field                          | Default                                                              |
| ------------------------------ | -------------------------------------------------------------------- |
| `clerk-stamp-asset`            | `_extensions/warrant-vignette/assets/seals/hartwell-county-court-clerk-stamp.svg` |
| `judge-seal-asset`             | `_extensions/warrant-vignette/assets/seals/hartwell-county-court-judge-seal.svg`  |
| `filed-stamp-asset`            | `_extensions/warrant-vignette/assets/stamps/filed-stamp.svg`         |
| `date-stamp-asset`             | `_extensions/warrant-vignette/assets/stamps/date-stamp.svg`          |
| `notary-stamp-asset`           | `_extensions/warrant-vignette/assets/stamps/notary-stamp-reilly.svg` |

## Maintaining the exhibit renderers

The four exhibit renderers (`meta-records`, `text-messages`,
`browser-history`, `photo-log`) are defined in two places that must
stay in sync:

- **Canonical source**: `typst/exhibits/*.typ` (one file per
  exhibit). Imported by `typst/lib.typ` for the standalone Typst
  rendering path.
- **Inlined copy**: a block inside `typst-template.typ` between the
  `// EXHIBITS-AUTO-START` and `// EXHIBITS-AUTO-END` markers. The
  Quarto path needs the definitions inlined because Quarto splices
  the template into the consumer project's root, where relative
  Typst imports do not resolve.

After editing any of the canonical files, regenerate the inlined
block through the
[warrantR R package](https://github.com/emmarshall/warrantR):

```r
library(warrantR)
build_exhibits()
```

`build_exhibits()` reads each `typst/exhibits/*.typ`, strips its
`merge-config` import (the template provides `merge-config` locally),
and replaces everything between the sentinels in
`typst-template.typ`. It is idempotent; re-running with no source
changes prints "No changes -- inlined block already up to date."

To add a **new exhibit type**:

1. Add a new file at `typst/exhibits/<your-type>.typ` following the
   shape of an existing one (top-level docstring, `#import` for
   `merge-config`, helpers, public function).
2. Register the new file name in the `.EXHIBIT_FILES` vector at the
   top of the warrantR package's `R/build_exhibits.R`.
3. Add an `#import` line in `typst/lib.typ` and a dispatch entry in
   `_exhibit-renderer()` so the standalone Typst path knows about it.
4. Add a dispatch arm to `exhibit()` in `typst-template.typ` (search
   for `if kind == "meta-records"`) so the Quarto path knows about it.
5. Run `build_exhibits()` to inline the new renderer.

## Photocopy post-processing (optional)

The Typst output is laser-print clean. For a stimulus that reads as a
photocopied legal document, run the Quarto-rendered PDF through the
warrantR package's photocopy pipeline:

```r
library(warrantR)
render_warrant(
  qmd_path = "test-warrant.qmd",
  output_pdf = "stim/test-warrant.pdf",
  output_pages_dir = "stim/test-warrant_pages",
  photocopy_level = "moderate",   # "clean" | "light" | "moderate" | "heavy"
  seed = 4747                     # reproducible aging
)
```

The pipeline rasterizes each page, applies a slight rotation, adds
Gaussian noise, compresses dynamic range, draws a left-edge binding
shadow, adds toner-drag streaks, optionally re-rasterizes for a
generation-2 photocopy look, and downsamples for online survey
display. Per-page PNG output is written next to the aged PDF for
embedding in Qualtrics.

## Per-condition customization

The intended workflow for a multi-condition study is one `.qmd` per
condition. Fixed jurisdiction and personnel fields can be pulled out
into a shared YAML include if desired. Example layout:

```
study/
├── _config/
│   └── jurisdiction.yaml      # state, county, judge, detective...
├── conditions/
│   ├── cond01_affidavit.qmd
│   ├── cond01_warrant.qmd
│   ├── cond02_affidavit.qmd
│   └── ...
└── stim/                      # rendered PDFs
```

Each `.qmd` references the shared config (Quarto supports
`metadata-files:` in the YAML header) and adds the per-condition
fields on top. Or, for batch generation, an R loop that templates
the YAML from a condition matrix CSV. See the `render_warrant()` and
`render_condition_matrix()` functions in `R/render_warrant.R`.

## Limitations and known caveats

- The Autograf signature font is freeware for personal use only.
  Check the included license file before using rendered packets in
  any commercial setting.
- The Code-39 style barcode at the bottom of the affidavit's first
  page is decorative. The bar pattern is seeded from the case-id
  string for reproducibility but does not validate as a real symbology
  and will not scan.
- Asset paths in the default config assume the post-`quarto add`
  install location. If the extension is referenced from a different
  directory, override the asset paths in YAML.
- The clerk-stamp rotation, signature placement offsets, and stamp
  positions are tuned visually; they may need adjustment if you
  change page margins or paper size.
- The photocopy post-processor is implemented but has not yet been
  exercised on a production stimulus set. Expect iteration on the
  realism-level presets when the first batch is generated.

## File reference

This extension contains only the Typst code, the Pandoc wrapper,
and the bundled visual assets. The R helpers (asset builders,
photocopy pipeline, batch render driver, exhibit-inliner) live in
the [warrantR R package](https://github.com/emmarshall/warrantR).

```
_extensions/warrant-vignette/
├── _extension.yml             # Quarto extension manifest
├── typst-template.typ         # consolidated Typst template for the Quarto path;
│                              # exhibit defs between the EXHIBITS-AUTO markers
│                              # are regenerated from typst/exhibits/, do not
│                              # edit by hand
├── typst-show.typ             # Pandoc template that calls article()
├── README.md                  # this file
├── example.qmd                # full-packet example
├── typst/                     # standalone Typst source (canonical exhibits)
│   ├── lib.typ                # standalone entry point: warrant-packet()
│   ├── partials/              # util, header, signature, notary, footer, ...
│   ├── docs/                  # affidavit, warrant, return, attachment
│   └── exhibits/              # CANONICAL: meta-records, text-messages,
│                              # browser-history, photo-log
└── assets/
    ├── seals/                 # round seals + clerk stamp
    ├── stamps/                # FILED stamp, date stamp, notary stamp
    └── fonts/Signature/       # bundled Autograf TTF
```

## License

The extension code is released under MIT. Bundled fonts and assets
carry their own licenses (see `assets/fonts/Signature/misc/` for
Autograf's terms). Confirm font licensing before publishing or
distributing rendered stimuli.
