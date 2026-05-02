// Page-footer pieces.
//
// The source affidavit shows a Code 39-style barcode at the bottom of
// page 1 only, with a numeric case identifier underneath. The bars are
// decorative — the pattern doesn't have to validate as a real symbology
// — but the widths are seeded from the case id so the same id always
// produces the same barcode.

// Map each character to a sequence of bar widths.
//   0 = narrow black bar
//   1 = wide black bar
//   2 = narrow white space
//   3 = wide white space
#let _bar-pattern(ch) = {
  let patterns = (
    "0": (0, 2, 1, 3, 0, 2, 0, 2, 0),
    "1": (1, 2, 0, 3, 0, 2, 0, 2, 1),
    "2": (0, 2, 1, 3, 0, 2, 0, 2, 1),
    "3": (1, 2, 1, 3, 0, 2, 0, 2, 0),
    "4": (0, 2, 0, 3, 1, 2, 0, 2, 1),
    "5": (1, 2, 0, 3, 1, 2, 0, 2, 0),
    "6": (0, 2, 1, 3, 1, 2, 0, 2, 0),
    "7": (0, 2, 0, 3, 0, 2, 1, 2, 1),
    "8": (1, 2, 0, 3, 0, 2, 1, 2, 0),
    "9": (0, 2, 1, 3, 0, 2, 1, 2, 0),
    "A": (1, 2, 0, 2, 0, 3, 0, 2, 1),
    "B": (0, 2, 1, 2, 0, 3, 0, 2, 1),
    "C": (1, 2, 1, 2, 0, 3, 0, 2, 0),
    "D": (0, 2, 0, 2, 1, 3, 0, 2, 1),
    "E": (1, 2, 0, 2, 1, 3, 0, 2, 0),
    "F": (0, 2, 1, 2, 1, 3, 0, 2, 0),
  )
  let key = upper(ch)
  if key in patterns { patterns.at(key) } else { (0, 2, 0, 2, 0, 2, 0, 2, 0) }
}

// Build the full bar sequence (including a small inter-character gap)
// for a given case-id string.
#let _build-bars(case-id) = {
  let bars = ()
  for ch in case-id {
    for v in _bar-pattern(ch) {
      bars.push(v)
    }
    // narrow inter-char gap
    bars.push(2)
  }
  bars
}

// Public: render the case-id as a decorative barcode plus its numeric
// label underneath. Intended for the bottom-right of the affidavit's
// first page.
#let case-barcode(case-id: "000000000", width: 2.6in, height: 0.5in) = {
  let bars = _build-bars(case-id)
  let unit-widths = bars.map(v => if calc.rem(v, 2) == 1 { 2.4 } else { 1.0 })
  let total-units = unit-widths.sum()
  // Compute cumulative x offset for each bar so we can place them with
  // absolute positions.
  let offsets = ()
  let cumulative = 0.0
  for w in unit-widths {
    offsets.push(cumulative)
    cumulative = cumulative + w
  }
  let scale = width / (total-units * 1pt)

  align(right + bottom, stack(dir: ttb, spacing: 3pt,
    box(width: width, height: height)[
      #for i in range(bars.len()) {
        let v = bars.at(i)
        let is-bar = v < 2
        let bar-w = unit-widths.at(i) * 1pt * scale
        let x = offsets.at(i) * 1pt * scale
        if is-bar {
          place(top + left, dx: x, dy: 0pt,
            rect(width: bar-w, height: height, fill: black, stroke: none))
        }
      }
    ],
    align(center, text(font: "Liberation Mono", size: 9pt, case-id)),
  ))
}
