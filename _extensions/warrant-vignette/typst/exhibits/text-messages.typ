// Text-message exhibit format.
//
// Mimics a forensic SMS / iMessage extract: a titled header strip
// followed by chronological message rows. Each row carries sender
// (phone or contact name), timestamp, direction (out / in), and
// message body. Outbound messages have a tinted sender label so the
// conversation reads like a transcript.
//
// CANONICAL SOURCE — also inlined into ../typst-template.typ via
// R/build_exhibits.R. Edit here, then re-run that script.

#import "../partials/util.typ": merge-config

#let _sms-row(record) = {
  let sender = record.at("sender", default: "[+1-555-0100]")
  let direction = lower(record.at("direction", default: "out"))
  let timestamp = record.at("timestamp", default: "[YYYY-MM-DD HH:MM]")
  let body = record.at("body", default: "")

  let sender-color = if direction == "out" {
    rgb(20, 80, 180)
  } else {
    rgb(30, 30, 30)
  }

  block(below: 0.7em, above: 0.2em, breakable: false)[
    #grid(
      columns: (1.4in, 1.4in, 1fr),
      column-gutter: 8pt,
      row-gutter: 2pt,
      align: (left + top, left + top, left + top),

      text(weight: "bold", size: 10pt, fill: sender-color, sender),
      text(size: 9pt, fill: rgb(90, 90, 90), timestamp),
      text(size: 10pt, body),
    )
  ]
}

#let text-messages(user-config, records: ()) = {
  let cfg = merge-config(user-config)
  let title = cfg.at("exhibit-title", default: "TEXT MESSAGE EXTRACT")
  let device = cfg.at("exhibit-device", default: "")

  set page(
    margin: (top: 0.7in, bottom: 0.7in, x: 0.9in),
    header: context {
      let n = counter(page).get().first()
      block(
        width: 100%,
        inset: (bottom: 6pt),
        stroke: (bottom: 1pt + black),
      )[
        #grid(
          columns: (1fr, auto),
          align: (left + horizon, right + horizon),
          text(weight: "bold", size: 10pt, title),
          text(size: 9pt, "Page " + str(n)),
        )
      ]
    },
    header-ascent: 0.15in,
  )
  set text(font: ("Liberation Sans", "Helvetica Neue", "Helvetica", "Arial"), size: 10.5pt)
  set par(first-line-indent: 0em, leading: 0.45em, justify: false)

  // Optional device line under the header
  if device != "" {
    block(below: 0.6em, text(size: 9pt, style: "italic",
      fill: rgb(80, 80, 80),
      "Device: " + device))
  }

  // Column header row
  block(below: 0.4em,
    grid(
      columns: (1.4in, 1.4in, 1fr),
      column-gutter: 8pt,
      align: (left, left, left),
      text(weight: "bold", size: 9pt, "Sender"),
      text(weight: "bold", size: 9pt, "Timestamp"),
      text(weight: "bold", size: 9pt, "Message"),
    )
  )
  line(length: 100%, stroke: 0.5pt + rgb(150, 150, 150))
  v(0.3em)

  for record in records {
    _sms-row(record)
  }
}
