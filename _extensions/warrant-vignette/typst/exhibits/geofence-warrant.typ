// Geofence warrant attachment.
//
// Mimics the structured "Geographical Area" attachment that
// accompanies a Google Sensorvault geofence warrant: a centered
// title, a labeled time-window line, a labeled lat/long + radius
// line, a brief narrative paragraph, and an optional aerial-view
// image with the geofence circle drawn on top.
//
// Records: not used by this renderer (the data lives in
// exhibit-level config fields, not in `exhibit-records`).
//
// CANONICAL SOURCE -- also inlined into ../typst-template.typ via
// R/build_exhibits.R. Edit here, then re-run that script.

#import "../partials/util.typ": merge-config

#let geofence-warrant(user-config, records: ()) = {
  let cfg = merge-config(user-config)
  let title = cfg.at("exhibit-title",
    default: "GEOFENCE SEARCH WARRANT -- GOOGLE LLC")
  let geo-center = cfg.at("geofence-center", default: "[Lat, Long]")
  let radius = cfg.at("geofence-radius-m", default: "[N]")
  let win-start = cfg.at("geofence-window-start", default: "[YYYY-MM-DD HH:MM]")
  let win-end = cfg.at("geofence-window-end", default: "[YYYY-MM-DD HH:MM]")
  let narrative = cfg.at("geofence-narrative", default: "")
  let map-asset = cfg.at("geofence-map-asset", default: "")

  set page(margin: (top: 0.7in, bottom: 0.7in, x: 0.85in))
  set text(font: ("Liberation Serif", "Times New Roman", "Times"), size: 11pt)
  set par(first-line-indent: 0em, leading: 0.55em, justify: false)

  align(center, text(weight: "bold", size: 13pt, title))
  v(0.3in)

  block(below: 0.6em)[
    #grid(
      columns: (1.6in, 1fr),
      column-gutter: 8pt,
      row-gutter: 6pt,

      text(weight: "bold", "Date / Time:"),
      [#win-start to #win-end],

      text(weight: "bold", "Geographical Area:"),
      [Radius of #radius meters around lat/long coordinate #geo-center],
    )
  ]

  if narrative != "" {
    v(0.3em)
    block(width: 100%, narrative)
  }

  if map-asset != "" {
    v(0.5em)
    align(center, image(map-asset, width: 5in))
  } else {
    v(0.5em)
    align(center,
      rect(
        width: 5in, height: 3.2in,
        fill: rgb(240, 240, 240),
        stroke: 0.5pt + rgb(180, 180, 180),
        align(center + horizon,
          text(fill: rgb(140, 140, 140), size: 10pt, style: "italic",
            "[ aerial-view map of geofence area ]"))
      ))
  }
}
