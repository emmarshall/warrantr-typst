// Signature blocks — a horizontal underline with a signature image
// floating on top of it, plus the typed name and title underneath.
//
// Three variations show up across the source document:
//
//   1. Detective signature on the affidavit page — signature, name,
//      unit on two lines.
//   2. Subscribed-and-sworn block with handwritten day/month/year and
//      the judge's signature with the round seal beside it.
//   3. Return-and-inventory signature with separate "Title" line that
//      is hand-written.

#import "util.typ": handwritten, fill-in

// Public: detective's signature block (used on affidavit page).
#let detective-signature(
  signature-asset: "",
  name: "Detective",
  unit: "Police Investigations Unit",
  badge: "",
  width: 3.2in,
) = {
  align(right, box(width: width)[
    #if signature-asset != "" {
      place(top + right, dx: 0.4in, dy: -0.3in,
        rotate(-2deg, image(signature-asset, width: 2.6in)))
    }
    #if badge != "" {
      place(top + right, dx: 0in, dy: -0.1in,
        handwritten(badge, size: 14pt))
    }
    #v(0.6in)
    #line(length: 100%)
    #align(center, [
      #name \
      #unit
    ])
  ])
}

// Public: judge's signature block. Includes the round judge seal as a
// stamp beside the signature.
#let judge-signature(
  signature-asset: "",
  seal-asset: "",
  title: "Judge",
  width: 3.5in,
) = {
  align(right, box(width: width)[
    #if signature-asset != "" {
      place(top + right, dx: -0.6in, dy: -0.3in,
        rotate(-3deg, image(signature-asset, width: 2.4in)))
    }
    #if seal-asset != "" {
      place(top + right, dx: 0in, dy: -0.4in,
        rotate(8deg, image(seal-asset, width: 1.05in)))
    }
    #v(0.7in)
    #line(length: 100% - 1.2in)
    #h(0.05in)
    #title
  ])
}

// Public: subscribed-and-sworn line with handwritten day/month/year.
// Fitting "_15th_ day of _June_, 2022" with the date pieces in
// handwritten style.
#let subscribed-and-sworn(day: "", month: "", year: "") = {
  let two-digit-year = if year != "" and year.len() >= 4 {
    year.slice(2)
  } else {
    year
  }
  [
    SUBSCRIBED AND SWORN to before me on this
    #fill-in(day, width: 0.6in)
    day of
    #fill-in(month, width: 1in)
    , 20#fill-in(two-digit-year, width: 0.4in)
  ]
}

// Public: return-and-inventory applicant block — handwritten title
// below the signature line, and a "Subscribed and sworn to me on"
// line with handwritten date.
#let applicant-block(
  signature-asset: "",
  title-text: "DETECTIVE — POLICE DEPT.",
  subscribed-date: "",
  badge: "",
  signature-width: 2.6in,
) = {
  align(left, box(width: 5in)[
    #if signature-asset != "" {
      place(top + left, dx: 0.2in, dy: -0.3in,
        rotate(-2deg, image(signature-asset, width: signature-width)))
    }
    #if badge != "" {
      place(top + left, dx: 2.7in, dy: -0.1in,
        handwritten(badge, size: 14pt))
    }
    #v(0.6in)
    #line(length: 4in)
    #text(size: 10pt, "Signature of applicant")

    #v(0.45in)
    #handwritten(title-text, size: 18pt)
    #v(-0.1em)
    #line(length: 4in)
    #text(size: 10pt, "Title")

    #v(0.3in)
    SUBSCRIBED AND SWORN to me on
    #fill-in(subscribed-date, width: 1.6in, size: 14pt)
    , 20#h(0.05in)
  ])
}
