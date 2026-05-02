// Utility helpers shared across the warrant-vignette partials.
//
// Most of these handle small layout chores that come up repeatedly:
// padding metadata defaults, normalizing date strings, and a typed
// dictionary merge.

#let default-config = (
  // Jurisdiction (fixed across study)
  state: "[Fictional State]",
  county: "[Fictional County]",
  city: "[Fictional City]",
  court-name: "[Fictional County Court]",
  judicial-district: "[Nth Judicial District]",

  // Personnel (fixed across study)
  clerk-name: "[CLERK]",
  judge-name: "[Hon. Judge]",
  judge-title-full: "[County Judge — Nth District]",
  detective-name: "[Detective]",
  detective-badge: "#000",
  detective-unit: "[Police Investigations Unit]",
  detective-division: "[Police Division]",
  detective-years: 0,
  notary-name: "[NOTARY]",
  notary-commission-exp: "[Comm. Exp. Date]",

  // Asset paths. Resolved relative to the file containing the
  // image() call — which is always one of the partials in this
  // directory. From `partials/`, `../../assets/...` walks up to the
  // extension root and into `assets/`. This works in both standalone
  // and Quarto-installed contexts.
  clerk-stamp-asset: "../../assets/seals/hartwell-county-court-clerk-stamp.svg",
  judge-seal-asset: "../../assets/seals/hartwell-county-court-judge-seal.svg",
  filed-stamp-asset: "../../assets/stamps/filed-stamp.svg",
  date-stamp-asset: "../../assets/stamps/date-stamp.svg",
  notary-stamp-asset: "../../assets/stamps/notary-stamp-reilly.svg",
  detective-signature-asset: "../../assets/signatures/sig-hayes.png",
  judge-signature-asset: "../../assets/signatures/sig-patterson.png",
  notary-signature-asset: "../../assets/signatures/sig-reilly.png",

  // Per-case content (overridden per condition)
  case-number: "[CR00-000]",
  case-id-barcode: "[000000000]",
  filed-date: "[MMM DD YYYY]",
  filed-time: "[H:MM]",
  warrant-time: "[H:MM]",
  warrant-period: "DAYTIME",
  search-address: "[address redacted]",
  property-description: "[building description]",
  suspect-names: ("[Suspect A]",),
  items-to-seize: (),
  narrative-paragraphs: (),
  inventory-items: (),
  exhibit-description: "",
)

// Merge a user-supplied config dictionary onto the defaults so callers
// only have to pass the fields that vary by condition.
#let merge-config(user-config) = {
  let cfg = default-config
  for (k, v) in user-config {
    cfg.insert(k, v)
  }
  cfg
}

// A handwritten-looking text fragment. Used for case numbers, fill-in
// dates, and other slots where the source document has hand-written
// content.
//
// `family` defaults to "Caveat" with serif italic fallback so the
// document still renders if Caveat is not installed.
#let handwritten(text-content, size: 14pt, rotate-by: 0deg) = {
  set text(
    font: ("Caveat", "Liberation Serif"),
    style: "italic",
    weight: "regular",
    size: size,
  )
  if rotate-by == 0deg {
    text-content
  } else {
    rotate(rotate-by, text-content)
  }
}

// Fill-in line: a horizontal underline with optional handwritten content
// centered above it. Used in the warrant time/date blanks.
#let fill-in(content, width: 1in, size: 11pt) = {
  box(width: width)[
    #align(center, handwritten(content, size: size))
    #v(-0.4em)
    #line(length: 100%)
  ]
}
