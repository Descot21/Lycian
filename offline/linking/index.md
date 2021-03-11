---
title: "Citation and linking"
layout: page
nav_order: 3
parent: "Home Page"
---

# Citation and linking
{: .no_toc }



All citable content in [the project github repository](../github/) is identified by URN.  This page explains how the URNs are mapped to URLs on this web site so that you can automatically link to content here, given a URN identifier.

All pages on the site also include a site-wide search box.  If you find a relevant text, article on a divinity, or lexicon entry by searching, you will see its URN displayed on the web page.  You can reliably link to these pages since the relation between URN and URL is predictable.


1. Content
{:toc}

## Summary examples

| Cited entity | URN | URL on this site |
| --- | --- | --- |
| The text *Tituli Lycii* 80 | `urn:cts:trmilli:tl.80:` |  <https://descot21.github.io/Lycian/Texts/tl_80/> |
| The goddess Maliya | `urn:cite2:trmilli:divinities.v1:div_03` | <https://descot21.github.io/Lycian/Divinities/div_03/> |
| The noun *tideimi-/*𐊗𐊆𐊅𐊁𐊆𐊎𐊆 | `urn:cite2:trmilli:lexicon.v1:m413` | <https://descot21.github.io/Lycian/Lexicon#m413> |

## Texts

There have been two major published collections of Lycian texts:  the *Tituli Lycii* series published by Kalinka in 1901, and the *Neufunde* published by Neumann in 1979.  Editions of this texts are in CTS text groups identified as:

- `urn:cts:trmilli:tl:` -- texts identifed in *Tituli Lycii*
- `urn:cts:trmilli:nf:` -- texts identifed in *Neufunde*

We use the numbers in those series as the work identifiers, so that an incription like *Tituli Lycii*, no. 80, will have the CTS URN `urn:cts:trmilli:tl.80:`.

Editions are in this site in the <https://descot21.github.io/Lycian/Texts/> section.  Individual texts are linked as `textgroup_work`, so that *Tituli Lycii* with the URN `urn:cts:trmilli:tl.80:` appears at <https://descot21.github.io/Lycian/Texts/tl_80/>.


## Divinities

Names of divinities in Lycian texts are identified by CITE2 URNs in the collection `urn:cite2:trmilli:divinities.v1:`.  Identifiers for individual divinities are defined in a delimited-text table [here](https://github.com/Descot21/Lycian/blob/master/datasets/divinities.cex). The goddess Maliya, for example, is assigned the URN `urn:cite2:trmilli:divinities.v1:div_03`.

Articles with automatically collated concordances to references in the text are in the <https://descot21.github.io/Lycian/Divinities> of this site.  Pages for  individual divinities are identified by the object identifier (final component) of the URN.  Maliya with the URN  `urn:cite2:trmilli:divinities.v1:div_03` can be found at <https://descot21.github.io/Lycian/Divinities/div_03/>.


## Lexicon

Lycian lexical entities are identified by CITE2 URNs in the collection `urn:cite2:trmilli:lexicon.v1:` in a delimited-text table [here](https://github.com/Descot21/Lycian/blob/master/lexicon/hc.cex). The noun *tideimi-/*𐊗𐊆𐊅𐊁𐊆𐊎𐊆, "son", has the URN `urn:cite2:trmilli:lexicon.v1:m413`, for example.

Entries giving a part of speech and brief definition are citable from the main lexicon page with the object identifer appended as an HTML anchor.  

*tideimi-/*𐊗𐊆𐊅𐊁𐊆𐊎𐊆, "son", with the URN `urn:cite2:trmilli:lexicon.v1:m413`, is linked to <https://descot21.github.io/Lycian/Lexicon#m413>, for example.
