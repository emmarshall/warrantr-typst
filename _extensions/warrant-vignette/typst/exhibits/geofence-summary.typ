// Sensorvault per-device summary table.
//
// Mimics the "Summary of Records Received from Google" table that
// FBI CAST presentations include alongside the raw Sensorvault
// returns: one row per anonymized device with first/last record
// timestamps, total count, and the smallest / largest Maps Display
// Radius observed.
//
// Records: each record is a dict with keys
//   device-id            anonymized integer (str)
//   first-record-time    HH:MM:SS or full timestamp (str)
//   last-record-time     same format (str)
//   record-count         integer or str
//   smallest-radius-m    integer or str
//   largest-radius-m     integer or str
//
// CANONICAL SOURCE -- also inlined into ../typst-template.typ via
// R/build_exhibits.R. Edit here, then re-run that script.

#import "../partials/util.typ": merge-config

#let geofence-summary(user-config, records: ()) = {
  let cfg = merge-config(user-config)
  let title = cfg.at("exhibit-title",
    default: "Summary of Records Received from Google")
  let subtitle = cfg.at("exhibit-device", default: "")  // case header

  set page(margin: (top: 0.6in, bottom: 0.7in, x: 0.6in))
  set text(font: ("Liberation Sans", "Helvetica Neue", "Helvetica", "Arial"),
    size: 9.5pt)
  set par(first-line-indent: 0em, leading: 0.4em, justify: false)

  align(center, text(weight: "bold", size: 13pt, title))
  if subtitle != "" {
    v(0.2em)
    align(center, text(size: 10pt, style: "italic", subtitle))
  }
  v(0.4em)

  let totals-count = records.fold(0, (acc, r) => {
    let c = r.at("record-count", default: 0)
    acc + (if type(c) == int { c } else { 0 })
  })

  let _row-cells = records.map(r => (
    text(r.at("device-id", default: "[device-id]")),
    text(r.at("first-record-time", default: "[--]")),
    text(r.at("last-record-time", default: "[--]")),
    align(right, text(str(r.at("record-count", default: "[--]")))),
    align(right, text(str(r.at("smallest-radius-m", default: "[--]")))),
    align(right, text(str(r.at("largest-radius-m", default: "[--]")))),
  )).flatten()

  let total-row = (
    text(weight: "bold", "Grand Total"),
    text(""),
    text(""),
    align(right, text(weight: "bold", str(totals-count))),
    text(""),
    text(""),
  )

  table(
    columns: (1.4in, 1.3in, 1.3in, 0.95in, 1.05in, 1.05in),
    inset: (x: 6pt, y: 5pt),
    align: (x, y) => if y == 0 { center + horizon } else { left + top },
    stroke: (x, y) => (
      top: if y == 0 { 1pt + black }
           else if y == 1 { 0.5pt + black }
           else { 0.2pt + rgb(200, 200, 200) },
      bottom: none,
      left: none,
      right: none,
    ),
    fill: (x, y) => if y == 0 { rgb(232, 232, 232) } else { none },

    table.header(
      text(weight: "bold", size: 9pt, "Device ID"),
      text(weight: "bold", size: 9pt, "First Record"),
      text(weight: "bold", size: 9pt, "Last Record"),
      text(weight: "bold", size: 9pt, "Records"),
      text(weight: "bold", size: 9pt, "Smallest Radius (m)"),
      text(weight: "bold", size: 9pt, "Largest Radius (m)"),
    ),
    .._row-cells,
    ..total-row
  )
}
