// Affidavit in Support of Search Warrant.
//
// The longest of the four document types. Pages 1–N carry the body
// (officer identification, list of items sought, property description,
// custody and control, narrative paragraphs, and computer-search
// boilerplate). The final page carries the affiant's signature,
// "SUBSCRIBED AND SWORN" line, and the judge's signature with seal.

#import "../partials/util.typ": handwritten, fill-in, merge-config
#import "../partials/caption.typ": caption-block
#import "../partials/header.typ": header-block
#import "../partials/signature.typ": detective-signature, judge-signature, subscribed-and-sworn
#import "../partials/footer.typ": case-barcode

#let _items-list(items) = {
  // Numbered list of items to be searched for. Bolded in the source.
  set par(first-line-indent: 0em)
  enum(
    indent: 0.5in,
    body-indent: 0.5em,
    spacing: 0.4em,
    ..items.map(it => strong(it))
  )
}

#let _narrative(paragraphs) = {
  // Body narrative paragraphs. Each is set as its own paragraph with
  // the standard first-line indent applied by the template's set par.
  for para in paragraphs {
    block(below: 1em, para)
  }
}

#let _opening-block(cfg) = {
  let day-num = "[DD]"  // The Typst layer doesn't parse the date; the
                        // narrative-paragraphs slot carries the actual
                        // dates the document references. The opening
                        // sentence uses fixed text.
  [
    The affidavit of the undersigned on this
    #fill-in(day-num, width: 0.6in)
    day of
    #fill-in("[Month]", width: 1.1in)
    , #fill-in("[YYYY]", width: 0.8in)
    , who being first duly sworn, upon oath says:

    #v(0.4em)
    That I am a certified law enforcement officer with the
    #cfg.detective-division, #cfg.city, #cfg.county
    #cfg.state, and have been employed by the #cfg.detective-division
    as a law enforcement officer for nearly #cfg.detective-years
    years. My duties include the investigation of criminal violations
    of the #cfg.state State Statutes.
  ]
}

#let _items-section(cfg) = [
  Contrary to the statutes of the State of #cfg.state, there is kept and
  concealed as hereinafter described the following described property:

  #_items-list(cfg.items-to-seize)
]

#let _location-section(cfg) = [
  That this property is concealed or kept in or about the following
  described place:

  #v(0.4em)
  #par(first-line-indent: 0em, hanging-indent: 0.5in,
    [*1. * #strong(underline(cfg.search-address + ". " + cfg.property-description))]
  )

  #v(0.4em)
  That the property is under the custody or control of:
  #strong(cfg.suspect-names.join(", "))
]

#let _grounds-section(cfg) = [
  That the grounds for issuance of the search warrant are as follows:

  #v(0.4em)
  #_narrative(cfg.narrative-paragraphs)
]

// Public: full affidavit document.
//
// Returns a content block that can be placed inside any page() context.
// The caller is expected to set page geometry and base text rules
// before invoking this.
#let affidavit(user-config) = {
  let cfg = merge-config(user-config)

  // ----- page 1 header zone -------------------------------------------------
  header-block(cfg, document-title: "AFFIDAVIT IN SUPPORT OF SEARCH WARRANT")

  // Caption block sits below the stamp cluster
  caption-block(
    state: cfg.state,
    county: cfg.county,
    title: "AFFIDAVIT IN SUPPORT OF SEARCH WARRANT",
    title-size: 13pt,
  )
  v(0.4em)

  // ----- body --------------------------------------------------------------
  _opening-block(cfg)
  v(0.5em)
  _items-section(cfg)
  v(0.4em)
  _location-section(cfg)
  v(0.4em)
  _grounds-section(cfg)

  // ----- page-1 footer barcode (only on page 1) ----------------------------
  // The barcode is positioned absolutely at the bottom-right of the
  // first page only. The caller can suppress this by passing an empty
  // case-id-barcode string.
  if cfg.case-id-barcode != "" {
    place(bottom + right, dx: 0in, dy: 0in,
      case-barcode(case-id: cfg.case-id-barcode))
  }

  // ----- closing ("WHEREFORE") + signature page ----------------------------
  v(1em)
  [
    Due to the above information, this affiant requests that a search
    warrant searching the residence of #cfg.search-address.
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
  subscribed-and-sworn()  // blank fill-in slots; caller may overlay

  v(0.4in)
  judge-signature(
    signature-asset: cfg.judge-signature-asset,
    seal-asset: cfg.judge-seal-asset,
    title: cfg.judge-name,
  )
}
