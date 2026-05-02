// Quarto pastes this partial into the generated .typ file AFTER the
// article() definition from typst-template.typ. The show-rule below
// is what actually invokes article() with the YAML metadata pulled
// into named arguments. Without this rule, article() is defined but
// never called and the rendered PDF is blank.
//
// (Comments here cannot reference Pandoc template tokens because
// Pandoc parses template syntax even inside Typst comments.)

#show: doc => article(
$if(title)$
  title: [$title$],
$endif$
$if(subtitle)$
  subtitle: [$subtitle$],
$endif$
$if(by-author)$
  authors: (
$for(by-author)$
$if(it.name.literal)$
    ( name: [$it.name.literal$], ),
$endif$
$endfor$
  ),
$endif$
$if(date)$
  date: [$date$],
$endif$
$if(lang)$
  lang: "$lang$",
$endif$
$if(region)$
  region: "$region$",
$endif$
$if(margin)$
  margin: ($for(margin/pairs)$$margin.key$: $margin.value$,$endfor$),
$endif$
$if(papersize)$
  paper: "$papersize$",
$endif$
$if(mainfont)$
  font: ("$mainfont$",),
$endif$
$if(fontsize)$
  fontsize: $fontsize$,
$endif$
  cols: $if(columns)$$columns$$else$1$endif$,

  // ---- warrant-vignette metadata -----------------------------------------
$if(document-types)$
  document-types: ($for(document-types)$"$it$",$endfor$),
$endif$
$if(case-number)$
  case-number: "$case-number$",
$endif$
$if(case-id-barcode)$
  case-id-barcode: "$case-id-barcode$",
$endif$
$if(filed-date)$
  filed-date: "$filed-date$",
$endif$
$if(filed-time)$
  filed-time: "$filed-time$",
$endif$
$if(warrant-time)$
  warrant-time: "$warrant-time$",
$endif$
$if(warrant-period)$
  warrant-period: "$warrant-period$",
$endif$
$if(state)$
  state: "$state$",
$endif$
$if(county)$
  county: "$county$",
$endif$
$if(city)$
  city: "$city$",
$endif$
$if(court-name)$
  court-name: "$court-name$",
$endif$
$if(judicial-district)$
  judicial-district: "$judicial-district$",
$endif$
$if(clerk-name)$
  clerk-name: "$clerk-name$",
$endif$
$if(judge-name)$
  judge-name: "$judge-name$",
$endif$
$if(judge-title-full)$
  judge-title-full: "$judge-title-full$",
$endif$
$if(detective-name)$
  detective-name: "$detective-name$",
$endif$
$if(detective-badge)$
  detective-badge: "$detective-badge$",
$endif$
$if(detective-unit)$
  detective-unit: "$detective-unit$",
$endif$
$if(detective-division)$
  detective-division: "$detective-division$",
$endif$
$if(detective-years)$
  detective-years: $detective-years$,
$endif$
$if(notary-name)$
  notary-name: "$notary-name$",
$endif$
$if(notary-commission-exp)$
  notary-commission-exp: "$notary-commission-exp$",
$endif$
$if(search-address)$
  search-address: "$search-address$",
$endif$
$if(property-description)$
  property-description: "$property-description$",
$endif$
$if(suspect-names)$
  suspect-names: ($for(suspect-names)$"$it$",$endfor$),
$endif$
$if(items-to-seize)$
  items-to-seize: ($for(items-to-seize)$[$it$],$endfor$),
$endif$
$if(narrative-paragraphs)$
  narrative-paragraphs: ($for(narrative-paragraphs)$[$it$],$endfor$),
$endif$
$if(inventory-items)$
  inventory-items: ($for(inventory-items)$"$it$",$endfor$),
$endif$
$if(exhibit-type)$
  exhibit-type: "$exhibit-type$",
$endif$
$if(exhibit-description)$
  exhibit-description: [$exhibit-description$],
$endif$
$if(exhibit-starting-page)$
  exhibit-starting-page: $exhibit-starting-page$,
$endif$
$if(exhibit-title)$
  exhibit-title: "$exhibit-title$",
$endif$
$if(exhibit-device)$
  exhibit-device: "$exhibit-device$",
$endif$
$if(exhibit-columns)$
  exhibit-columns: $exhibit-columns$,
$endif$
$if(defendant-name)$
  defendant-name: "$defendant-name$",
$endif$
$if(charging-document-type)$
  charging-document-type: "$charging-document-type$",
$endif$
$if(charges-description)$
  charges-description: ($for(charges-description)$[$it$],$endfor$),
$endif$
$if(arrest-received-date)$
  arrest-received-date: "$arrest-received-date$",
$endif$
$if(arrest-date)$
  arrest-date: "$arrest-date$",
$endif$
$if(arrest-location)$
  arrest-location: "$arrest-location$",
$endif$
$if(arresting-officer-name)$
  arresting-officer-name: "$arresting-officer-name$",
$endif$
$if(arresting-officer-title)$
  arresting-officer-title: "$arresting-officer-title$",
$endif$
$if(exhibit-records)$
  exhibit-records: (
$for(exhibit-records)$
    (
$if(it.author)$      author: "$it.author$",
$endif$$if(it.account)$      account: "$it.account$",
$endif$$if(it.sent)$      sent: "$it.sent$",
$endif$$if(it.sender)$      sender: "$it.sender$",
$endif$$if(it.timestamp)$      timestamp: "$it.timestamp$",
$endif$$if(it.direction)$      direction: "$it.direction$",
$endif$$if(it.body)$      body: "$it.body$",
$endif$$if(it.type)$      type: "$it.type$",
$endif$$if(it.query)$      query: "$it.query$",
$endif$$if(it.url)$      url: "$it.url$",
$endif$$if(it.title)$      title: "$it.title$",
$endif$$if(it.source)$      source: "$it.source$",
$endif$$if(it.item-id)$      item-id: "$it.item-id$",
$endif$$if(it.path)$      path: "$it.path$",
$endif$$if(it.description)$      description: "$it.description$",
$endif$$if(it.caption)$      caption: "$it.caption$",
$endif$$if(it.photographer)$      photographer: "$it.photographer$",
$endif$$if(it.officer)$      officer: "$it.officer$",
$endif$    ),
$endfor$
  ),
$endif$
$if(exhibits)$
  exhibits: (
$for(exhibits)$
    (
$if(it.exhibit-type)$      exhibit-type: "$it.exhibit-type$",
$endif$$if(it.exhibit-title)$      exhibit-title: "$it.exhibit-title$",
$endif$$if(it.exhibit-device)$      exhibit-device: "$it.exhibit-device$",
$endif$$if(it.exhibit-description)$      exhibit-description: [$it.exhibit-description$],
$endif$$if(it.exhibit-starting-page)$      exhibit-starting-page: $it.exhibit-starting-page$,
$endif$$if(it.exhibit-columns)$      exhibit-columns: $it.exhibit-columns$,
$endif$$if(it.exhibit-records)$      exhibit-records: (
$for(it.exhibit-records)$
        (
$if(it.author)$          author: "$it.author$",
$endif$$if(it.account)$          account: "$it.account$",
$endif$$if(it.sent)$          sent: "$it.sent$",
$endif$$if(it.sender)$          sender: "$it.sender$",
$endif$$if(it.timestamp)$          timestamp: "$it.timestamp$",
$endif$$if(it.direction)$          direction: "$it.direction$",
$endif$$if(it.body)$          body: "$it.body$",
$endif$$if(it.type)$          type: "$it.type$",
$endif$$if(it.query)$          query: "$it.query$",
$endif$$if(it.url)$          url: "$it.url$",
$endif$$if(it.title)$          title: "$it.title$",
$endif$$if(it.source)$          source: "$it.source$",
$endif$$if(it.item-id)$          item-id: "$it.item-id$",
$endif$$if(it.path)$          path: "$it.path$",
$endif$$if(it.description)$          description: "$it.description$",
$endif$$if(it.caption)$          caption: "$it.caption$",
$endif$$if(it.photographer)$          photographer: "$it.photographer$",
$endif$$if(it.officer)$          officer: "$it.officer$",
$endif$        ),
$endfor$
      ),
$endif$    ),
$endfor$
  ),
$endif$
  doc,
)
