// Attachment cover sheet.
//
// One page. Centered "ATTACHMENT # N" title at the top, one descriptive
// paragraph below it, then the rest of the page is blank — the actual
// attached exhibit pages follow.

#import "../partials/util.typ": merge-config

// Public: attachment cover.
//
// The `number` argument is the attachment number ("# 1", "# 2", …) as
// it appears in the source document.
#let attachment(user-config, number: 1) = {
  let cfg = merge-config(user-config)

  v(0.6in)

  align(center, text(weight: "bold", size: 14pt)[ATTACHMENT \# #number])

  v(0.6in)

  // The descriptive paragraph names what the attachment is. The
  // exhibit-description field carries the per-condition copy.
  let description = if cfg.exhibit-description != "" {
    cfg.exhibit-description
  } else {
    "[Description of attached exhibit. The Typst layer sets " +
      "exhibit-description in the per-condition config to the appropriate " +
      "summary text — for example, 'Attached are printouts of the " +
      "conversation between [Suspect A] and [Suspect B] over [Platform] " +
      "concerning the [topic].']"
  }

  block(width: 100%, description)
}
