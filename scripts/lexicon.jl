using Pkg
Pkg.activate(".")


using CSV
using CitableText
using DataFrames

root = dirname(pwd())
lexiconfile = root * "/lexicon/hc.cex"
offlinelex = root * "/offline/Lexicon/"

lexicon = CSV.File(lexiconfile, delim="|") |> Array
xcribed = filter(lex -> ! ismissing(lex.lemma), lexicon)

urns = map(l -> l.urn, xcribed)
lemmas = map(l -> l.lemma, xcribed)
xlits = map(l -> l.xlit, xcribed)
articles = map(l -> l.article, xcribed)
letters = map(l -> replace(l.lemma, "-" => "")[1], xcribed)

lexdf = DataFrame(letter = letters, urn = urns, lemma = lemmas, xlit = xlits, article = articles)
grouped = groupby(lexdf, :letter)


function yamlplus(ltr, xlit)
    lines = [
        "---",
        "title: " * string(ltr, " (", xlit, ")"),
        "layout:  page",
        "parent: Lexicon",
        "---",
        "\n\n",
        "# " * ltr,
        "\n\n"
    ]
    join(lines,"\n")
end


function outputfile(basedir, ltr)
    outputdir = string(basedir, ltr)
    if !isdir(outputdir)
        mkdir(outputdir)
    end
    outputdir * "/index.md"
end

function mdrow(entry)
    string("- ", entry.lemma, " (", entry.xlit, ") ", entry.article)
end

for k in keys(grouped)
    string(offlinelex, k.letter)
    
    entries = grouped[k]
    xlitletter =  grouped[1][1, :xlit][1]
    outfile = outputfile(offlinelex, string("Letter ", k.letter))
    top = yamlplus(k.letter, xlitletter)
    mdlines = []
    for entry in eachrow(entries)
        push!(mdlines, mdrow(entry))
        #println(mdrow(entry))
    end
    
    println("Writing to " * outfile)
    println("With ", length(mdlines), " lines of entries." )

    doc = top * join(mdlines,"\n")
    open(outfile, "w") do io
        try 
            print(io, doc)
        catch e
            println("Failed to write file " * outfile)
        end
    end 
end