// Google Maps Timeline location export.
//
// Mimics the user-facing "Your places / Your timeline" export from
// Google Maps: a chronological list of place visits, each showing
// the place name, address, arrival and departure times, and an
// optional confidence label. Entries are grouped by date heading.
//
// Records: each record is a dict with keys
//   date         YYYY-MM-DD (str) -- used to group into day sections
//   place-name   (str)
//   address      (str)
//   arrival      HH:MM (str)
//   departure    HH:MM (str)
//   confidence   "High" | "Medium" | "Low" (str, optional)
//
// CANONICAL SOURCE -- also inlined into ../typst-template.typ via
// R/build_exhibits.R. Edit here, then re-run that script.

#import "../partials/util.typ": merge-config

#let _timeline-entry(record) = {
  let place = record.at("place-name", default: "[Place]")
  let addr = record.at("address", default: "")
  let arr = record.at("arrival", default: "[--:--]")
  let dep = record.at("departure", default: "[--:--]")
  let conf = record.at("confidence", default: "")

  block(below: 0.7em, above: 0.2em, breakable: false,
        inset: (left: 0.4in))[
    #grid(
      columns: (1fr, auto),
      column-gutter: 12pt,

      block[
        #text(weight: "bold", size: 11pt, place)
        #if addr != "" [
          \
          #text(size: 9.5pt, fill: rgb(100, 100, 100), addr)
        ]
      ],
      block(width: 1.4in)[
        #align(right, text(size: 9.5pt,
          font: ("Liberation Mono", "Menlo", "Courier New"),
          arr + " -- " + dep))
        #if conf != "" [
          #linebreak()
          #align(right, text(size: 8pt, fill: rgb(120, 120, 120),
            style: "italic", conf + " confidence"))
        ]
      ],
    )
  ]
}

#let location-timeline(user-config, records: ()) = {
  let cfg = merge-config(user-config)
  let title = cfg.at("exhibit-title",
    default: "Google Maps Timeline -- Place Visits")
  let device = cfg.at("exhibit-device", default: "")

  set page(
    margin: (top: 0.7in, bottom: 0.7in, x: 0.85in),
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
  set text(font: ("Liberation Sans", "Helvetica Neue", "Helvetica", "Arial"),
    size: 10pt)
  set par(first-line-indent: 0em, leading: 0.45em, justify: false)

  if device != "" {
    block(below: 0.6em, text(size: 9pt, style: "italic",
      fill: rgb(80, 80, 80),
      "Source: " + device))
  }

  // Group entries by date and emit a date heading before each group.
  let prev-date = ""
  for record in records {
    let d = record.at("date", default: "")
    if d != "" and d != prev-date {
      v(0.4em)
      block(below: 0.4em,
        text(weight: "bold", size: 12pt, fill: rgb(26, 115, 232), d))
      align(left, line(length: 100%, stroke: 0.5pt + rgb(200, 200, 200)))
      v(0.2em)
      prev-date = d
    }
    _timeline-entry(record)
  }
}
