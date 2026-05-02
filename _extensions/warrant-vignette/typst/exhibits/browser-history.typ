// Browser-history exhibit format.
//
// Mimics a forensic browser-activity export: a titled header band,
// then a four-column table showing timestamp, activity type
// (Search / Visit / Download), the search query or URL, and the page
// title or browser source. Searches and visits both flow through the
// same table so chronology is preserved.
//
// CANONICAL SOURCE — also inlined into ../typst-template.typ via
// R/build_exhibits.R. Edit here, then re-run that script.

#import "../partials/util.typ": merge-config

#let browser-history(user-config, records: ()) = {
  let cfg = merge-config(user-config)
  let title = cfg.at("exhibit-title", default: "BROWSER ACTIVITY EXTRACT")
  let device = cfg.at("exhibit-device", default: "")

  set page(
    margin: (top: 0.7in, bottom: 0.7in, x: 0.7in),
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
  set text(font: ("Liberation Sans", "Helvetica Neue", "Helvetica", "Arial"), size: 9.5pt)
  set par(first-line-indent: 0em, leading: 0.4em, justify: false)

  if device != "" {
    block(below: 0.6em, text(size: 9pt, style: "italic",
      fill: rgb(80, 80, 80),
      "Source device: " + device))
  }

  let _row-cells = records.map(r => {
    let ts = r.at("timestamp", default: "")
    let kind = upper(r.at("type", default: "visit"))
    let query-or-url = if r.at("type", default: "") == "search" {
      r.at("query", default: r.at("url", default: ""))
    } else {
      r.at("url", default: r.at("query", default: ""))
    }
    let title-or-source = r.at("title", default: r.at("source", default: ""))
    (
      text(size: 9pt, ts),
      text(size: 8.5pt, weight: "bold",
        fill: if r.at("type", default: "") == "search"
          { rgb(20, 80, 180) } else { rgb(40, 40, 40) },
        kind),
      text(size: 9pt, query-or-url),
      text(size: 9pt, fill: rgb(80, 80, 80), style: "italic", title-or-source),
    )
  }).flatten()

  table(
    columns: (1.3in, 0.7in, 1fr, 1.6in),
    inset: 6pt,
    align: (x, y) => (
      if y == 0 { center + horizon }
      else { left + top }
    ),
    stroke: (x, y) => (
      top: if y == 0 { 1pt + black }
           else if y == 1 { 0.5pt + black }
           else { 0.2pt + rgb(180, 180, 180) },
      bottom: none,
      left: none,
      right: none,
    ),
    fill: (x, y) => if y == 0 { rgb(232, 232, 232) } else { none },

    table.header(
      text(weight: "bold", size: 9pt, "Timestamp"),
      text(weight: "bold", size: 9pt, "Type"),
      text(weight: "bold", size: 9pt, "Query / URL"),
      text(weight: "bold", size: 9pt, "Title / Source"),
    ),
    .._row-cells
  )
}
