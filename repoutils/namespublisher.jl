
"""Copy articles about divinities from offline directory
into published space.

$(SIGNATURES)
"""
function cp_articles(publisher::Publisher)
    divs = publisher.root * "/divinities-articles/"
    offlinedivs = publisher.root * "/offline/Divinities/"
    cp(divs, offlinedivs, force=true)
end


"""Publish articles on divinities by copying text from offline source,
and adding index of text passages for each named.

$(SIGNATURES)
"""    
function publisharticles(publisher::Publisher)
    target = publisher.root *  "/offline/Divinities/"
    cp_articles(publisher)
    c = xmlcorpus(publisher.editorsrepo)
    namesidx = indexnames(c)
    names_printindex(namesidx, target)
end


"""Format a single CTS URN as a markdown link to an edition
of that text.

$(SIGNATURES)
"""
function names_editionlink(u::CtsUrn)
    lnk = "../../Texts/" * workparts(u)[1] * "_" * workparts(u)[2]
    label = string("*", workparts(u)[1], "* ",workparts(u)[2],", ", passagecomponent(u) )
    "[" * label * "](" * lnk * ")"
end



"""Format a list of CTS URNs as a markdown list of links to editions
of those texts.

$(SIGNATURES)
"""
function names_mdlist(psgs)
    items = map(psg -> "- " * names_editionlink(psg), psgs)
    "\n\n## Appears in\n\n" * join(items, "\n")
end

"""For each divinity appearing as a key in `dict`, append 
to the offline article for that divinity links to texts 
where the divinity's name appears.

$(SIGNATURES)

Parameters

- `dict` is a dictionary using URN values for divinities as keys to CtsUrns for texts where that divinity appears
- `dir` is the target directory for articles about divinities
"""
function names_printindex(dict, dir)
    for k in keys(dict)
        u = Cite2Urn(k)
        fname = dir * objectcomponent(u) * "/index.md"
        println("Append names index to ", fname)
        md = names_mdlist(dict[k])
        open(fname, "a") do io
            print(io, md)
        end
    end
end