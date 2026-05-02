// Notary block — combines the notary's signature on a "Judge or Notary
// Public" line with the rectangular notary stamp positioned to the
// right of the line.
//
// In the source document, the word "Judge" is struck through with a
// pen line, leaving "Notary Public" as the active title. We replicate
// this with a strike-through over "Judge".

#import "util.typ": handwritten

#let notary-block(
  signature-asset: "",
  stamp-asset: "",
  width: 5in,
) = {
  align(left, box(width: width)[
    // Signature image rotated slightly, floating above the line
    #if signature-asset != "" {
      place(top + left, dx: 0.5in, dy: -0.25in,
        rotate(-1deg, image(signature-asset, width: 2.5in)))
    }
    #v(0.5in)
    #line(length: 4in)

    // The "Judge or Notary Public" caption — Judge is struck through
    #h(0.1in)
    #strike()[Judge or] Notary Public
    #v(0.1in)

    // Notary stamp — placed to the right, slightly rotated
    #if stamp-asset != "" {
      align(right,
        rotate(-2deg, reflow: true,
          image(stamp-asset, width: 2.6in)))
    }
  ])
}
