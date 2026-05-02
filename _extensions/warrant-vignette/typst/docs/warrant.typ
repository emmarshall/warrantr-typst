// Search Warrant.
//
// Single-page document. Same header stamp cluster and pleading caption
// as the affidavit, then a "TO:" line addressing the executing officer,
// followed by court-finding paragraphs, a numbered list of items to
// seize, and a signature block at the bottom with handwritten DAYTIME /
// NIGHTTIME, date, and time fields.

#import "../partials/util.typ": handwritten, fill-in, merge-config
#import "../partials/caption.typ": caption-block
#import "../partials/header.typ": header-block
#import "../partials/signature.typ": judge-signature

#let _command-list(items) = {
  set par(first-line-indent: 0em)
  enum(
    indent: 0.5in,
    body-indent: 0.5em,
    spacing: 0.4em,
    ..items.map(it => [Any and all #it])
  )
}

// Public: full search warrant.
#let warrant(user-config) = {
  let cfg = merge-config(user-config)

  header-block(cfg, document-title: "SEARCH WARRANT")

  caption-block(
    state: cfg.state,
    county: cfg.county,
    title: "SEARCH WARRANT",
    title-size: 16pt,
  )
  v(0.4em)

  // ----- "TO:" addressing line ---------------------------------------------
  [
    *TO:* #cfg.detective-name of the #cfg.detective-division and other
    officers under his supervision.
  ]
  v(0.5em)

  // ----- court-finding paragraphs ------------------------------------------
  [
    THIS MATTER came on for hearing on the
    #fill-in("[DD]", width: 0.5in) day of
    #fill-in("[Month]", width: 1in) , #fill-in("[YYYY]", width: 0.6in)
    , upon the sworn affidavit for issuance of a Search Warrant, and
    the Court, being fully advised in the premises finds as follows:
  ]
  v(0.4em)

  [That the Court has jurisdiction in this matter.]
  v(0.4em)

  [
    That based upon the sworn affidavit for issuance of a Search
    Warrant by #cfg.detective-unit Detective #cfg.detective-name, dated
    #fill-in("[Month DD, YYYY]", width: 1.6in)
    , that there is probable cause and grounds for the issuance of
    this Search Warrant.
  ]
  v(0.4em)

  // ----- command + items list ---------------------------------------------
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

  // ----- handwritten fill-in fields ----------------------------------------
  [This warrant shall be served during the #fill-in(cfg.warrant-period, width: 1.6in, size: 14pt) .]
  v(0.4em)

  [
    DATED THIS #fill-in("[DD]", width: 0.5in) DAY OF
    #fill-in("[Month]", width: 1.1in) , #fill-in("[YYYY]", width: 0.6in) .
  ]
  v(0.3em)

  let split-time = if "warrant-time" in cfg and cfg.warrant-time != none {
    cfg.warrant-time
  } else { "" }
  let am-pm = if cfg.warrant-period == "DAYTIME" { "P" } else { "A" }
  [
    AT #fill-in(split-time, width: 0.8in) O'CLOCK
    #fill-in(am-pm, width: 0.4in) .M.
  ]

  v(0.7in)

  // ----- judge signature with seal ----------------------------------------
  judge-signature(
    signature-asset: cfg.judge-signature-asset,
    seal-asset: cfg.judge-seal-asset,
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
