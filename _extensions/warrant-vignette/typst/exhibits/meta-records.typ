// Meta Platforms Business Record exhibit format.
//
// Mimics the layout of the Facebook / Messenger business-record export:
// a solid black header bar runs across the top of every page with white
// "Meta Platforms Business Record" text on the left and the page number
// on the right. Below the bar, a stack of message records each formatted
// as
//
//   Author  [Display Name] (Facebook: [account-id])
//      Sent  YYYY-MM-DD HH:MM:SS UTC
//      Body  [message text]
//
// Each record block sits with the field labels in bold and the values
// in regular weight, with a consistent left indent.
//
// CANONICAL SOURCE — also inlined into ../typst-template.typ via
// R/build_exhibits.R. Edit here, then re-run that script.

#import "../partials/util.typ": merge-config

// Single record block.
#let _meta-record-block(record) = {
  let author = record.at("author", default: "[Author]")
  let account = record.at("account", default: "[account-id]")
  let sent = record.at("sent", default: "[YYYY-MM-DD HH:MM:SS UTC]")
  let body = record.at("body", default: "")

  block(below: 1.1em, above: 0.2em, breakable: false)[
    #grid(
      columns: (0.7in, 1fr),
      column-gutter: 6pt,
      row-gutter: 4pt,

      align(right, text(weight: "bold", "Author")),
      [#author #h(0.4em) (Facebook: #account)],

      align(right, text(weight: "bold", "Sent")),
      sent,

      align(right, text(weight: "bold", "Body")),
      body,
    )
  ]
}

// Public: full Meta records exhibit. Renders one or more pages with
// the black header bar and a stack of message records.
//
// `records` is an array of dictionaries, each with keys:
//   author (str), account (str), sent (str), body (str)
#let meta-records(user-config, records: ()) = {
  let cfg = merge-config(user-config)
  let starting-page = cfg.at("exhibit-starting-page", default: 1403)

  set page(
    margin: (top: 0.6in, bottom: 0.6in, x: 1in),
    header: context {
      let n = counter(page).get().first()
      block(
        width: 100%,
        height: 0.32in,
        fill: black,
        inset: (x: 0.4in, y: 0.07in),
      )[
        #grid(
          columns: (1fr, auto),
          align: (left + horizon, right + horizon),
          text(white, weight: "bold", size: 11pt, "Meta Platforms Business Record"),
          text(white, weight: "bold", size: 11pt,
            "Page " + str(starting-page + n - 1)),
        )
      ]
    },
    header-ascent: 0pt,
  )

  set text(font: ("Liberation Sans", "Helvetica Neue", "Helvetica", "Arial"), size: 10.5pt)
  set par(first-line-indent: 0em, leading: 0.5em)

  v(0.2in)

  for record in records {
    _meta-record-block(record)
  }
}
