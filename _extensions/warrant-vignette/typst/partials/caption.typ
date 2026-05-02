// Caption block: the "STATE OF X / )ss / COUNTY OF Y" pleading caption
// that appears at the head of every court document.
//
// Layout (matching the source document):
//
//   STATE OF [STATE]      )
//                         ) ss:    [DOCUMENT TITLE]
//   COUNTY OF [COUNTY]    )
//
// The title is right-aligned alongside the parens column.

#let caption-block(
  state: "[STATE]",
  county: "[COUNTY]",
  title: "[DOCUMENT TITLE]",
  title-size: 14pt,
) = {
  // Three-column grid:
  //   col 1 — state / county labels (left)
  //   col 2 — three closing parens with "ss:" on the middle row
  //   col 3 — document title (right)
  grid(
    columns: (auto, auto, 1fr),
    column-gutter: 1em,
    align: (left + horizon, left + horizon, left + horizon),
    inset: (x: 0pt, y: 1pt),

    // row 1 — state label
    text(weight: "bold")[STATE OF #upper(state)],
    text()[\)],
    [],

    // row 2 — ss: + title (vertically centered between parens)
    [],
    text()[\) ss:],
    text(size: title-size, weight: "bold")[#upper(title)],

    // row 3 — county label
    text(weight: "bold")[COUNTY OF #upper(county)],
    text()[\)],
    [],
  )
}
