
function publishconcordance(reporoot)
    target = reporoot * "/offline/Concordance/index.md" 
    repo = repository(reporoot)
    # A CitableCorpus:
    indexable = normalcorpus(repo)
    # A GroupedDataFrame keyed by term
    idx = indexcorpus(indexable) 
    open(target, "w") do io
        print(io, conc_yamlplus(), conc_mdpage(idx))
    end
end

function conc_mdrow(pr)
    hdg = "**" * pr[1] * "** (" * Lycian.ucode(pr[1]) * ")"
    
     hdg * ":  " * pr[2]
end

function conc_editionlink(u::CtsUrn)
    lnk = "../Texts/" * workparts(u)[1] * "_" * workparts(u)[2]
    label = string("*", workparts(u)[1], "* ",workparts(u)[2],", ", passagecomponent(u) )
    "[" * label * "](" * lnk * ")"
end

"""
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