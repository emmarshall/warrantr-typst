// Warrant vignette — main library entry point.
//
// Re-exports the per-document-type renderers and the page-setup wrapper
// used by the Quarto integration. The library is consumed two ways:
//
//   1. Standalone Typst — call `warrant-packet()` directly with a
//      config dictionary, inside a `#set page(...)` context that
//      defines paper size and margins.
//
//   2. Via the Quarto extension (Phase 4) — the extension's
//      typst-template.typ wraps the user's .qmd content with an
//      automatic page setup and dispatches to the right document
//      renderer based on metadata.

#import "docs/affidavit.typ": affidavit
#import "docs/warrant.typ": warrant
#import "docs/return.typ": return-doc
#import "docs/attachment.typ": attachment
#import "exhibits/meta-records.typ": meta-records
#import "exhibits/text-messages.typ": text-messages
#import "exhibits/browser-history.typ": browser-history
#import "exhibits/photo-log.typ": photo-log
#import "exhibits/geofence-warrant.typ": geofence-warrant
#import "exhibits/geofence-anonymized.typ": geofence-anonymized
#import "exhibits/geofence-summary.typ": geofence-summary
#import "exhibits/geofence-subscriber.typ": geofence-subscriber
#import "exhibits/account-audit.typ": account-audit
#import "exhibits/location-timeline.typ": location-timeline
#import "exhibits/search-activity.typ": search-activity
#import "partials/util.typ": merge-config

#let _doc-renderer(name) = {
  let table = (
    "affidavit": affidavit,
    "warrant": warrant,
    "return": return-doc,
    "attachment": attachment,
  )
  if name in table {
    table.at(name)
  } else {
    panic("Unknown document type: " + name)
  }
}

// Map exhibit-type strings to the appropriate exhibit renderer.
#let _exhibit-renderer(name) = {
  let table = (
    "meta-records": meta-records,
    "facebook-messages": meta-records,        // alias
    "text-messages": text-messages,
    "sms": text-messages,                     // alias
    "browser-history": browser-history,
    "search-history": browser-history,        // alias
    "photo-log": photo-log,
    "photos": photo-log,                      // alias
    "evidence-photos": photo-log,             // alias
    "geofence-warrant": geofence-warrant,
    "geofence-anonymized": geofence-anonymized,
    "sensorvault-step1": geofence-anonymized, // alias
    "sensorvault-step2": geofence-anonymized, // alias
    "geofence-summary": geofence-summary,
    "geofence-subscriber": geofence-subscriber,
    "sensorvault-step3": geofence-subscriber, // alias
    "account-audit": account-audit,
    "location-timeline": location-timeline,
    "maps-timeline": location-timeline,       // alias
    "search-activity": search-activity,
    "my-activity": search-activity,           // alias
  )
  if name in table {
    table.at(name)
  } else {
    panic("Unknown exhibit type: " + name)
  }
}

// Public: render the exhibit indicated by user-config.exhibit-type
// using the records supplied in user-config.exhibit-records.
#let exhibit(user-config) = {
  let cfg = merge-config(user-config)
  let kind = cfg.at("exhibit-type", default: none)
  if kind == none {
    return
  }
  let records = cfg.at("exhibit-records", default: ())
  let renderer = _exhibit-renderer(kind)
  renderer(user-config, records: records)
}

// Public: page setup + document dispatch.
//
// `document-types` is an array of strings naming the documents to
// include. Each is rendered on its own pages, in order. Page breaks
// are inserted between document types.
#let warrant-packet(
  user-config: (:),
  document-types: ("affidavit",),
  paper: "us-letter",
  margin: (top: 0.6in, bottom: 0.7in, x: 0.85in),
  fontsize: 11pt,
  body-font: "Liberation Serif",
) = {
  set page(paper: paper, margin: margin)
  set text(font: body-font, size: fontsize)
  set par(first-line-indent: 0.25in, leading: 0.6em, justify: false)

  // Default headings off — court documents don't use the heading
  // hierarchy.
  set heading(numbering: none)

  let cfg = merge-config(user-config)

  for (i, doc-name) in document-types.enumerate() {
    if i > 0 {
      pagebreak()
    }
    if doc-name == "exhibit" {
      exhibit(user-config)
    } else {
      let renderer = _doc-renderer(doc-name)
      renderer(user-config)
    }
  }
}

// Re-exports
#let public = (
  warrant-packet: warrant-packet,
  affidavit: affidavit,
  warrant: warrant,
  return-doc: return-doc,
  attachment: attachment,
  exhibit: exhibit,
  meta-records: meta-records,
  text-messages: text-messages,
  browser-history: browser-history,
  photo-log: photo-log,
  geofence-warrant: geofence-warrant,
  geofence-anonymized: geofence-anonymized,
  geofence-summary: geofence-summary,
  geofence-subscriber: geofence-subscriber,
  account-audit: account-audit,
  location-timeline: location-timeline,
  search-activity: search-activity,
  merge-config: merge-config,
)
