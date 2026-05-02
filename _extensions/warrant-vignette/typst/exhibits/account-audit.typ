// Google account audit record (McGriff-declaration style).
//
// Mimics the Sensorvault audit record served alongside subpoena
// returns: a numbered chronological log of account events
// (Account Created, LH Enabled, Location Reporting Enabled, Device
// Associated, Device Disassociated). Each entry has a UTC
// timestamp, an event type, and an optional descriptive blurb.
//
// Records: each record is a dict with keys
//   timestamp     YYYY-MM-DD HH:MM:SS UTC (str)
//   event         short event name, e.g. "LH Enabled" (str)
//   detail        optional one-line explanation (str)
//   device-tag    optional device identifier (str)
//
// Config:
//   exhibit-title         default "Google LLC Audit Record"
//   account-id            subject account ID shown in subtitle
//
// CANONICAL SOURCE -- also inlined into ../typst-template.typ via
// R/build_exhibits.R. Edit here, then re-run that script.

#import "../partials/util.typ": merge-config

#let _audit-row(record, idx) = {
  let ts = record.at("timestamp", default: "[YYYY-MM-DD HH:MM:SS UTC]")
  let ev = record.at("event", default: "[event]")
  let dt = record.at("detail", default: "")
  let tag = record.at("device-tag", default: "")

  block(below: 0.55em, above: 0.2em, breakable: false)[
    #grid(
      columns: (0.4in, 1.6in, 1fr),
      column-gutter: 6pt,
      row-gutter: 2pt,

      align(right, text(weight: "bold", str(idx) + ".")),
      text(font: ("Liberation Mono", "Menlo", "Courier New"), size: 9pt, ts),
      text(weight: "bold", ev),
    )
    #if dt != "" or tag != "" {
      block(inset: (left: 2.05in, top: 2pt))[
        #if dt != "" [#text(size: 9.5pt, dt)]
        #if tag != "" [
          #linebreak()
          #text(size: 9pt, fill: rgb(100, 100, 100),
            "Device tag: " + tag)
        ]
      ]
    }
  ]
}

#let account-audit(user-config, records: ()) = {
  let cfg = merge-config(user-config)
  let title = cfg.at("exhibit-title",
    default: "Google LLC Audit Record")
  let account = cfg.at("account-id", default: "")

  set page(margin: (top: 0.7in, bottom: 0.7in, x: 0.85in))
  set text(font: ("Liberation Serif", "Times New Roman", "Times"), size: 11pt)
  set par(first-line-indent: 0em, leading: 0.5em, justify: false)

  align(center, text(weight: "bold", size: 13pt, title))
  if account != "" {
    v(0.2em)
    align(center, text(size: 10pt, style: "italic",
      "Subject Account: " + account))
  }
  v(0.4em)
  align(center, line(length: 60%, stroke: 0.5pt))
  v(0.5em)

  for (i, record) in records.enumerate() {
    _audit-row(record, i + 1)
  }
}
