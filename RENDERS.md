# Render options

Each `.qmd` file in this directory renders a different subset of the
warrant packet. Pick the one matching what you need; render with
`quarto render <file>.qmd`.

## Document examples

| File                       | Output                                              | Pages |
| -------------------------- | --------------------------------------------------- | ----- |
| `affidavit-only.qmd`       | Affidavit in Support of Search Warrant              | 2--3  |
| `warrant-only.qmd`         | Search Warrant                                      | 1     |
| `arrest-warrant-only.qmd`  | Arrest Warrant (AO 442 form style)                  | 1     |
| `return-only.qmd`          | Return and Inventory                                | 1     |
| `test-warrant.qmd`         | Full packet (affidavit + attachment + exhibit + warrant + return) | all |

## Exhibit examples

Each renders the attachment cover sheet plus one exhibit type.

| File                                  | `exhibit-type`         | Format                                                |
| ------------------------------------- | ---------------------- | ----------------------------------------------------- |
| `exhibit-only.qmd`                    | `text-messages`        | SMS / iMessage transcript                             |
| `exhibit-browser.qmd`                 | `browser-history`      | Forensic browser / search-history table               |
| `exhibit-photos.qmd`                  | `photo-log`            | Chain-of-custody photo grid                           |
| `exhibit-geofence-warrant.qmd`        | `geofence-warrant`     | Geofence warrant attachment (lat/lon, radius, window) |
| `exhibit-geofence-anonymized.qmd`     | `geofence-anonymized`  | Sensorvault Step 1 / 2 anonymized location table      |
| `exhibit-geofence-summary.qmd`        | `geofence-summary`     | Per-device aggregate summary of Sensorvault returns   |
| `exhibit-geofence-subscriber.qmd`     | `geofence-subscriber`  | Sensorvault Step 3 subscriber-info / CSI return       |
| `exhibit-account-audit.qmd`           | `account-audit`        | Google audit record of LH opt-in / device events      |
| `exhibit-location-timeline.qmd`       | `location-timeline`    | Google Maps Timeline place visits, day-grouped        |
| `exhibit-search-activity.qmd`         | `search-activity`      | Google "My Activity" search & web feed                |

## Customizing

Each `.qmd` is YAML-only with no body content. To change what gets
rendered, edit the values in the YAML header:

- **What documents appear**: `document-types` list. Valid values:
  `affidavit`, `attachment`, `exhibit`, `warrant` (search warrant),
  `arrest-warrant`, `return`. Order matters; documents render in the
  order listed.
- **Exhibit format**: `exhibit-type` controls which exhibit renderer
  fires. Built-in formats:
  - `meta-records` (or `facebook-messages`): Author / Sent / Body
    records under a black "Meta Platforms Business Record" header bar.
  - `text-messages` (or `sms`): sender / timestamp / body rows with
    outbound messages tinted; optional `exhibit-device` field for the
    source-device line under the title.
  - `browser-history` (or `search-history`): tabular timestamp /
    type / query-or-URL / title-or-source extract; searches are
    tinted blue, visits and downloads are gray.
  - `photo-log` (or `photos`, `evidence-photos`): chain-of-custody
    grid with image cells captioned by item ID, description,
    timestamp, and photographer. Leave `path:` blank in any record
    to render a labeled placeholder rectangle. `exhibit-columns`
    sets grid width (default 2).
  - `geofence-warrant`: structured warrant attachment with
    `geofence-window-start`, `geofence-window-end`,
    `geofence-center` (lat,long), `geofence-radius-m`,
    `geofence-narrative`, and optional `geofence-map-asset`.
  - `geofence-anonymized` (or `sensorvault-step1`,
    `sensorvault-step2`): per-device location-point table
    (`device-id`, `timestamp`, `latitude`, `longitude`, `source`,
    `display-radius-m`) with a Google-blue header bar. `geofence-step`
    selects 1 or 2 in the title.
  - `geofence-summary`: aggregate table with one row per device
    (`device-id`, `first-record-time`, `last-record-time`,
    `record-count`, `smallest-radius-m`, `largest-radius-m`).
  - `geofence-subscriber` (or `sensorvault-step3`): subscriber-info
    blocks per de-anonymized account (`subscriber-name`,
    `account-number`, `emails`, `device-make-model`, `device-imei`,
    `phone-numbers`, `google-voice`).
  - `account-audit`: numbered chronological event log with
    `timestamp`, `event`, `detail`, optional `device-tag`. Set
    `account-id` for the subtitle.
  - `location-timeline` (or `maps-timeline`): Google Maps Timeline
    place visits with `date`, `place-name`, `address`, `arrival`,
    `departure`, optional `confidence`. Records are grouped under
    the `date` heading.
  - `search-activity` (or `my-activity`): Google My Activity feed
    with `timestamp`, `action`, `target`, `source-app`. Each entry
    is colored by source app (Search blue, Chrome red, Maps green,
    Assistant yellow).
- **Per-case content**: case-number, filed-date, suspect-names,
  search-address, items-to-seize, narrative-paragraphs,
  inventory-items, exhibit-records. These vary per condition.
- **Fixed jurisdiction / personnel**: state, county, city,
  court-name, clerk-name, judge-name, detective-name, etc. Hold
  these constant across the study unless you're testing a
  jurisdiction effect.

## Batch generation

Once the layout is locked in, the
[warrantR R package](https://github.com/emmarshall/warrantR) wraps
`quarto render` and applies the photocopy effect. Install it once:

```r
install.packages("pak")
pak::pak("emmarshall/warrantR")
```

Then drive the rendering loop from any R session:

```r
library(warrantR)

render_warrant(
  qmd_path = "affidavit-only.qmd",
  output_pdf = "stim/cond01_affidavit.pdf",
  output_pages_dir = "stim/cond01_affidavit_pages",
  photocopy_level = "moderate",
  seed = 4747
)
```

For multi-condition rendering, see `?warrantr::render_condition_matrix`.
