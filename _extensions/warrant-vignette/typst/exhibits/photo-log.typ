// Photo-log exhibit format.
//
// Mimics a chain-of-custody photo appendix: a titled header strip, an
// optional case/officer line, then a grid of photo cells. Each cell
// holds an image (or a placeholder rectangle when no path is supplied)
// and a caption block with item ID, description, timestamp, and
// photographer.
//
// Records carry: item-id, path (optional), description, timestamp,
// photographer (or officer), caption (alternative description).
//
// CANONICAL SOURCE — also inlined into ../typst-template.typ via
// R/build_exhibits.R. Edit here, then re-run that script.

#import "../partials/util.typ": merge-config

#let _photo-cell(record) = {
  let item-id = record.at("item-id", default: "")
  let path = record.at("path", default: "")
  let description = record.at("description",
    default: record.at("caption", default: ""))
  let timestamp = record.at("timestamp", default: "")
  let photographer = record.at("photographer",
    default: record.at("officer", default: ""))

  block(breakable: false, below: 0.3in)[
    #if path != "" {
      image(path, width: 100%)
    } else {
      rect(
        width: 100%, height: 2.0in,
        fill: rgb(240, 240, 240),
        stroke: 0.5pt + rgb(180, 180, 180),
        align(center + horizon,
          text(fill: rgb(140, 140, 140), size: 10pt, style: "italic",
            "[ photo placeholder ]"))
      )
    }
    #v(0.4em)
    #if item-id != "" {
      text(weight: "bold", size: 10pt, "Item #" + item-id)
      h(0.4em)
    }
    #if description != "" {
      text(size: 9.5pt, description)
    }
    #linebreak()
    #if timestamp != "" or photographer != "" {
      text(size: 8.5pt, fill: rgb(100, 100, 100), style: "italic",
        timestamp +
          (if timestamp != "" and photographer != "" { " — " } else { "" }) +
          photographer)
    }
  ]
}

#let photo-log(user-config, records: ()) = {
  let cfg = merge-config(user-config)
  let title = cfg.at("exhibit-title", default: "PHYSICAL EVIDENCE PHOTO LOG")
  let device = cfg.at("exhibit-device", default: "")
  let cols = cfg.at("exhibit-columns", default: 2)

  set page(
    margin: (top: 0.7in, bottom: 0.7in, x: 0.8in),
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
  set text(font: ("Liberation Sans", "Helvetica Neue", "Helvetica", "Arial"), size: 10pt)
  set par(first-line-indent: 0em, leading: 0.45em, justify: false)

  if device != "" {
    block(below: 0.6em, text(size: 9pt, style: "italic",
      fill: rgb(80, 80, 80),
      "Custodian: " + device))
  }

  grid(
    columns: (1fr,) * cols,
    column-gutter: 0.3in,
    row-gutter: 0.2in,
    ..records.map(_photo-cell)
  )
}
