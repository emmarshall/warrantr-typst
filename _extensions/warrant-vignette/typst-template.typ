// Warrant Vignette — consolidated Quarto Typst template.
//
// The bulk of the Typst code lives in this one file because Quarto's
// template-partials mechanism splices the template into the generated
// .typ file at the project root, where relative imports do not resolve
// the way they would in a standalone Typst project. Consolidating
// most of the code here side-steps the import maze.
//
// The exhibit renderers (meta-records, text-messages, browser-history,
// photo-log) are the one exception: they have CANONICAL sources at
// typst/exhibits/*.typ that are also imported by typst/lib.typ for the
// standalone Typst path. The block between the EXHIBITS-AUTO-START and
// EXHIBITS-AUTO-END markers below is regenerated from those files by
// R/build_exhibits.R. Do not edit that block by hand — edit the
// canonical sources and re-run the script.
//
// Public entry point: article — Quarto calls this with the .qmd's
// YAML metadata pulled into named arguments. The body of the .qmd is
// ignored; the metadata IS the document.

// ===========================================================================
// 1. Configuration defaults + helpers
// ===========================================================================

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

  // Asset paths. Use Quarto's project-root-relative `/`-prefix so the
  // paths resolve correctly regardless of where the .qmd sits in the
  // project tree (e.g., `posts/SMA-F/warrant.qmd` two levels deep).
  clerk-stamp-asset: "/_extensions/warrant-vignette/assets/seals/carter-county-court-clerk-stamp.svg",
  judge-seal-asset: "/_extensions/warrant-vignette/assets/seals/carter-county-court-judge-seal.svg",
  filed-stamp-asset: "/_extensions/warrant-vignette/assets/stamps/filed-stamp.svg",
  date-stamp-asset: "/_extensions/warrant-vignette/assets/stamps/date-stamp.svg",
  notary-stamp-asset: "/_extensions/warrant-vignette/assets/stamps/notary-stamp-doyle.svg",
  detective-signature-asset: "/_extensions/warrant-vignette/assets/signatures/sig-hayes.png",
  judge-signature-asset: "/_extensions/warrant-vignette/assets/signatures/sig-patterson.png",
  notary-signature-asset: "/_extensions/warrant-vignette/assets/signatures/sig-reilly.png",

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
  // When non-empty, load exhibit-records from this YAML file
  // instead of from inline `exhibit-records:` metadata. Workaround
  // for Pandoc/Quarto's typst-writer dropping nested-dict contents
  // for some record schemas. Path is resolved relative to the
  // generated .typ file (same dir as the source .qmd).
  exhibit-records-file: "",
  // Geofence / Sensorvault / Google-data exhibit fields. Used by
  // geofence-warrant, geofence-anonymized, geofence-summary,
  // geofence-subscriber, account-audit, location-timeline,
  // search-activity. Defaults are placeholders.
  geofence-center: "",
  geofence-radius-m: "",
  geofence-window-start: "",
  geofence-window-end: "",
  geofence-narrative: "",
  geofence-map-asset: "",
  geofence-step: 1,
  account-id: "",
  // Multi-exhibit support. When `exhibits` is a non-empty list,
  // each `attachment` and each `exhibit` in document-types is paired
  // with the corresponding entry by index (attachments and exhibits
  // are numbered separately, but in a typical packet they alternate
  // 1:1). Each entry is a dict with optional keys: exhibit-type,
  // exhibit-title, exhibit-device, exhibit-description,
  // exhibit-records, exhibit-columns, exhibit-starting-page.
  // When `exhibits` is empty (the legacy case), the top-level
  // exhibit-* fields above are used and a single attachment + single
  // exhibit can render. This keeps older warrant.qmd files working
  // unchanged.
  exhibits: (),
)

// Pandoc's typst writer escapes special characters and converts
// em-dashes to triple hyphens and non-breaking spaces to tilde.
// Those substitutions are correct for Typst CONTENT mode but they
// leak as literal characters when the values land inside string
// contexts. Strip them before the rest of the library uses the
// values. (Dollar and backtick are avoided in this file because
// Quarto runs Pandoc on the template.)
#let _dollar = str.from-unicode(36)
#let _unescape-string(s) = {
  if type(s) != str { return s }
  s.replace("\\[", "[")
   .replace("\\]", "]")
   .replace("\\#", "#")
   .replace("\\_", "_")
   .replace("\\" + _dollar, _dollar)
   .replace("\\*", "*")
   .replace("\\\\", "\\")
   .replace("---", "—")
   .replace("--", "–")
   .replace("~", " ")
}

#let _unescape(value) = {
  if type(value) == str {
    _unescape-string(value)
  } else if type(value) == array {
    value.map(_unescape)
  } else if type(value) == dictionary {
    let cleaned = (:)
    for (k, v) in value { cleaned.insert(k, _unescape(v)) }
    cleaned
  } else {
    value
  }
}

#let merge-config(user-config) = {
  let cfg = default-config
  for (k, v) in user-config {
    cfg.insert(k, _unescape(v))
  }
  cfg
}

#let handwritten(text-content, size: 14pt, rotate-by: 0deg) = {
  set text(
    // Liberation Serif italic is the canonical pilot02 look for
    // handwritten fill-ins. Times New Roman is the always-available
    // fallback on macOS / Windows. The italic style is forced
    // because that's what carries the visual "filled in by hand"
    // quality on the rendered warrant; without it the fill-ins
    // read as printed text.
    font: ("Liberation Serif", "Times New Roman", "Times"),
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

#let fill-in(content, width: 1in, size: 11pt) = {
  box(width: width)[
    #align(center, handwritten(content, size: size))
    #v(-0.4em)
    #line(length: 100%)
  ]
}

// Parse a filed-date string like "AUG 12 2024" into day/month/year.
// Returns (day: "12", month: "August", year: "2024", year-2: "24")
// for use in the SUBSCRIBED AND SWORN fill-in.
#let _parse-filed-date(date-str) = {
  if type(date-str) != str or date-str.len() == 0 {
    return (day: "", month: "", year: "", year-2: "")
  }
  let parts = date-str.split(" ").filter(p => p.len() > 0)
  if parts.len() < 3 {
    return (day: "", month: "", year: "", year-2: "")
  }
  let month-abbr = upper(parts.at(0))
  let day = parts.at(1)
  let year = parts.at(2)
  let month-map = (
    "JAN": "January", "FEB": "February", "MAR": "March", "APR": "April",
    "MAY": "May", "JUN": "June", "JUL": "July", "AUG": "August",
    "SEP": "September", "OCT": "October", "NOV": "November", "DEC": "December",
  )
  let month-full = month-map.at(month-abbr, default: month-abbr)
  let year-2 = if year.len() >= 4 { year.slice(2) } else { year }
  (day: day, month: month-full, year: year, year-2: year-2)
}

// Strip common title prefixes from a name so the signature shows only
// the personal-name portion. "Detective J. Hayes" -> "J. Hayes",
// "Hon. R. Patterson" -> "R. Patterson", "M. Doyle" -> "M. Doyle".
#let _signing-name(full-name) = {
  let prefixes = (
    "Detective ", "Det. ",
    "Officer ", "Off. ",
    "Sergeant ", "Sgt. ",
    "Lieutenant ", "Lt. ",
    "Captain ", "Cpt. ", "Capt. ",
    "Hon. ", "Honorable ", "Judge ",
    "Mr. ", "Mrs. ", "Ms. ", "Dr. ",
  )
  for prefix in prefixes {
    if full-name.starts-with(prefix) {
      return full-name.slice(prefix.len())
    }
  }
  full-name
}

// Render a typed name as a stylized handwritten signature.
//
// Primary font: Autograf — a handwriting-style script bundled in the
// extension at assets/fonts/Signature/. Install it system-wide before
// rendering (drag the .ttf into Font Book on macOS, or copy to
// ~/.fonts on Linux and run fc-cache).
#let signature-text(name, size: 24pt, color: rgb(20, 20, 60)) = {
  set text(
    // Autograf is bundled in assets/fonts/Signature/ — install it
    // system-wide so Typst can find it (drag the .ttf into Font Book
    // on macOS, or copy to ~/.fonts on Linux and run fc-cache).
    // Bradley Hand is a macOS-default handwritten font that matches
    // the script style if Autograf hasn't been installed yet.
    font: (
      "Autograf PERSONAL USE ONLY",
      "Bradley Hand",
      "Caveat",
    ),
    style: "italic",
    weight: "regular",
    size: size,
    fill: color,
  )
  _signing-name(name)
}

// ===========================================================================
// 2. Caption block (state / )ss / county)
// ===========================================================================

// When `state` is non-empty, emit the conventional "STATE OF X"
// caption left-side. When empty, emit "STATE COURT" — the canonical
// pilot02 convention for affidavits with an intentionally
// unspecified state (see pilot02_warrant_affidavit_scenarios.qmd §3).
// Also catches the default-config placeholder "[Fictional State]"
// which leaks through when Pandoc's conditional-block templating
// filters out an explicit empty `state: ""` from the YAML before
// the value reaches typst-show.typ. (Pandoc syntax tokens are
// avoided in this comment because Quarto runs Pandoc on this file.)
#let _caption-state-line(state) = {
  if state == none or state == "" or state == "[Fictional State]" {
    [STATE COURT]
  } else {
    [STATE OF #upper(state)]
  }
}

// "COUNTY OF CARTER COUNTY" is awkwardly redundant. Strip a trailing
// " County" / " county" before the template prepends "COUNTY OF".
// YAML keeps the natural `Carter County` form so prose rendering
// elsewhere (e.g., "Millfield, Carter County") stays correct.
#let _caption-county-line(county) = {
  let trimmed = if county.ends-with(" County") {
    county.slice(0, county.len() - " County".len())
  } else if county.ends-with(" county") {
    county.slice(0, county.len() - " county".len())
  } else {
    county
  }
  [COUNTY OF #upper(trimmed)]
}

#let caption-block(
  state: "[STATE]",
  county: "[COUNTY]",
  title: "[DOCUMENT TITLE]",
  title-size: 14pt,
) = {
  grid(
    columns: (auto, auto, 1fr),
    column-gutter: 1em,
    align: (left + horizon, left + horizon, left + horizon),
    inset: (x: 0pt, y: 1pt),

    text(weight: "bold", _caption-state-line(state)),
    text()[\)],
    [],

    [],
    text()[\) ss:],
    text(size: title-size, weight: "bold")[#upper(title)],

    text(weight: "bold", _caption-county-line(county)),
    text()[\)],
    [],
  )
}

// ===========================================================================
// 3. Page header — stamp cluster
// ===========================================================================

#let _corner-filed-stamp(filed-stamp-asset, filed-time) = {
  if filed-stamp-asset == "" {
    return
  }
  box(width: 1.7in, height: 0.7in)[
    #place(top + left, dx: 0pt, dy: 0pt, image(filed-stamp-asset, width: 1.7in))
    #place(top + left, dx: 0.55in, dy: 0.5in,
      handwritten(filed-time, size: 14pt, rotate-by: -2deg))
  ]
}

#let _date-stamp(date-stamp-asset, filed-date) = {
  if date-stamp-asset == "" {
    return
  }
  box(width: 1.4in, height: 0.36in)[
    #image(date-stamp-asset, width: 1.4in)
    #place(top + left, dx: 0pt, dy: 0pt,
      rect(width: 1.4in, height: 0.36in, fill: white, stroke: none))
    #place(top + center, dy: 0.05in,
      text(font: ("Liberation Sans", "Helvetica Neue", "Helvetica", "Arial"), weight: "bold", size: 13pt, filed-date))
  ]
}

#let _clerk-stamp(clerk-stamp-asset, filed-date, rotation: -22deg) = {
  if clerk-stamp-asset == "" {
    return
  }
  rotate(rotation, reflow: true,
    box(width: 2in, height: 0.95in)[
      #image(clerk-stamp-asset, width: 2in)
      #place(top + center, dy: 0.5in,
        rect(width: 1.7in, height: 0.22in, fill: white, stroke: none))
      #place(top + center, dy: 0.52in,
        text(font: ("Liberation Sans", "Helvetica Neue", "Helvetica", "Arial"), weight: "bold", size: 14pt, filed-date))
    ]
  )
}

#let _district-text(state, county) = {
  let state-empty = state == none or state == "" or state == "[Fictional State]"
  let line2 = if state-empty { upper(county) } else { upper(county) + ", " + upper(state) }
  rotate(-3deg, reflow: true,
    text(font: ("Liberation Sans", "Helvetica Neue", "Helvetica", "Arial"), size: 9pt, weight: "bold")[
      IN COUNTY COURT OF \
      #line2
    ]
  )
}

// Returns the stamp-cluster content suitable for `set page(header: ...)`.
// Renders the corner FILED stamp, the date stamp, the district-court
// text, the rotated clerk filed-copy stamp, and the handwritten case
// number — all positioned absolutely. Use as a per-page header so the
// stamps repeat on every page of the document.
//
// `with-clerk-stamp` toggles the rotated clerk filed-copy stamp in
// the top-right. Set to false on the return-and-inventory page,
// which carries a "Case #" label instead.
#let make-page-header(cfg, with-clerk-stamp: true) = {
  block(width: 100%, height: 2.0in, breakable: false)[
    #place(top + left, dx: 0in, dy: 0in,
      _corner-filed-stamp(cfg.filed-stamp-asset, cfg.filed-time))
    #place(top + left, dx: 0.1in, dy: 0.85in,
      _date-stamp(cfg.date-stamp-asset, cfg.filed-date))
    #place(top + left, dx: 0.05in, dy: 1.3in,
      _district-text(cfg.state, cfg.county))

    #if with-clerk-stamp {
      place(top + right, dx: 0in, dy: 0.05in,
        _clerk-stamp(cfg.clerk-stamp-asset, cfg.filed-date))
    } else {
      // Return page substitutes a typed "Case #" label
      place(top + right, dx: -0.1in, dy: 0.05in,
        text(size: 12pt, weight: "bold", "Case #" + cfg.case-number))
    }

    #place(top + right, dx: -0.1in, dy: 1.4in,
      handwritten(cfg.case-number, size: 22pt, rotate-by: -3deg))
  ]
}

// Backward-compatible flow-content version. Some callers still want
// to emit the header inline (e.g. when the page header is set to
// something else). Currently unused but kept for flexibility.
#let header-block(
  cfg,
  document-title: "AFFIDAVIT IN SUPPORT OF SEARCH WARRANT",
) = {
  make-page-header(cfg)
}

// ===========================================================================
// 4. Signature blocks
// ===========================================================================

#let detective-signature(
  signature-asset: "",
  name: "Detective",
  unit: "Police Investigations Unit",
  badge: "",
  width: 3.2in,
) = {
  align(right, box(width: width)[
    // Signature centred over the underline, slightly above it
    #place(top + right, dx: -0.3in, dy: 0.05in,
      rotate(-3deg, signature-text(name, size: 26pt)))
    #if badge != "" {
      place(top + right, dx: -0.05in, dy: 0.1in,
        handwritten(badge, size: 14pt))
    }
    #v(0.5in)
    #line(length: 100%)
    #align(center, [
      #name \
      #unit
    ])
  ])
}

#let judge-signature(
  signature-asset: "",
  seal-asset: "",
  name: "Judge",
  title: "Judge",
  width: 3.5in,
) = {
  align(right, box(width: width)[
    #place(top + right, dx: -1.4in, dy: 0.1in,
      rotate(-3deg, signature-text(name, size: 24pt)))
    #if seal-asset != "" {
      place(top + right, dx: 0in, dy: -0.1in,
        rotate(8deg, image(seal-asset, width: 1.05in)))
    }
    #v(0.6in)
    #line(length: 100% - 1.2in)
    #h(0.05in)
    #title
  ])
}

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

#let applicant-block(
  signature-asset: "",
  name: "Detective",
  title-text: "DETECTIVE — POLICE DEPT.",
  subscribed-date: "",
  badge: "",
  signature-width: 2.6in,
) = {
  align(left, box(width: 5in)[
    #place(top + left, dx: 0.4in, dy: -0.3in,
      rotate(-3deg, signature-text(name, size: 30pt)))
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

// ===========================================================================
// 5. Notary block
// ===========================================================================

#let notary-block(
  signature-asset: "",
  stamp-asset: "",
  name: "Notary",
  width: 5in,
) = {
  align(left, box(width: width)[
    #place(top + left, dx: 0.6in, dy: -0.2in,
      rotate(-2deg, signature-text(name, size: 26pt)))
    #v(0.5in)
    #line(length: 4in)

    #h(0.1in)
    #strike[Judge or] Notary Public
    #v(0.1in)

    #if stamp-asset != "" {
      align(right,
        rotate(-2deg, reflow: true,
          image(stamp-asset, width: 2.6in)))
    }
  ])
}

// ===========================================================================
// 6. Footer barcode
// ===========================================================================

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

#let _build-bars(case-id) = {
  let bars = ()
  for ch in case-id {
    for v in _bar-pattern(ch) {
      bars.push(v)
    }
    bars.push(2)
  }
  bars
}

#let case-barcode(case-id: "000000000", width: 2.6in, height: 0.5in) = {
  let bars = _build-bars(case-id)
  let unit-widths = bars.map(v => if calc.rem(v, 2) == 1 { 2.4 } else { 1.0 })
  let total-units = unit-widths.sum()
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
    align(center, text(font: ("Liberation Mono", "Menlo", "Courier New", "Courier"), size: 9pt, case-id)),
  ))
}

// ===========================================================================
// 7. Court documents
// ===========================================================================

#let _items-list-strong(items) = {
  set par(first-line-indent: 0em)
  enum(
    indent: 0.5in,
    body-indent: 0.5em,
    spacing: 0.4em,
    ..items.map(it => strong(it))
  )
}

#let _narrative(paragraphs) = {
  // Emit each entry as its own paragraph so the surrounding `set par`
  // first-line-indent applies. block() would suppress the indent.
  for para in paragraphs {
    par(first-line-indent: 0.25in, para)
    v(0.5em)
  }
}

#let affidavit(user-config) = {
  let cfg = merge-config(user-config)

  // Repeat the stamp cluster on every page of the affidavit. Top
  // margin is bumped to make room for the header band.
  set page(
    margin: (top: 2.2in, bottom: 0.7in, x: 0.85in),
    header: make-page-header(cfg),
    header-ascent: 0.3in,
  )

  // Reserve space for the case-id barcode at the bottom-right of
  // page 1. `float: true` makes Typst reserve the area in flow so
  // body text breaks above it instead of running through it.
  if cfg.case-id-barcode != "" {
    place(bottom + right, scope: "parent", float: true,
      clearance: 0.4em,
      case-barcode(case-id: cfg.case-id-barcode))
  }

  caption-block(
    state: cfg.state,
    county: cfg.county,
    title: "AFFIDAVIT IN SUPPORT OF SEARCH WARRANT",
    title-size: 13pt,
  )
  v(0.4em)

  // Opening — wording matches canonical pilot02 boilerplate
  // (pilot02_warrant_affidavit_scenarios.qmd §3). Empty cfg.state is
  // suppressed so phrases like "Carter County, " (with no state) and
  // "the State Statutes" (no possessive state) read as written. When
  // a state IS specified, the older form ", X State" / "of the X
  // State Statutes" comes back.
  let _state-empty = cfg.state == none or cfg.state == "" or cfg.state == "[Fictional State]"
  let _state-suffix = if _state-empty { "" } else { ", " + cfg.state }
  let _state-statutes-prefix = if _state-empty {
    "the State Statutes"
  } else {
    "the " + cfg.state + " State Statutes"
  }

  let _d = _parse-filed-date(cfg.filed-date)
  [
    The affidavit of the undersigned on this
    #fill-in(_d.day, width: 0.6in)
    day of
    #fill-in(_d.month, width: 1.1in)
    , #fill-in(_d.year, width: 0.8in)
    , who being first duly sworn, upon oath says:

    #v(0.4em)
    That I am a certified law enforcement officer with the
    #cfg.detective-division, #cfg.city, #cfg.county#_state-suffix,
    and have been employed by the #cfg.detective-division
    as a law enforcement officer for #cfg.detective-years years.
    My duties include the investigation of criminal violations of
    #_state-statutes-prefix.
  ]
  v(0.5em)

  // Items intro — matches canonical wording, including the explicit
  // 72-hour pre/post window the affidavit asks the magistrate to
  // authorize. Canonical text:
  //   "That I am investigating the circumstances surrounding a
  //    pregnancy loss that occurred at the below-described location.
  //    Based on the facts set forth in this affidavit, I have
  //    probable cause to believe that evidence relevant to this
  //    investigation is kept and concealed at the described
  //    premises, specifically, for the period from seventy-two (72)
  //    hours prior to the pregnancy loss through seventy-two (72)
  //    hours following the pregnancy loss:"
  [
    That I am investigating the circumstances surrounding a pregnancy
    loss that occurred at the below-described location. Based on the
    facts set forth in this affidavit, I have probable cause to
    believe that evidence relevant to this investigation is kept and
    concealed at the described premises, specifically, for the period
    from seventy-two (72) hours prior to the pregnancy loss through
    seventy-two (72) hours following the pregnancy loss:

    #_items-list-strong(cfg.items-to-seize)
  ]
  v(0.4em)

  // Location. property-description is optional; when empty, just
  // the search-address renders.
  let _location-line = if cfg.property-description == none or cfg.property-description == "" {
    cfg.search-address
  } else {
    cfg.search-address + ". " + cfg.property-description
  }
  [
    That this property is concealed or kept in or about the following
    described place:

    #v(0.4em)
    #par(first-line-indent: 0em, hanging-indent: 0.5in,
      [*1. * #strong(underline(_location-line))]
    )

    #v(0.4em)
    That the property is under the custody or control of:
    #strong(cfg.suspect-names.join(", "))
  ]
  v(0.4em)

  // Grounds
  [
    That the grounds for issuance of the search warrant are as follows:

    #v(0.4em)
    #_narrative(cfg.narrative-paragraphs)
  ]

  v(2em)
  strong[WHEREFORE, affiant prays that a search warrant be issued.]

  v(0.7in)
  detective-signature(
    signature-asset: cfg.detective-signature-asset,
    name: cfg.detective-name,
    unit: cfg.detective-unit,
    badge: cfg.detective-badge,
  )

  v(0.4in)
  let _d = _parse-filed-date(cfg.filed-date)
  subscribed-and-sworn(day: _d.day, month: _d.month, year: _d.year)

  v(0.4in)
  judge-signature(
    signature-asset: cfg.judge-signature-asset,
    seal-asset: cfg.judge-seal-asset,
    name: cfg.judge-name,
    title: cfg.judge-name,
  )
}

#let _command-list(items) = {
  set par(first-line-indent: 0em)
  enum(
    indent: 0.5in,
    body-indent: 0.5em,
    spacing: 0.4em,
    ..items.map(it => [Any and all #it])
  )
}

#let warrant-doc(user-config) = {
  let cfg = merge-config(user-config)

  set page(
    margin: (top: 2.2in, bottom: 0.7in, x: 0.85in),
    header: make-page-header(cfg),
    header-ascent: 0.3in,
  )

  caption-block(
    state: cfg.state,
    county: cfg.county,
    title: "SEARCH WARRANT",
    title-size: 16pt,
  )
  v(0.4em)

  [
    *TO:* #cfg.detective-name of the #cfg.detective-division and other
    officers under his supervision.
  ]
  v(0.5em)

  let _d = _parse-filed-date(cfg.filed-date)
  [
    THIS MATTER came on for hearing on the
    #fill-in(_d.day, width: 0.5in) day of
    #fill-in(_d.month, width: 1in) , #fill-in(_d.year, width: 0.6in)
    , upon the sworn affidavit for issuance of a Search Warrant, and
    the Court, being fully advised in the premises finds as follows:
  ]
  v(0.4em)

  [That the Court has jurisdiction in this matter.]
  v(0.4em)

  [
    That based upon the sworn affidavit for issuance of a Search
    Warrant by #cfg.detective-unit Detective #cfg.detective-name, dated
    #fill-in(_d.month + " " + _d.day + ", " + _d.year, width: 1.8in)
    , that there is probable cause and grounds for the issuance of
    this Search Warrant.
  ]
  v(0.4em)

  [
    *You are therefore commanded*, with necessary and proper
    assistance, to search the following person(s) or place(s):
  ]
  v(0.3em)

  par(first-line-indent: 0em, hanging-indent: 0.5in,
    [*1.* #strong(underline(cfg.search-address))]
  )
  v(0.3em)

  [for the purpose of discovering and seizing the following, to wit:]
  v(0.3em)

  _command-list(cfg.items-to-seize)
  v(0.3em)

  [
    And, if found, to seize and deal with the same as provided by
    law, and to make return of this warrant to me within ten days
    after the date hereof.
  ]
  v(0.5em)

  [This warrant shall be served during the #fill-in(cfg.warrant-period, width: 1.6in) .]
  v(0.4em)

  [
    DATED THIS #fill-in(_d.day, width: 0.5in) DAY OF
    #fill-in(_d.month, width: 1.1in) , #fill-in(_d.year, width: 0.6in) .
  ]
  v(0.3em)

  let split-time = if "warrant-time" in cfg and cfg.warrant-time != none {
    cfg.warrant-time
  } else { "" }
  let am-pm = if cfg.warrant-period == "DAYTIME" { "P" } else { "A" }
  // .M. sits flush against the fill-in box — real warrant forms
  // print "____.M." with no whitespace gap so the participant just
  // writes "A" or "P" in front of the period. The `text[.M.]` wrapper
  // prevents Typst from parsing `.M` as field access on the
  // preceding fill-in() return value.
  [
    AT #fill-in(split-time, width: 0.8in) O'CLOCK #fill-in(am-pm, width: 0.4in)#text[.M.]
  ]

  v(0.7in)

  judge-signature(
    signature-asset: cfg.judge-signature-asset,
    seal-asset: cfg.judge-seal-asset,
    name: cfg.judge-name,
    title: "Signature of Judge",
  )

  v(0.4in)
  align(right, box(width: 3.5in)[
    #handwritten(cfg.judge-title-full, size: 14pt)
    #v(-0.1em)
    #line(length: 100%)
    #h(0.05in)
    Title
  ])
}

// Arrest warrant — AO 442 federal-form style adapted to the
// fictional jurisdiction.
//
// Drawn as small rectangles (with an interior tick when selected) so
// the form does not depend on the running font containing ☐ / ☑
// glyphs.
#let _checkbox(selected, label) = {
  let mark = box(
    baseline: 1pt,
    width: 9pt, height: 9pt,
    rect(width: 9pt, height: 9pt, stroke: 0.7pt + black, inset: 0pt,
      if selected {
        align(center + horizon, text(size: 8pt, weight: "bold", "✓"))
      } else { [] })
  )
  box(mark + h(4pt) + text(size: 9.5pt, label))
}

// Reusable underlined fill-in slot with a small italic caption below.
// Used for AO 442's labeled blank fields.
#let _ao-field(value, label, width: 2in, size: 11pt) = {
  box(width: width)[
    #handwritten(value, size: size)
    #v(-0.2em)
    #line(length: 100%)
    #text(style: "italic", size: 8.5pt, fill: rgb(60, 60, 60), label)
  ]
}

#let arrest-warrant(user-config) = {
  let cfg = merge-config(user-config)
  let _d = _parse-filed-date(cfg.filed-date)
  let defendant = cfg.at("defendant-name",
    default: if cfg.suspect-names.len() > 0 { cfg.suspect-names.at(0) } else { "[Defendant]" })
  let charging-doc = lower(cfg.at("charging-document-type", default: "complaint"))
  let charges = cfg.at("charges-description", default: ())

  // Arrest warrant uses a form-style page with no court header
  // stamps. Override warrant-packet's page setup.
  set page(
    margin: (top: 0.5in, bottom: 0.5in, x: 0.85in),
    numbering: none,
    header: none,
    header-ascent: 0pt,
  )
  set par(first-line-indent: 0em, leading: 0.5em, justify: false)

  // Form label + horizontal rule
  text(size: 9pt, style: "italic",
    "AO 442  (Rev. 11/11)  Arrest Warrant")
  v(0.2em)
  line(length: 100%, stroke: 1.2pt + black)
  v(0.3em)

  // Court header
  align(center, text(weight: "bold", size: 17pt, upper(cfg.court-name)))
  v(-0.3em)
  align(center, text(size: 11pt, "for the"))
  v(-0.4em)
  align(center, text(size: 11pt, cfg.judicial-district))
  v(0.3em)

  // Caption block. Three columns: plaintiff/defendant on the left,
  // closing parens in the middle, Case No. on the right. The left
  // column is its own mini-grid so State/v./Defendant are
  // vertically stacked and centered.
  grid(
    columns: (1fr, 0.5in, 1.7in),
    column-gutter: 0.2em,
    align: (center + horizon, left + horizon, left + horizon),
    inset: (x: 0pt, y: 2pt),

    // left column — plaintiff / v. / defendant. When state is
    // unspecified we drop the "of X" suffix so the line just reads
    // "State" (matches the canonical convention of leaving the state
    // unnamed; see pilot02_warrant_affidavit_scenarios.qmd §9).
    align(center)[
      #if cfg.state == none or cfg.state == "" or cfg.state == "[Fictional State]" [
        State \
      ] else [
        State of #cfg.state \
      ]
      v.
      #v(0.3em)
      #box(width: 90%)[
        #align(left, handwritten(defendant, size: 14pt))
        #v(-0.2em)
        #line(length: 100%)
        #align(left, text(style: "italic", size: 9.5pt, "Defendant"))
      ]
    ],
    // middle parens — six closing parens stacked
    text(size: 12pt)[
      \) \
      \) \
      \) \
      \) \
      \) \
      \)
    ],
    // right column — Case No.
    box(width: 100%)[
      Case No. \
      #v(0.2em)
      #handwritten(cfg.case-number, size: 16pt)
      #v(-0.2em)
      #line(length: 100%)
    ],
  )

  v(0.4em)

  // Title
  align(center, text(weight: "bold", size: 18pt, "ARREST WARRANT"))
  v(0.3em)

  // TO line
  text(weight: "bold", "To:") + h(0.5em) + "Any authorized law enforcement officer"
  v(0.5em)

  // YOU ARE COMMANDED — paragraph followed by a fill-in slot
  par(first-line-indent: 0.3in, justify: false)[
    *YOU ARE COMMANDED* to arrest and bring before a magistrate
    judge of the #cfg.court-name without unnecessary delay #h(2em)
    #_ao-field(defendant, "(name of person to be arrested)", width: 100% - 0.3in, size: 14pt)
    , who is accused of an offense or violation based on the
    following document filed with the court:
  ]
  v(0.4em)

  // Charging-document checkboxes — two rows
  grid(
    columns: (auto, auto, auto, auto, auto, 1fr),
    column-gutter: 1em,
    row-gutter: 0.4em,
    inset: 0pt,

    _checkbox(charging-doc == "indictment", "Indictment"),
    _checkbox(charging-doc == "superseding-indictment", "Superseding Indictment"),
    _checkbox(charging-doc == "information", "Information"),
    _checkbox(charging-doc == "superseding-information", "Superseding Information"),
    _checkbox(charging-doc == "complaint", "Complaint"),
    [],

    _checkbox(charging-doc == "probation-violation-petition", "Probation Violation Petition"),
    _checkbox(charging-doc == "supervised-release-violation-petition", "Supervised Release Violation Petition"),
    _checkbox(charging-doc == "violation-notice", "Violation Notice"),
    _checkbox(charging-doc == "order-of-the-court", "Order of the Court"),
    [], [],
  )
  v(0.4em)

  // Offense description
  text("This offense is briefly described as follows:")
  v(0.3em)

  // Charges narrative paragraphs
  for para in charges {
    par(first-line-indent: 0.25in, justify: false, para)
    v(0.4em)
  }

  // Date / signature block
  v(0.3in)
  grid(
    columns: (1fr, 0.3in, 1fr),
    align: (left + bottom, left, right + bottom),

    _ao-field(_d.month + " " + _d.day + ", " + _d.year,
      "Date", width: 2.2in),
    [],
    block(width: 100%)[
      #place(top + right, dx: -0.4in, dy: -0.05in,
        rotate(-3deg, signature-text(cfg.judge-name, size: 22pt)))
      #v(0.35in)
      #line(length: 100%)
      #align(right, text(size: 9pt, style: "italic",
        "Issuing officer's signature"))
    ],
  )
  v(0.2em)
  grid(
    columns: (1fr, 0.3in, 1fr),
    align: (left + bottom, left, right + bottom),

    _ao-field(
      if cfg.state == none or cfg.state == "" or cfg.state == "[Fictional State]" {
        cfg.city
      } else {
        cfg.city + ", " + cfg.state
      },
      if cfg.state == none or cfg.state == "" or cfg.state == "[Fictional State]" { "City" } else { "City and state" },
      width: 2.6in),
    [],
    block(width: 100%)[
      #align(right, text(size: 11pt,
        cfg.judge-name + ", " + cfg.judge-title-full))
      #v(-0.2em)
      #line(length: 100%)
      #align(right, text(size: 9pt, style: "italic",
        "Printed name and title"))
    ],
  )

  // Return-section defaults. Each can be overridden via YAML; if the
  // override is missing, fall back to the most sensible value drawn
  // from the rest of the config.
  let _date-str = _d.month + " " + _d.day + ", " + _d.year
  let received-date = cfg.at("arrest-received-date", default: _date-str)
  let arrest-date = cfg.at("arrest-date", default: _date-str)
  let arrest-location = cfg.at("arrest-location",
    default: if cfg.state == none or cfg.state == "" or cfg.state == "[Fictional State]" {
      cfg.city
    } else {
      cfg.city + ", " + cfg.state
    })
  let arresting-officer = cfg.at("arresting-officer-name",
    default: cfg.detective-name)
  let arresting-officer-title = cfg.at("arresting-officer-title",
    default: cfg.detective-unit)

  // Return box
  v(0.3in)
  block(
    stroke: 1pt + black,
    inset: 0.12in,
    width: 100%,
  )[
    #align(center, block(
      width: 100%,
      fill: rgb(220, 220, 220),
      inset: (x: 6pt, y: 4pt),
      text(weight: "bold", size: 11pt, "Return")
    ))
    #v(0.3em)
    This warrant was received on #_ao-field(received-date, "(date)", width: 1.6in)
    , and the person was arrested on #_ao-field(arrest-date, "(date)", width: 1.6in)
    at #_ao-field(arrest-location, "(city and state)", width: 2.4in) .
    #v(0.4em)
    #grid(
      columns: (1fr, 0.3in, 1fr),
      align: (left + bottom, left, right + bottom),

      _ao-field(arrest-date, "Date", width: 1.8in),
      [],
      block(width: 100%)[
        #place(top + right, dx: -0.4in, dy: -0.05in,
          rotate(-3deg, signature-text(arresting-officer, size: 20pt)))
        #v(0.3in)
        #line(length: 100%)
        #align(right, text(size: 9pt, style: "italic",
          "Arresting officer's signature"))
      ],
    )
    #v(0.3em)
    #align(right, block(width: 60%)[
      #align(right, text(size: 11pt,
        arresting-officer + ", " + arresting-officer-title))
      #v(-0.2em)
      #line(length: 100%)
      #align(right, text(size: 9pt, style: "italic",
        "Printed name and title"))
    ])
  ]
}

#let _inventory-list(items) = {
  set par(first-line-indent: 0em)
  enum(
    indent: 0.4in,
    body-indent: 0.4em,
    spacing: 0.3em,
    ..items.map(it => it)
  )
}

#let return-doc(user-config) = {
  let cfg = merge-config(user-config)

  set page(
    margin: (top: 2.2in, bottom: 0.7in, x: 0.85in),
    header: make-page-header(cfg, with-clerk-stamp: false),
    header-ascent: 0.3in,
  )

  caption-block(
    state: cfg.state,
    county: cfg.county,
    title: "RETURN AND INVENTORY",
    title-size: 14pt,
  )
  v(0.4em)

  let _d = _parse-filed-date(cfg.filed-date)
  let _exec-time = if cfg.warrant-time != none and cfg.warrant-time != "" {
    cfg.warrant-time
  } else { "" }
  let _am-pm = if cfg.warrant-period == "DAYTIME" { "P" } else { "A" }
  [
    THE UNDERSIGNED, being first duly sworn, upon oath says that on
    #fill-in(_d.month + " " + _d.day + ", " + _d.year, width: 1.8in)
    , at #fill-in(_exec-time, width: 0.7in) o'clock
    #fill-in(_am-pm, width: 0.4in)#text[.M.], I executed the within warrant
    as directed there.
  ]
  v(0.5em)

  [
    I seized from the place described in said warrant the following
    described property of which I am now in possession.
  ]
  v(0.5em)

  _inventory-list(cfg.inventory-items)
  v(0.5em)

  let service-recipient = if cfg.suspect-names.len() > 0 {
    cfg.suspect-names.at(0)
  } else { "[recipient]" }

  [
    A copy of the search warrant and an inventory of the items seized
    was signed for by #service-recipient and left on the dining room
    table at #cfg.search-address.
  ]
  v(0.4in)

  applicant-block(
    signature-asset: cfg.detective-signature-asset,
    name: cfg.detective-name,
    title-text: cfg.detective-name,
    subscribed-date: _d.month + " " + _d.day,
    badge: cfg.detective-badge,
  )
  v(0.15in)

  notary-block(
    signature-asset: cfg.notary-signature-asset,
    stamp-asset: cfg.notary-stamp-asset,
    name: cfg.notary-name,
  )
}

// Returns a config that has the per-exhibit fields (exhibit-type,
// exhibit-title, exhibit-device, exhibit-description,
// exhibit-records, exhibit-columns, exhibit-starting-page) sourced
// from cfg.exhibits.at(idx) when the list has an entry at that
// index, falling back to the top-level cfg fields otherwise. The
// returned dict can be passed to renderers that expect the legacy
// flat schema.
#let _config-for-exhibit(cfg, idx) = {
  let exhibits = cfg.at("exhibits", default: ())
  if type(exhibits) != array or exhibits.len() <= idx {
    return cfg
  }
  let entry = exhibits.at(idx)
  let result = cfg
  // Each per-exhibit field overrides the top-level field of the same
  // name when present in the list entry.
  let keys = (
    "exhibit-type",
    "exhibit-title",
    "exhibit-device",
    "exhibit-description",
    "exhibit-records",
    "exhibit-records-file",
    "exhibit-columns",
    "exhibit-starting-page",
    "geofence-center",
    "geofence-radius-m",
    "geofence-window-start",
    "geofence-window-end",
    "geofence-narrative",
    "geofence-map-asset",
    "geofence-step",
    "account-id",
  )
  for k in keys {
    if k in entry {
      result.insert(k, _unescape(entry.at(k)))
    }
  }
  result
}

#let attachment(user-config, number: 1, exhibit-index: 0) = {
  let cfg = merge-config(user-config)
  let cfg = _config-for-exhibit(cfg, exhibit-index)

  v(0.6in)

  align(center, text(weight: "bold", size: 14pt)[ATTACHMENT \# #number])

  v(0.6in)

  let description = if cfg.exhibit-description != "" {
    cfg.exhibit-description
  } else {
    "[Description of attached exhibit. Set exhibit-description in YAML to override.]"
  }

  block(width: 100%, description)
}

// ===========================================================================
// 8. Exhibits
// ===========================================================================
//
// The block between the AUTO-GENERATED markers below is regenerated by
// R/build_exhibits.R from the canonical sources at
// typst/exhibits/*.typ. Do not edit by hand — edit the source files
// and re-run the script.

// EXHIBITS-AUTO-START
// --- inlined from typst/exhibits/meta-records.typ ---

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

// --- inlined from typst/exhibits/photo-log.typ ---

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

// --- inlined from typst/exhibits/browser-history.typ ---

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

// --- inlined from typst/exhibits/text-messages.typ ---

#let _sms-row(record) = {
  let sender = record.at("sender", default: "[+1-555-0100]")
  let direction = lower(record.at("direction", default: "out"))
  let timestamp = record.at("timestamp", default: "[YYYY-MM-DD HH:MM]")
  let body = record.at("body", default: "")

  let sender-color = if direction == "out" {
    rgb(20, 80, 180)
  } else {
    rgb(30, 30, 30)
  }

  block(below: 0.7em, above: 0.2em, breakable: false)[
    #grid(
      columns: (1.4in, 1.4in, 1fr),
      column-gutter: 8pt,
      row-gutter: 2pt,
      align: (left + top, left + top, left + top),

      text(weight: "bold", size: 10pt, fill: sender-color, sender),
      text(size: 9pt, fill: rgb(90, 90, 90), timestamp),
      text(size: 10pt, body),
    )
  ]
}

#let text-messages(user-config, records: ()) = {
  let cfg = merge-config(user-config)
  let title = cfg.at("exhibit-title", default: "TEXT MESSAGE EXTRACT")
  let device = cfg.at("exhibit-device", default: "")

  set page(
    margin: (top: 0.7in, bottom: 0.7in, x: 0.9in),
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
  set text(font: ("Liberation Sans", "Helvetica Neue", "Helvetica", "Arial"), size: 10.5pt)
  set par(first-line-indent: 0em, leading: 0.45em, justify: false)

  // Optional device line under the header
  if device != "" {
    block(below: 0.6em, text(size: 9pt, style: "italic",
      fill: rgb(80, 80, 80),
      "Device: " + device))
  }

  // Column header row
  block(below: 0.4em,
    grid(
      columns: (1.4in, 1.4in, 1fr),
      column-gutter: 8pt,
      align: (left, left, left),
      text(weight: "bold", size: 9pt, "Sender"),
      text(weight: "bold", size: 9pt, "Timestamp"),
      text(weight: "bold", size: 9pt, "Message"),
    )
  )
  line(length: 100%, stroke: 0.5pt + rgb(150, 150, 150))
  v(0.3em)

  for record in records {
    _sms-row(record)
  }
}

// --- inlined from typst/exhibits/geofence-warrant.typ ---

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

// --- inlined from typst/exhibits/geofence-anonymized.typ ---

#let geofence-anonymized(user-config, records: ()) = {
  let cfg = merge-config(user-config)
  let step = cfg.at("geofence-step", default: 1)
  let title = cfg.at("exhibit-title",
    default: "Google LLC -- Geofence Production")
  let win-start = cfg.at("geofence-window-start", default: "")
  let win-end = cfg.at("geofence-window-end", default: "")

  set page(
    margin: (top: 0.55in, bottom: 0.6in, x: 0.55in),
    header: context {
      let n = counter(page).get().first()
      block(
        width: 100%,
        height: 0.36in,
        fill: rgb(26, 115, 232),  // Google blue
        inset: (x: 0.4in, y: 0.08in),
      )[
        #grid(
          columns: (1fr, auto),
          align: (left + horizon, right + horizon),
          text(white, weight: "bold", size: 11pt,
            title + " -- Step " + str(step)),
          text(white, weight: "bold", size: 10pt, "Page " + str(n)),
        )
      ]
    },
    header-ascent: 0pt,
    footer: context {
      let n = counter(page).get().first()
      let total = counter(page).final().first()
      block(
        width: 100%,
        inset: (top: 6pt),
        stroke: (top: 0.5pt + rgb(180, 180, 180)),
      )[
        #align(center,
          text(size: 8pt, fill: rgb(120, 120, 120), style: "italic",
            "Intellectual property of Google LLC. " +
            "Page " + str(n) + " of " + str(total) + "."))
      ]
    },
  )
  set text(font: ("Liberation Sans", "Helvetica Neue", "Helvetica", "Arial"),
    size: 8.5pt)
  set par(first-line-indent: 0em, leading: 0.4em, justify: false)

  v(0.15in)

  if win-start != "" or win-end != "" {
    block(below: 0.4em,
      text(size: 9pt, weight: "bold",
        "Time window: " + win-start +
          (if win-start != "" and win-end != "" { " to " } else { "" }) +
          win-end))
  }

  let _row-cells = records.map(r => (
    text(r.at("device-id", default: "[device-id]")),
    text(r.at("timestamp", default: "[YYYY-MM-DD HH:MM:SS UTC]")),
    text(str(r.at("latitude", default: "[lat]"))),
    text(str(r.at("longitude", default: "[long]"))),
    text(weight: "bold", upper(r.at("source", default: "[src]"))),
    align(right, text(str(r.at("display-radius-m", default: "[m]")))),
  )).flatten()

  table(
    columns: (1.05in, 1.45in, 0.85in, 0.95in, 0.55in, 0.7in),
    inset: (x: 5pt, y: 4pt),
    align: (x, y) => if y == 0 { center + horizon } else { left + top },
    stroke: (x, y) => (
      top: if y == 0 { 0.8pt + black }
           else if y == 1 { 0.5pt + black }
           else { 0.2pt + rgb(200, 200, 200) },
      bottom: none,
      left: none,
      right: none,
    ),
    fill: (x, y) => if y == 0 { rgb(232, 232, 232) }
                    else if calc.rem(y, 2) == 0 { rgb(248, 248, 248) }
                    else { none },

    table.header(
      text(weight: "bold", size: 8.5pt, "Device ID"),
      text(weight: "bold", size: 8.5pt, "Timestamp (UTC)"),
      text(weight: "bold", size: 8.5pt, "Latitude"),
      text(weight: "bold", size: 8.5pt, "Longitude"),
      text(weight: "bold", size: 8.5pt, "Source"),
      text(weight: "bold", size: 8.5pt, "Maps Disp. Radius (m)"),
    ),
    .._row-cells
  )
}

// --- inlined from typst/exhibits/geofence-summary.typ ---

#let geofence-summary(user-config, records: ()) = {
  let cfg = merge-config(user-config)
  let title = cfg.at("exhibit-title",
    default: "Summary of Records Received from Google")
  let subtitle = cfg.at("exhibit-device", default: "")  // case header

  set page(margin: (top: 0.6in, bottom: 0.7in, x: 0.6in))
  set text(font: ("Liberation Sans", "Helvetica Neue", "Helvetica", "Arial"),
    size: 9.5pt)
  set par(first-line-indent: 0em, leading: 0.4em, justify: false)

  align(center, text(weight: "bold", size: 13pt, title))
  if subtitle != "" {
    v(0.2em)
    align(center, text(size: 10pt, style: "italic", subtitle))
  }
  v(0.4em)

  let totals-count = records.fold(0, (acc, r) => {
    let c = r.at("record-count", default: 0)
    acc + (if type(c) == int { c } else { 0 })
  })

  let _row-cells = records.map(r => (
    text(r.at("device-id", default: "[device-id]")),
    text(r.at("first-record-time", default: "[--]")),
    text(r.at("last-record-time", default: "[--]")),
    align(right, text(str(r.at("record-count", default: "[--]")))),
    align(right, text(str(r.at("smallest-radius-m", default: "[--]")))),
    align(right, text(str(r.at("largest-radius-m", default: "[--]")))),
  )).flatten()

  let total-row = (
    text(weight: "bold", "Grand Total"),
    text(""),
    text(""),
    align(right, text(weight: "bold", str(totals-count))),
    text(""),
    text(""),
  )

  table(
    columns: (1.4in, 1.3in, 1.3in, 0.95in, 1.05in, 1.05in),
    inset: (x: 6pt, y: 5pt),
    align: (x, y) => if y == 0 { center + horizon } else { left + top },
    stroke: (x, y) => (
      top: if y == 0 { 1pt + black }
           else if y == 1 { 0.5pt + black }
           else { 0.2pt + rgb(200, 200, 200) },
      bottom: none,
      left: none,
      right: none,
    ),
    fill: (x, y) => if y == 0 { rgb(232, 232, 232) } else { none },

    table.header(
      text(weight: "bold", size: 9pt, "Device ID"),
      text(weight: "bold", size: 9pt, "First Record"),
      text(weight: "bold", size: 9pt, "Last Record"),
      text(weight: "bold", size: 9pt, "Records"),
      text(weight: "bold", size: 9pt, "Smallest Radius (m)"),
      text(weight: "bold", size: 9pt, "Largest Radius (m)"),
    ),
    .._row-cells,
    ..total-row
  )
}

// --- inlined from typst/exhibits/geofence-subscriber.typ ---

#let _format-list(value) = {
  if type(value) == array {
    value.join(", ")
  } else {
    value
  }
}

#let _subscriber-block(record) = {
  let name = record.at("subscriber-name", default: "[Subscriber]")
  let acct = record.at("account-number", default: "[--]")
  let created = record.at("account-created", default: "")
  let emails = _format-list(record.at("emails", default: "[--]"))
  let device = record.at("device-make-model", default: "[--]")
  let imei = record.at("device-imei", default: "")
  let phones = _format-list(record.at("phone-numbers", default: "[--]"))
  let voice = record.at("google-voice", default: "")

  block(below: 1em, above: 0.3em, breakable: false,
        stroke: (left: 2pt + rgb(26, 115, 232)),
        inset: (left: 10pt, top: 4pt, bottom: 4pt))[
    #text(weight: "bold", size: 12pt, name)
    #v(0.4em)
    #grid(
      columns: (1.4in, 1fr),
      column-gutter: 6pt,
      row-gutter: 4pt,

      text(weight: "bold", "Account Number"),
      acct,

      ..(if created != "" {
        (text(weight: "bold", "Account Created"), created)
      } else { () }),

      text(weight: "bold", "Email Address(es)"),
      emails,

      text(weight: "bold", "Device"),
      device,

      ..(if imei != "" {
        (text(weight: "bold", "Device IMEI"), imei)
      } else { () }),

      text(weight: "bold", "Phone Number(s)"),
      phones,

      ..(if voice != "" {
        (text(weight: "bold", "Google Voice"), voice)
      } else { () }),
    )
  ]
}

#let geofence-subscriber(user-config, records: ()) = {
  let cfg = merge-config(user-config)
  let title = cfg.at("exhibit-title",
    default: "Google LLC -- Subscriber Information Production")

  set page(
    margin: (top: 0.55in, bottom: 0.6in, x: 0.85in),
    header: context {
      let n = counter(page).get().first()
      block(
        width: 100%,
        height: 0.36in,
        fill: rgb(26, 115, 232),
        inset: (x: 0.4in, y: 0.08in),
      )[
        #grid(
          columns: (1fr, auto),
          align: (left + horizon, right + horizon),
          text(white, weight: "bold", size: 11pt, title),
          text(white, weight: "bold", size: 10pt, "Page " + str(n)),
        )
      ]
    },
    header-ascent: 0pt,
  )
  set text(font: ("Liberation Sans", "Helvetica Neue", "Helvetica", "Arial"),
    size: 10pt)
  set par(first-line-indent: 0em, leading: 0.45em, justify: false)

  v(0.2in)

  for record in records {
    _subscriber-block(record)
  }
}

// --- inlined from typst/exhibits/account-audit.typ ---

#let _audit-row(record, idx) = {
  let ts = record.at("timestamp", default: "[YYYY-MM-DD HH:MM:SS UTC]")
  let ev = record.at("event", default: "[event]")
  let dt = record.at("detail", default: "")
  let tag = record.at("device-tag", default: "")

  block(below: 0.55em, above: 0.2em, breakable: false)[
    #grid(
      columns: (0.4in, 1.6in, 1fr),
      column-gutter: 6pt,
      row-gutter: 2pt,

      align(right, text(weight: "bold", str(idx) + ".")),
      text(font: ("Liberation Mono", "Menlo", "Courier New"), size: 9pt, ts),
      text(weight: "bold", ev),
    )
    #if dt != "" or tag != "" {
      block(inset: (left: 2.05in, top: 2pt))[
        #if dt != "" [#text(size: 9.5pt, dt)]
        #if tag != "" [
          #linebreak()
          #text(size: 9pt, fill: rgb(100, 100, 100),
            "Device tag: " + tag)
        ]
      ]
    }
  ]
}

#let account-audit(user-config, records: ()) = {
  let cfg = merge-config(user-config)
  let title = cfg.at("exhibit-title",
    default: "Google LLC Audit Record")
  let account = cfg.at("account-id", default: "")

  set page(margin: (top: 0.7in, bottom: 0.7in, x: 0.85in))
  set text(font: ("Liberation Serif", "Times New Roman", "Times"), size: 11pt)
  set par(first-line-indent: 0em, leading: 0.5em, justify: false)

  align(center, text(weight: "bold", size: 13pt, title))
  if account != "" {
    v(0.2em)
    align(center, text(size: 10pt, style: "italic",
      "Subject Account: " + account))
  }
  v(0.4em)
  align(center, line(length: 60%, stroke: 0.5pt))
  v(0.5em)

  for (i, record) in records.enumerate() {
    _audit-row(record, i + 1)
  }
}

// --- inlined from typst/exhibits/location-timeline.typ ---

#let _timeline-entry(record) = {
  let place = record.at("place-name", default: "[Place]")
  let addr = record.at("address", default: "")
  let arr = record.at("arrival", default: "[--:--]")
  let dep = record.at("departure", default: "[--:--]")
  let conf = record.at("confidence", default: "")

  block(below: 0.7em, above: 0.2em, breakable: false,
        inset: (left: 0.4in))[
    #grid(
      columns: (1fr, auto),
      column-gutter: 12pt,

      block[
        #text(weight: "bold", size: 11pt, place)
        #if addr != "" [
          \
          #text(size: 9.5pt, fill: rgb(100, 100, 100), addr)
        ]
      ],
      block(width: 1.4in)[
        #align(right, text(size: 9.5pt,
          font: ("Liberation Mono", "Menlo", "Courier New"),
          arr + " -- " + dep))
        #if conf != "" [
          #linebreak()
          #align(right, text(size: 8pt, fill: rgb(120, 120, 120),
            style: "italic", conf + " confidence"))
        ]
      ],
    )
  ]
}

#let location-timeline(user-config, records: ()) = {
  let cfg = merge-config(user-config)
  let title = cfg.at("exhibit-title",
    default: "Google Maps Timeline -- Place Visits")
  let device = cfg.at("exhibit-device", default: "")

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

  if device != "" {
    block(below: 0.6em, text(size: 9pt, style: "italic",
      fill: rgb(80, 80, 80),
      "Source: " + device))
  }

  // Group entries by date and emit a date heading before each group.
  let prev-date = ""
  for record in records {
    let d = record.at("date", default: "")
    if d != "" and d != prev-date {
      v(0.4em)
      block(below: 0.4em,
        text(weight: "bold", size: 12pt, fill: rgb(26, 115, 232), d))
      align(left, line(length: 100%, stroke: 0.5pt + rgb(200, 200, 200)))
      v(0.2em)
      prev-date = d
    }
    _timeline-entry(record)
  }
}

// --- inlined from typst/exhibits/search-activity.typ ---

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
// EXHIBITS-AUTO-END

// ===========================================================================
// 9. Top-level dispatch
// ===========================================================================

#let _doc-renderer(name) = {
  let table = (
    "affidavit": affidavit,
    "warrant": warrant-doc,
    "search-warrant": warrant-doc,
    "arrest-warrant": arrest-warrant,
    "return": return-doc,
    "attachment": attachment,
  )
  if name in table {
    table.at(name)
  } else {
    panic("Unknown document type: " + name)
  }
}

#let exhibit(user-config, records: (), exhibit-index: 0) = {
  let cfg = merge-config(user-config)
  let cfg = _config-for-exhibit(cfg, exhibit-index)
  let kind = cfg.at("exhibit-type", default: none)
  if kind == none {
    return
  }
  // Records resolution priority:
  //   1. records arg passed directly to exhibit()
  //   2. exhibit-records-file YAML data file (workaround for Pandoc
  //      dropping nested-dict contents on some record schemas)
  //   3. inline exhibit-records: metadata
  let records-file = cfg.at("exhibit-records-file", default: "")
  let recs = if records.len() > 0 {
    records
  } else if records-file != "" {
    yaml(records-file)
  } else {
    cfg.at("exhibit-records", default: ())
  }
  // The downstream renderers (meta-records, text-messages,
  // browser-history, photo-log) call merge-config(user-config)
  // again on their own and read from the legacy flat-schema fields.
  // To make sure they see the per-exhibit values, we package the
  // resolved cfg as a fresh user-config with just the relevant
  // keys overridden. Any field set on the per-exhibit entry will
  // override the user-config the renderer reads.
  let exhibits = user-config.at("exhibits", default: ())
  let scoped-config = if type(exhibits) == array and exhibits.len() > exhibit-index {
    let merged = user-config
    let entry = exhibits.at(exhibit-index)
    for k in (
      "exhibit-type", "exhibit-title", "exhibit-device",
      "exhibit-description", "exhibit-records", "exhibit-records-file",
      "exhibit-columns", "exhibit-starting-page",
      "geofence-center", "geofence-radius-m",
      "geofence-window-start", "geofence-window-end",
      "geofence-narrative", "geofence-map-asset",
      "geofence-step", "account-id",
    ) {
      if k in entry {
        merged.insert(k, entry.at(k))
      }
    }
    merged
  } else {
    user-config
  }

  // Dispatch by exhibit-type.
  if kind == "meta-records" or kind == "facebook-messages" {
    meta-records(scoped-config, records: recs)
  } else if kind == "text-messages" or kind == "sms" {
    text-messages(scoped-config, records: recs)
  } else if kind == "browser-history" or kind == "search-history" {
    browser-history(scoped-config, records: recs)
  } else if kind == "photo-log" or kind == "photos" or kind == "evidence-photos" {
    photo-log(scoped-config, records: recs)
  } else if kind == "geofence-warrant" {
    geofence-warrant(scoped-config, records: recs)
  } else if (kind == "geofence-anonymized" or kind == "sensorvault-step1"
             or kind == "sensorvault-step2") {
    geofence-anonymized(scoped-config, records: recs)
  } else if kind == "geofence-summary" {
    geofence-summary(scoped-config, records: recs)
  } else if kind == "geofence-subscriber" or kind == "sensorvault-step3" {
    geofence-subscriber(scoped-config, records: recs)
  } else if kind == "account-audit" {
    account-audit(scoped-config, records: recs)
  } else if kind == "location-timeline" or kind == "maps-timeline" {
    location-timeline(scoped-config, records: recs)
  } else if kind == "search-activity" or kind == "my-activity" {
    search-activity(scoped-config, records: recs)
  } else {
    panic("Unknown exhibit-type: " + kind)
  }
}

#let warrant-packet(
  user-config: (:),
  document-types: ("affidavit",),
  paper: "us-letter",
  margin: (top: 0.6in, bottom: 0.7in, x: 0.85in),
  fontsize: 11pt,
  // Body font with fallback chain. Liberation Serif is the
  // preferred match for the source-document look but is not bundled
  // on macOS by default; fall back to Times-family fonts that ship
  // with most operating systems.
  body-font: ("Liberation Serif", "Times New Roman", "Times", "Hoefler Text"),
) = {
  // numbering: none turns off the "1, 2, 3" page numbers Quarto adds
  // by default; the source court documents don't carry visible page
  // numbers.
  set page(paper: paper, margin: margin, numbering: none)
  set text(font: body-font, size: fontsize)
  set par(first-line-indent: 0.25in, leading: 0.6em, justify: false)
  set heading(numbering: none)

  // attachment-counter and exhibit-counter both advance as we walk
  // document-types so a packet like
  //   ["affidavit", "attachment", "exhibit", "attachment", "exhibit"]
  // produces ATTACHMENT #1 + exhibits[0], then ATTACHMENT #2 +
  // exhibits[1]. Attachments and exhibits advance independently;
  // the user is free to render an attachment-only document or an
  // exhibit-only document if needed.
  let attachment-counter = 1
  let exhibit-counter = 0
  for (i, doc-name) in document-types.enumerate() {
    if i > 0 {
      pagebreak()
    }
    if doc-name == "exhibit" {
      exhibit(user-config, exhibit-index: exhibit-counter)
      exhibit-counter += 1
    } else if doc-name == "attachment" {
      // ATTACHMENT \#N cover sheet pulls its description from
      // exhibits[N-1] (so attachment #1 describes exhibit #1).
      attachment(user-config,
        number: attachment-counter,
        exhibit-index: attachment-counter - 1)
      attachment-counter += 1
    } else {
      let renderer = _doc-renderer(doc-name)
      renderer(user-config)
    }
  }
}

// ===========================================================================
// 10. Quarto entry point
// ===========================================================================

#let article(
  // Standard Quarto fields
  title: none,
  subtitle: none,
  authors: none,
  date: none,
  abstract: none,
  cols: 1,
  margin: (x: 0.85in, y: 0.65in),
  paper: "us-letter",
  lang: "en",
  region: "US",
  font: ("Liberation Serif", "Times New Roman", "Times", "Hoefler Text"),
  fontsize: 11pt,
  sectionnumbering: none,
  linkcolor: "#A41034",
  linestretch: 1,
  flipped: false,

  // Warrant-vignette fields
  document-types: ("affidavit",),
  case-number: none,
  case-id-barcode: none,
  filed-date: none,
  filed-time: none,
  warrant-time: none,
  warrant-period: "DAYTIME",
  state: none,
  county: none,
  city: none,
  court-name: none,
  judicial-district: none,
  clerk-name: none,
  judge-name: none,
  judge-title-full: none,
  detective-name: none,
  detective-badge: none,
  detective-unit: none,
  detective-division: none,
  detective-years: none,
  notary-name: none,
  notary-commission-exp: none,
  search-address: none,
  property-description: none,
  suspect-names: none,
  items-to-seize: none,
  narrative-paragraphs: none,
  inventory-items: none,
  exhibit-type: none,
  exhibit-records: none,
  exhibit-records-file: none,
  exhibit-description: none,
  exhibit-starting-page: none,
  exhibit-title: none,
  exhibit-device: none,
  exhibit-columns: none,
  exhibits: none,

  // Geofence / Sensorvault / Google-data exhibit fields
  geofence-center: none,
  geofence-radius-m: none,
  geofence-window-start: none,
  geofence-window-end: none,
  geofence-narrative: none,
  geofence-map-asset: none,
  geofence-step: none,
  account-id: none,

  // Arrest-warrant fields
  defendant-name: none,
  charging-document-type: none,
  charges-description: none,
  arrest-received-date: none,
  arrest-date: none,
  arrest-location: none,
  arresting-officer-name: none,
  arresting-officer-title: none,

  clerk-stamp-asset: none,
  judge-seal-asset: none,
  filed-stamp-asset: none,
  date-stamp-asset: none,
  notary-stamp-asset: none,
  detective-signature-asset: none,
  judge-signature-asset: none,
  notary-signature-asset: none,

  doc,
) = {
  let _candidates = (
    case-number: case-number,
    case-id-barcode: case-id-barcode,
    filed-date: filed-date,
    filed-time: filed-time,
    warrant-time: warrant-time,
    warrant-period: warrant-period,
    state: state,
    county: county,
    city: city,
    court-name: court-name,
    judicial-district: judicial-district,
    clerk-name: clerk-name,
    judge-name: judge-name,
    judge-title-full: judge-title-full,
    detective-name: detective-name,
    detective-badge: detective-badge,
    detective-unit: detective-unit,
    detective-division: detective-division,
    detective-years: detective-years,
    notary-name: notary-name,
    notary-commission-exp: notary-commission-exp,
    search-address: search-address,
    property-description: property-description,
    suspect-names: suspect-names,
    items-to-seize: items-to-seize,
    narrative-paragraphs: narrative-paragraphs,
    inventory-items: inventory-items,
    exhibit-type: exhibit-type,
    exhibit-records: exhibit-records,
    exhibit-records-file: exhibit-records-file,
    exhibit-description: exhibit-description,
    exhibit-starting-page: exhibit-starting-page,
    exhibit-title: exhibit-title,
    exhibit-device: exhibit-device,
    exhibit-columns: exhibit-columns,
    exhibits: exhibits,
    geofence-center: geofence-center,
    geofence-radius-m: geofence-radius-m,
    geofence-window-start: geofence-window-start,
    geofence-window-end: geofence-window-end,
    geofence-narrative: geofence-narrative,
    geofence-map-asset: geofence-map-asset,
    geofence-step: geofence-step,
    account-id: account-id,
    defendant-name: defendant-name,
    charging-document-type: charging-document-type,
    charges-description: charges-description,
    arrest-received-date: arrest-received-date,
    arrest-date: arrest-date,
    arrest-location: arrest-location,
    arresting-officer-name: arresting-officer-name,
    arresting-officer-title: arresting-officer-title,
    clerk-stamp-asset: clerk-stamp-asset,
    judge-seal-asset: judge-seal-asset,
    filed-stamp-asset: filed-stamp-asset,
    date-stamp-asset: date-stamp-asset,
    notary-stamp-asset: notary-stamp-asset,
    detective-signature-asset: detective-signature-asset,
    judge-signature-asset: judge-signature-asset,
    notary-signature-asset: notary-signature-asset,
  )

  let user-config = (:)
  for (k, v) in _candidates {
    if v != none {
      user-config.insert(k, v)
    }
  }

  warrant-packet(
    user-config: user-config,
    document-types: document-types,
    paper: paper,
    margin: margin,
    fontsize: fontsize,
  )
}
