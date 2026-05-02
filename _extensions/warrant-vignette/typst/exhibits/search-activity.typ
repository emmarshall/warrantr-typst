// Google My Activity: search and web feed.
//
// Mimics the user-facing "My Activity" export from Google Takeout:
// a reverse-chronological feed of search queries, visited URLs, and
// app actions, each with a timestamp and source-app badge. The
// styling intentionally echoes the My Activity HTML export rather
// than the forensic browser-history table (which is a separate
// exhibit-type, `browser-history`).
//
// Records: each record is a dict with keys
//   timestamp     YYYY-MM-DD HH:MM (str)
//   action        "Searched for" | "Visited" | "Watched" | "Used" (str)
//   target        the query string, URL, or item name (str)
//   source-app    "Search" | "Chrome" | "Maps" | "Assistant" | ... (str)
//
// CANONICAL SOURCE -- also inlined into ../typst-template.typ via
// R/build_exhibits.R. Edit here, then re-run that script.

#import "../partials/util.typ": merge-config

#let _activity-entry(record) = {
  let ts = record.at("timestamp", default: "[YYYY-MM-DD HH:MM]")
  let action = record.at("action", default: "Searched for")
  let target = record.at("target", default: "[query]")
  let app = record.at("source-app", default: "Search")

  let app-color = if app == "Search" { rgb(66, 133, 244) }
                  else if app == "Chrome" { rgb(234, 67, 53) }
                  else if app == "Maps" { rgb(52, 168, 83) }
                  else if app == "Assistant" { rgb(251, 188, 5) }
                  else { rgb(120, 120, 120) }

  block(below: 0.55em, above: 0.2em, breakable: false,
        stroke: (left: 2pt + app-color),
        inset: (left: 8pt, top: 3pt, bottom: 3pt))[
    #grid(
      columns: (1fr, auto),
      column-gutter: 10pt,
      align: (left + top, right + top),

      block[
        #text(size: 9.5pt, fill: rgb(80, 80, 80), action + ": ")
        #text(weight: "bold", target)
      ],
      block(width: 0.9in)[
        #align(right,
          text(size: 8pt, weight: "bold", fill: app-color, upper(app)))
      ],
    )
    #v(0.1em)
    #text(size: 8.5pt, fill: rgb(120, 120, 120),
      font: ("Liberation Mono", "Menlo", "Courier New"), ts)
  ]
}

#let search-activity(user-config, records: ()) = {
  let cfg = merge-config(user-config)
  let title = cfg.at("exhibit-title",
    default: "Google My Activity -- Search & Browsing")
  let account = cfg.at("account-id", default: "")

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

  if account != "" {
    block(below: 0.6em, text(size: 9pt, style: "italic",
      fill: rgb(80, 80, 80),
      "Account: " + account))
  }

  for record in records {
    _activity-entry(record)
  }
}
