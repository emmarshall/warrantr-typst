// Google Sensorvault anonymized location production (Step 1 / Step 2).
//
// Mimics the tabular per-device export Google returns in response to
// a geofence warrant: each row is one location point with anonymized
// device ID, timestamp, lat/long, source (GPS / WiFi / Cell), and
// the Maps Display Radius. A Google-branded header bar identifies
// the production step.
//
// Records: each record is a dict with keys
//   device-id   anonymized integer (str)
//   timestamp   YYYY-MM-DD HH:MM:SS UTC (str)
//   latitude    numeric or str
//   longitude   numeric or str
//   source      "GPS" | "WiFi" | "Cell" (str)
//   display-radius-m   numeric or str
//
// Config:
//   exhibit-title          override the default title
//   geofence-step          1 or 2 (default 1)
//   geofence-window-start  date/time string for the header banner
//   geofence-window-end    date/time string for the header banner
//
// CANONICAL SOURCE -- also inlined into ../typst-template.typ via
// R/build_exhibits.R. Edit here, then re-run that script.

#import "../partials/util.typ": merge-config

#let geofence-anonymized(user-config, records: ()) = {
  let cfg = merge-config(user-config)
  let step = cfg.at("geofence-step", default: 1)
  let title = cfg.at("exhibit-title",
    default: "Google LLC -- Geofence Production")
  let win-start = cfg.at("geofence-window-start", default: "")
  let win-end = cfg.at("geofence-window-end", default: "")

  set page(
    margin: (top: 0.55in, bottom: 0.6in, x: 0.55in),
    header: context {
      let n = counter(page).get().first()
      block(
        width: 100%,
        height: 0.36in,
        fill: rgb(26, 115, 232),  // Google blue
        inset: (x: 0.4in, y: 0.08in),
      )[
        #grid(
          columns: (1fr, auto),
          align: (left + horizon, right + horizon),
          text(white, weight: "bold", size: 11pt,
            title + " -- Step " + str(step)),
          text(white, weight: "bold", size: 10pt, "Page " + str(n)),
        )
      ]
    },
    header-ascent: 0pt,
    footer: context {
      let n = counter(page).get().first()
      let total = counter(page).final().first()
      block(
        width: 100%,
        inset: (top: 6pt),
        stroke: (top: 0.5pt + rgb(180, 180, 180)),
      )[
        #align(center,
          text(size: 8pt, fill: rgb(120, 120, 120), style: "italic",
            "Intellectual property of Google LLC. " +
            "Page " + str(n) + " of " + str(total) + "."))
      ]
    },
  )
  set text(font: ("Liberation Sans", "Helvetica Neue", "Helvetica", "Arial"),
    size: 8.5pt)
  set par(first-line-indent: 0em, leading: 0.4em, justify: false)

  v(0.15in)

  if win-start != "" or win-end != "" {
    block(below: 0.4em,
      text(size: 9pt, weight: "bold",
        "Time window: " + win-start +
          (if win-start != "" and win-end != "" { " to " } else { "" }) +
          win-end))
  }

  let _row-cells = records.map(r => (
    text(r.at("device-id", default: "[device-id]")),
    text(r.at("timestamp", default: "[YYYY-MM-DD HH:MM:SS UTC]")),
    text(str(r.at("latitude", default: "[lat]"))),
    text(str(r.at("longitude", default: "[long]"))),
    text(weight: "bold", upper(r.at("source", default: "[src]"))),
    align(right, text(str(r.at("display-radius-m", default: "[m]")))),
  )).flatten()

  table(
    columns: (1.05in, 1.45in, 0.85in, 0.95in, 0.55in, 0.7in),
    inset: (x: 5pt, y: 4pt),
    align: (x, y) => if y == 0 { center + horizon } else { left + top },
    stroke: (x, y) => (
      top: if y == 0 { 0.8pt + black }
           else if y == 1 { 0.5pt + black }
           else { 0.2pt + rgb(200, 200, 200) },
      bottom: none,
      left: none,
      right: none,
    ),
    fill: (x, y) => if y == 0 { rgb(232, 232, 232) }
                    else if calc.rem(y, 2) == 0 { rgb(248, 248, 248) }
                    else { none },

    table.header(
      text(weight: "bold", size: 8.5pt, "Device ID"),
      text(weight: "bold", size: 8.5pt, "Timestamp (UTC)"),
      text(weight: "bold", size: 8.5pt, "Latitude"),
      text(weight: "bold", size: 8.5pt, "Longitude"),
      text(weight: "bold", size: 8.5pt, "Source"),
      text(weight: "bold", size: 8.5pt, "Maps Disp. Radius (m)"),
    ),
    .._row-cells
  )
}
