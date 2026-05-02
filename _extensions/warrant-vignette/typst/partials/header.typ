// Page header — the dense top-of-page region that sits above the body of
// every court document.
//
// In the source document, the header carries up to four overlapping
// pieces:
//   1. Top-left:  the corner FILED stamp with handwritten time, plus the
//                 mechanical date stamp and the multi-line "IN DISTRICT
//                 COURT OF / [STATE], [COUNTY]" text below.
//   2. Top-right: the rectangular clerk filed-copy stamp, slightly
//                 rotated.
//   3. Hand-written case number near the right margin.
//   4. The pleading caption block (state / )ss / county / title), drawn
//                 across the top below the stamps.
//
// All assets are referenced by path so the caller controls where they
// live on disk. The caller supplies a config dictionary built via
// util.typ#merge-config.

#import "util.typ": handwritten

#let _corner-filed-stamp(filed-stamp-asset, filed-time) = {
  // The FILED stamp asset has a pre-printed "FILED A.M. ___ P.M." with
  // an underline in the time slot. The handwritten time floats over the
  // underline.
  if filed-stamp-asset == "" {
    return
  }
  box(width: 1.7in, height: 0.7in)[
    #place(top + left, dx: 0pt, dy: 0pt, image(filed-stamp-asset, width: 1.7in))
    // Handwritten time: positioned roughly over the A.M. ___ P.M. line
    #place(top + left, dx: 0.55in, dy: 0.5in,
      handwritten(filed-time, size: 14pt, rotate-by: -2deg))
  ]
}

#let _date-stamp(date-stamp-asset, filed-date) = {
  // The date stamp asset has a "MMM DD YYYY" placeholder; we cover it
  // with a white box and overlay the real date.
  if date-stamp-asset == "" {
    return
  }
  box(width: 1.4in, height: 0.36in)[
    #image(date-stamp-asset, width: 1.4in)
    // White cover + real date overlay
    #place(top + left, dx: 0pt, dy: 0pt,
      rect(width: 1.4in, height: 0.36in, fill: white, stroke: none))
    #place(top + center, dy: 0.05in,
      text(font: "Liberation Sans", weight: "bold", size: 13pt, filed-date))
  ]
}

#let _clerk-stamp(clerk-stamp-asset, filed-date, rotation: -22deg) = {
  // Rectangular clerk's filed-copy stamp, slightly rotated. The asset
  // includes a date placeholder; we cover and overlay the same way the
  // date stamp does.
  if clerk-stamp-asset == "" {
    return
  }
  rotate(rotation, reflow: true,
    box(width: 2in, height: 0.95in)[
      #image(clerk-stamp-asset, width: 2in)
      // Cover the placeholder date row and overlay the real one. The
      // clerk stamp is 320 x 130 in its own native units; the date row
      // sits roughly at y = 88 (out of 130) which is ~68% down.
      #place(top + center, dy: 0.5in,
        rect(width: 1.7in, height: 0.22in, fill: white, stroke: none))
      #place(top + center, dy: 0.52in,
        text(font: "Liberation Sans", weight: "bold", size: 14pt, filed-date))
    ]
  )
}

#let _district-text(state, county) = {
  // The small "IN DISTRICT COURT OF / [COUNTY], [STATE]" block under
  // the corner FILED stamp. Slightly rotated in the source.
  rotate(-3deg, reflow: true,
    text(font: "Liberation Sans", size: 9pt, weight: "bold")[
      IN DISTRICT COURT OF \
      #upper(county), #upper(state)
    ]
  )
}

// Public: full page header. Produces an absolutely-positioned cluster
// of stamps and the caption block at the top of the page.
#let header-block(
  cfg,
  document-title: "AFFIDAVIT IN SUPPORT OF SEARCH WARRANT",
) = {
  // Position the corner FILED + date + district text in the top-left
  place(top + left, dx: 0in, dy: 0in,
    _corner-filed-stamp(cfg.filed-stamp-asset, cfg.filed-time))
  place(top + left, dx: 0.1in, dy: 0.85in,
    _date-stamp(cfg.date-stamp-asset, cfg.filed-date))
  place(top + left, dx: 0.05in, dy: 1.3in,
    _district-text(cfg.state, cfg.county))

  // Position the clerk filed-copy stamp in the top-right
  place(top + right, dx: 0in, dy: 0.05in,
    _clerk-stamp(cfg.clerk-stamp-asset, cfg.filed-date))

  // Handwritten case number — bottom right of the header zone
  place(top + right, dx: -0.1in, dy: 1.4in,
    handwritten(cfg.case-number, size: 22pt, rotate-by: -3deg))

  // Caption block — sits below the stamp cluster
  v(2.2in)
  // Caption is rendered by the document-type wrapper because the title
  // varies per document. We just reserve vertical space here.
}
