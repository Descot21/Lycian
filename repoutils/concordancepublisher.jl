
"""Write concordance of tokens to test web site in `offline` directory.

$(SIGNATURES)
"""
function publishconcordance(publisher::Publisher)
    @info("Composing concordance of all tokens in edition...")
    target = publisher.root * "/offline/Concordance/index.md" 
 
    # A CitableCorpus:
    indexable = normalcorpus(publisher.editorsrepo)
    # A GroupedDataFrame keyed by term
    idx = indexcorpus(indexable) 
    open(target, "w") do io
        print(io, conc_yamlplus(), conc_mdpage(idx))
    end
    @info("Written to ", target)
end


"""Compose markdown for a Lycian token in transcription and in Unicode.

$(SIGNATURES)
"""
function conc_mdrow(pr)
    hdg = "**" * pr[1] * "** (" * Lycian.ucode(pr[1]) * ")"
    
     hdg * ":  " * pr[2]
end


"""Compose link from Concordance page to a text identified by CTS URN.

$(SIGNATURES)
"""
function conc_editionlink(u::CtsUrn)
    lnk = "../Texts/" * workparts(u)[1] * "_" * workparts(u)[2]
    label = string("*", workparts(u)[1], "* ",workparts(u)[2],", ", passagecomponent(u) )
    "[" * label * "](" * lnk * ")"
end

"""Compose body of Concordance web page in markdown.

$(SIGNATURES)
"""
function conc_mdpage(idx)
    delimited = []
    for k in keys(idx)
        term = k.term
        vals = idx[k]
        urns = vals[!, :urn]
     
        urnlabels = map(u ->  conc_editionlink(u), urns)
        push!(delimited, term * "|" * join(urnlabels,"; "))
    end
    sorted = sort(delimited)
    paired = map(ln -> split(ln, "|"), sorted)
    rows = map(pr -> conc_mdrow(pr), paired)
    join(rows, "\n\n")
end

"""Compose YAML header for Concordance web page.

$(SIGNATURES)
"""
function conc_yamlplus()
    lines = [
        "---",
        "title: Concordance",
        "layout: page",
        "nav_order: 10",
        "---",
        "\n\n",
        "# Concordance of lexical tokens",
        "\n\n",
        """Hyphens indicate line breaks when lexical tokens 
        span more than one line.  References in the concordance
        are to the line where the lexical token begins.""",
        "\n\n"
    ]
    join(lines,"\n")
end