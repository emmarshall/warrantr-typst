// Sensorvault Step 3 subscriber / CSI return.
//
// Mimics the de-anonymized subscriber-information production Google
// returns after law enforcement has narrowed the device list:
// per-device key-value blocks listing subscriber name, account
// number, email addresses, device make / model / IMEI, telephone
// numbers, and Google Voice numbers. Page header carries the
// Google brand bar.
//
// Records: each record is a dict for one subscriber with keys
//   subscriber-name      (str)
//   account-number       (str)
//   account-created      (str, optional)
//   emails               array of str (or comma-separated str)
//   device-make-model    (str)
//   device-imei          (str, optional)
//   phone-numbers        array of str (or comma-separated str)
//   google-voice         (str, optional)
//
// CANONICAL SOURCE -- also inlined into ../typst-template.typ via
// R/build_exhibits.R. Edit here, then re-run that script.

#import "../partials/util.typ": merge-config

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
