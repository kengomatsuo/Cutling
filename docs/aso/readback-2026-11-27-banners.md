# Banner readback, 2026-11-27

Header (PRODUCT_PAGE_HEADER_ASSET) and search (APP_STORE_SEARCH_RESULTS_ASSET) banners on Cutling 2.0, read from App Store Connect with `undirect/Support/AppStore/banner.py show` after placing. Every localization shows its own page's banner in its own language in both spots: 2.0.0 50/50, custom page versions 112/112. They go to App Review with 2.0.0 and the page versions; the live 1.6.2 keeps the creative3 keyboard banner until then.

Source: `fastlane/compose/creative/cpp/banners.py <page> --all` (out/banners/<page>/<locale>.png, 5244x2950, no alpha). Upload: `banner.py upload 6759476314 <prefix> 'out/banners/<page>/{locale}.png'`, then `banner.py place 6759476314 <prefix> version|page <id>`.

| Surface | Id | Prefix | Localizations |
|---|---|---|---|
| 2.0.0 (main page, Don't type it) | 571874b5-db30-408f-b7b3-77b0df238476 | creative5-main | 50 |
| Personal details v2 | 80b65655-d7ea-4b16-812a-3eeba84b9e91 | creative4-pd | 50 |
| Quick replies v2 | d463c66b-b6b3-4a9c-9059-b2252e895cfb | creative4-qr | 50 |
| Text expander | 6d9b1e05-e98b-4c74-8aef-c27d4768f4b5 | creative4-te | 4 |
| Clipboard history | 290bdd1d-9903-407e-87a0-1af82f35242c | creative4-ch | 4 |
| Notes you paste | e28d5f7c-d8e9-4a4e-9005-a8942c4241a5 | creative4-np | 4 |

creative4-main (the render whose key rows ran off the bottom in about 20 languages) sits unused in the asset library.

## 2.0.0

```
ar-SA PRODUCT=creative5-main-ar-SA SEARCH=creative5-main-ar-SA
bn-BD PRODUCT=creative5-main-bn-BD SEARCH=creative5-main-bn-BD
ca PRODUCT=creative5-main-ca SEARCH=creative5-main-ca
cs PRODUCT=creative5-main-cs SEARCH=creative5-main-cs
da PRODUCT=creative5-main-da SEARCH=creative5-main-da
de-DE PRODUCT=creative5-main-de-DE SEARCH=creative5-main-de-DE
el PRODUCT=creative5-main-el SEARCH=creative5-main-el
en-AU PRODUCT=creative5-main-en-AU SEARCH=creative5-main-en-AU
en-CA PRODUCT=creative5-main-en-CA SEARCH=creative5-main-en-CA
en-GB PRODUCT=creative5-main-en-GB SEARCH=creative5-main-en-GB
en-US PRODUCT=creative5-main-en-US SEARCH=creative5-main-en-US
es-ES PRODUCT=creative5-main-es-ES SEARCH=creative5-main-es-ES
es-MX PRODUCT=creative5-main-es-MX SEARCH=creative5-main-es-MX
fi PRODUCT=creative5-main-fi SEARCH=creative5-main-fi
fr-CA PRODUCT=creative5-main-fr-CA SEARCH=creative5-main-fr-CA
fr-FR PRODUCT=creative5-main-fr-FR SEARCH=creative5-main-fr-FR
gu-IN PRODUCT=creative5-main-gu-IN SEARCH=creative5-main-gu-IN
he PRODUCT=creative5-main-he SEARCH=creative5-main-he
hi PRODUCT=creative5-main-hi SEARCH=creative5-main-hi
hr PRODUCT=creative5-main-hr SEARCH=creative5-main-hr
hu PRODUCT=creative5-main-hu SEARCH=creative5-main-hu
id PRODUCT=creative5-main-id SEARCH=creative5-main-id
it PRODUCT=creative5-main-it SEARCH=creative5-main-it
ja PRODUCT=creative5-main-ja SEARCH=creative5-main-ja
kn-IN PRODUCT=creative5-main-kn-IN SEARCH=creative5-main-kn-IN
ko PRODUCT=creative5-main-ko SEARCH=creative5-main-ko
ml-IN PRODUCT=creative5-main-ml-IN SEARCH=creative5-main-ml-IN
mr-IN PRODUCT=creative5-main-mr-IN SEARCH=creative5-main-mr-IN
ms PRODUCT=creative5-main-ms SEARCH=creative5-main-ms
nl-NL PRODUCT=creative5-main-nl-NL SEARCH=creative5-main-nl-NL
no PRODUCT=creative5-main-no SEARCH=creative5-main-no
or-IN PRODUCT=creative5-main-or-IN SEARCH=creative5-main-or-IN
pa-IN PRODUCT=creative5-main-pa-IN SEARCH=creative5-main-pa-IN
pl PRODUCT=creative5-main-pl SEARCH=creative5-main-pl
pt-BR PRODUCT=creative5-main-pt-BR SEARCH=creative5-main-pt-BR
pt-PT PRODUCT=creative5-main-pt-PT SEARCH=creative5-main-pt-PT
ro PRODUCT=creative5-main-ro SEARCH=creative5-main-ro
ru PRODUCT=creative5-main-ru SEARCH=creative5-main-ru
sk PRODUCT=creative5-main-sk SEARCH=creative5-main-sk
sl-SI PRODUCT=creative5-main-sl-SI SEARCH=creative5-main-sl-SI
sv PRODUCT=creative5-main-sv SEARCH=creative5-main-sv
ta-IN PRODUCT=creative5-main-ta-IN SEARCH=creative5-main-ta-IN
te-IN PRODUCT=creative5-main-te-IN SEARCH=creative5-main-te-IN
th PRODUCT=creative5-main-th SEARCH=creative5-main-th
tr PRODUCT=creative5-main-tr SEARCH=creative5-main-tr
uk PRODUCT=creative5-main-uk SEARCH=creative5-main-uk
ur-PK PRODUCT=creative5-main-ur-PK SEARCH=creative5-main-ur-PK
vi PRODUCT=creative5-main-vi SEARCH=creative5-main-vi
zh-Hans PRODUCT=creative5-main-zh-Hans SEARCH=creative5-main-zh-Hans
zh-Hant PRODUCT=creative5-main-zh-Hant SEARCH=creative5-main-zh-Hant
```

## Custom product pages

```
== personal-details (80b65655-d7ea-4b16-812a-3eeba84b9e91)
ar-SA PRODUCT=creative4-pd-ar-SA SEARCH=creative4-pd-ar-SA
bn-BD PRODUCT=creative4-pd-bn-BD SEARCH=creative4-pd-bn-BD
ca PRODUCT=creative4-pd-ca SEARCH=creative4-pd-ca
cs PRODUCT=creative4-pd-cs SEARCH=creative4-pd-cs
da PRODUCT=creative4-pd-da SEARCH=creative4-pd-da
de-DE PRODUCT=creative4-pd-de-DE SEARCH=creative4-pd-de-DE
el PRODUCT=creative4-pd-el SEARCH=creative4-pd-el
en-AU PRODUCT=creative4-pd-en-AU SEARCH=creative4-pd-en-AU
en-CA PRODUCT=creative4-pd-en-CA SEARCH=creative4-pd-en-CA
en-GB PRODUCT=creative4-pd-en-GB SEARCH=creative4-pd-en-GB
en-US PRODUCT=creative4-pd-en-US SEARCH=creative4-pd-en-US
es-ES PRODUCT=creative4-pd-es-ES SEARCH=creative4-pd-es-ES
es-MX PRODUCT=creative4-pd-es-MX SEARCH=creative4-pd-es-MX
fi PRODUCT=creative4-pd-fi SEARCH=creative4-pd-fi
fr-CA PRODUCT=creative4-pd-fr-CA SEARCH=creative4-pd-fr-CA
fr-FR PRODUCT=creative4-pd-fr-FR SEARCH=creative4-pd-fr-FR
gu-IN PRODUCT=creative4-pd-gu-IN SEARCH=creative4-pd-gu-IN
he PRODUCT=creative4-pd-he SEARCH=creative4-pd-he
hi PRODUCT=creative4-pd-hi SEARCH=creative4-pd-hi
hr PRODUCT=creative4-pd-hr SEARCH=creative4-pd-hr
hu PRODUCT=creative4-pd-hu SEARCH=creative4-pd-hu
id PRODUCT=creative4-pd-id SEARCH=creative4-pd-id
it PRODUCT=creative4-pd-it SEARCH=creative4-pd-it
ja PRODUCT=creative4-pd-ja SEARCH=creative4-pd-ja
kn-IN PRODUCT=creative4-pd-kn-IN SEARCH=creative4-pd-kn-IN
ko PRODUCT=creative4-pd-ko SEARCH=creative4-pd-ko
ml-IN PRODUCT=creative4-pd-ml-IN SEARCH=creative4-pd-ml-IN
mr-IN PRODUCT=creative4-pd-mr-IN SEARCH=creative4-pd-mr-IN
ms PRODUCT=creative4-pd-ms SEARCH=creative4-pd-ms
nl-NL PRODUCT=creative4-pd-nl-NL SEARCH=creative4-pd-nl-NL
no PRODUCT=creative4-pd-no SEARCH=creative4-pd-no
or-IN PRODUCT=creative4-pd-or-IN SEARCH=creative4-pd-or-IN
pa-IN PRODUCT=creative4-pd-pa-IN SEARCH=creative4-pd-pa-IN
pl PRODUCT=creative4-pd-pl SEARCH=creative4-pd-pl
pt-BR PRODUCT=creative4-pd-pt-BR SEARCH=creative4-pd-pt-BR
pt-PT PRODUCT=creative4-pd-pt-PT SEARCH=creative4-pd-pt-PT
ro PRODUCT=creative4-pd-ro SEARCH=creative4-pd-ro
ru PRODUCT=creative4-pd-ru SEARCH=creative4-pd-ru
sk PRODUCT=creative4-pd-sk SEARCH=creative4-pd-sk
sl-SI PRODUCT=creative4-pd-sl-SI SEARCH=creative4-pd-sl-SI
sv PRODUCT=creative4-pd-sv SEARCH=creative4-pd-sv
ta-IN PRODUCT=creative4-pd-ta-IN SEARCH=creative4-pd-ta-IN
te-IN PRODUCT=creative4-pd-te-IN SEARCH=creative4-pd-te-IN
th PRODUCT=creative4-pd-th SEARCH=creative4-pd-th
tr PRODUCT=creative4-pd-tr SEARCH=creative4-pd-tr
uk PRODUCT=creative4-pd-uk SEARCH=creative4-pd-uk
ur-PK PRODUCT=creative4-pd-ur-PK SEARCH=creative4-pd-ur-PK
vi PRODUCT=creative4-pd-vi SEARCH=creative4-pd-vi
zh-Hans PRODUCT=creative4-pd-zh-Hans SEARCH=creative4-pd-zh-Hans
zh-Hant PRODUCT=creative4-pd-zh-Hant SEARCH=creative4-pd-zh-Hant
== quick-replies (d463c66b-b6b3-4a9c-9059-b2252e895cfb)
ar-SA PRODUCT=creative4-qr-ar-SA SEARCH=creative4-qr-ar-SA
bn-BD PRODUCT=creative4-qr-bn-BD SEARCH=creative4-qr-bn-BD
ca PRODUCT=creative4-qr-ca SEARCH=creative4-qr-ca
cs PRODUCT=creative4-qr-cs SEARCH=creative4-qr-cs
da PRODUCT=creative4-qr-da SEARCH=creative4-qr-da
de-DE PRODUCT=creative4-qr-de-DE SEARCH=creative4-qr-de-DE
el PRODUCT=creative4-qr-el SEARCH=creative4-qr-el
en-AU PRODUCT=creative4-qr-en-AU SEARCH=creative4-qr-en-AU
en-CA PRODUCT=creative4-qr-en-CA SEARCH=creative4-qr-en-CA
en-GB PRODUCT=creative4-qr-en-GB SEARCH=creative4-qr-en-GB
en-US PRODUCT=creative4-qr-en-US SEARCH=creative4-qr-en-US
es-ES PRODUCT=creative4-qr-es-ES SEARCH=creative4-qr-es-ES
es-MX PRODUCT=creative4-qr-es-MX SEARCH=creative4-qr-es-MX
fi PRODUCT=creative4-qr-fi SEARCH=creative4-qr-fi
fr-CA PRODUCT=creative4-qr-fr-CA SEARCH=creative4-qr-fr-CA
fr-FR PRODUCT=creative4-qr-fr-FR SEARCH=creative4-qr-fr-FR
gu-IN PRODUCT=creative4-qr-gu-IN SEARCH=creative4-qr-gu-IN
he PRODUCT=creative4-qr-he SEARCH=creative4-qr-he
hi PRODUCT=creative4-qr-hi SEARCH=creative4-qr-hi
hr PRODUCT=creative4-qr-hr SEARCH=creative4-qr-hr
hu PRODUCT=creative4-qr-hu SEARCH=creative4-qr-hu
id PRODUCT=creative4-qr-id SEARCH=creative4-qr-id
it PRODUCT=creative4-qr-it SEARCH=creative4-qr-it
ja PRODUCT=creative4-qr-ja SEARCH=creative4-qr-ja
kn-IN PRODUCT=creative4-qr-kn-IN SEARCH=creative4-qr-kn-IN
ko PRODUCT=creative4-qr-ko SEARCH=creative4-qr-ko
ml-IN PRODUCT=creative4-qr-ml-IN SEARCH=creative4-qr-ml-IN
mr-IN PRODUCT=creative4-qr-mr-IN SEARCH=creative4-qr-mr-IN
ms PRODUCT=creative4-qr-ms SEARCH=creative4-qr-ms
nl-NL PRODUCT=creative4-qr-nl-NL SEARCH=creative4-qr-nl-NL
no PRODUCT=creative4-qr-no SEARCH=creative4-qr-no
or-IN PRODUCT=creative4-qr-or-IN SEARCH=creative4-qr-or-IN
pa-IN PRODUCT=creative4-qr-pa-IN SEARCH=creative4-qr-pa-IN
pl PRODUCT=creative4-qr-pl SEARCH=creative4-qr-pl
pt-BR PRODUCT=creative4-qr-pt-BR SEARCH=creative4-qr-pt-BR
pt-PT PRODUCT=creative4-qr-pt-PT SEARCH=creative4-qr-pt-PT
ro PRODUCT=creative4-qr-ro SEARCH=creative4-qr-ro
ru PRODUCT=creative4-qr-ru SEARCH=creative4-qr-ru
sk PRODUCT=creative4-qr-sk SEARCH=creative4-qr-sk
sl-SI PRODUCT=creative4-qr-sl-SI SEARCH=creative4-qr-sl-SI
sv PRODUCT=creative4-qr-sv SEARCH=creative4-qr-sv
ta-IN PRODUCT=creative4-qr-ta-IN SEARCH=creative4-qr-ta-IN
te-IN PRODUCT=creative4-qr-te-IN SEARCH=creative4-qr-te-IN
th PRODUCT=creative4-qr-th SEARCH=creative4-qr-th
tr PRODUCT=creative4-qr-tr SEARCH=creative4-qr-tr
uk PRODUCT=creative4-qr-uk SEARCH=creative4-qr-uk
ur-PK PRODUCT=creative4-qr-ur-PK SEARCH=creative4-qr-ur-PK
vi PRODUCT=creative4-qr-vi SEARCH=creative4-qr-vi
zh-Hans PRODUCT=creative4-qr-zh-Hans SEARCH=creative4-qr-zh-Hans
zh-Hant PRODUCT=creative4-qr-zh-Hant SEARCH=creative4-qr-zh-Hant
== text-expander (6d9b1e05-e98b-4c74-8aef-c27d4768f4b5)
en-AU PRODUCT=creative4-te-en-AU SEARCH=creative4-te-en-AU
en-CA PRODUCT=creative4-te-en-CA SEARCH=creative4-te-en-CA
en-GB PRODUCT=creative4-te-en-GB SEARCH=creative4-te-en-GB
en-US PRODUCT=creative4-te-en-US SEARCH=creative4-te-en-US
== clipboard-history (290bdd1d-9903-407e-87a0-1af82f35242c)
en-AU PRODUCT=creative4-ch-en-AU SEARCH=creative4-ch-en-AU
en-CA PRODUCT=creative4-ch-en-CA SEARCH=creative4-ch-en-CA
en-GB PRODUCT=creative4-ch-en-GB SEARCH=creative4-ch-en-GB
en-US PRODUCT=creative4-ch-en-US SEARCH=creative4-ch-en-US
== notes-you-paste (e28d5f7c-d8e9-4a4e-9005-a8942c4241a5)
en-AU PRODUCT=creative4-np-en-AU SEARCH=creative4-np-en-AU
en-CA PRODUCT=creative4-np-en-CA SEARCH=creative4-np-en-CA
en-GB PRODUCT=creative4-np-en-GB SEARCH=creative4-np-en-GB
en-US PRODUCT=creative4-np-en-US SEARCH=creative4-np-en-US
```
