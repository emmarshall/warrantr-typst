// Return and Inventory.
//
// Single-page post-execution document. Same header pattern, plus a
// "Case #" label in the top-right area. Body lists the items seized,
// notes who signed for the search-warrant copy, and ends with the
// applicant's signature, handwritten title, and a notary block.

#import "../partials/util.typ": handwritten, fill-in, merge-config
#import "../partials/caption.typ": caption-block
#import "../partials/header.typ": header-block
#import "../partials/signature.typ": applicant-block
#import "../partials/notary.typ": notary-block

#let _inventory-list(items) = {
  set par(first-line-indent: 0em)
  enum(
    indent: 0.4in,
    body-indent: 0.4em,
    spacing: 0.3em,
    ..items.map(it => it)
  )
}

// Public: full return and inventory.
#let return-doc(user-config) = {
  let cfg = merge-config(user-config)

  // The return-and-inventory header has a "Case #" label up top right
  // instead of the rotated clerk stamp. We render the standard header
  // first, then overlay the case number text in the top-right zone.
  header-block(cfg, document-title: "RETURN AND INVENTORY")
  place(top + right, dx: -0.1in, dy: 0.25in,
    text(size: 12pt, "Case #" + cfg.case-number))

  caption-block(
    state: cfg.state,
    county: cfg.county,
    title: "RETURN AND INVENTORY",
    title-size: 14pt,
  )
  v(0.4em)

  // ----- opening sworn-statement paragraph --------------------------------
  [
    THE UNDERSIGNED, being first duly sworn, upon oath says that on
    #fill-in("[Month DD, YYYY]", width: 1.6in)
    , at #fill-in("[H:MM]", width: 0.7in) o'clock
    #fill-in("[A/P]", width: 0.4in) .M., I executed the within warrant
    as directed there.
  ]
  v(0.5em)

  [
    I seized from the place described in said warrant the following
    described property of which I am now in possession.
  ]
  v(0.5em)

  // ----- inventory list ---------------------------------------------------
  _inventory-list(cfg.inventory-items)
  v(0.5em)

  // ----- closing service note ---------------------------------------------
  let service-recipient = if cfg.suspect-names.len() > 0 {
    cfg.suspect-names.at(0)
  } else { "[recipient]" }

  [
    A copy of the search warrant and an inventory of the items seized
    was signed for by #service-recipient and left on the dining room
    table at #cfg.search-address.
  ]
  v(0.6in)

  // ----- applicant signature + title + sworn line + notary -----------------
  applicant-block(
    signature-asset: cfg.detective-signature-asset,
    title-text: cfg.detective-name,
    subscribed-date: "[Month DD]",
    badge: cfg.detective-badge,
  )
  v(0.3in)

  notary-block(
    signature-asset: cfg.notary-signature-asset,
    stamp-asset: cfg.notary-stamp-asset,
  )
}
