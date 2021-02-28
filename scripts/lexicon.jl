using Pkg
Pkg.activate(".")


using CSV
using CitableText
using DataFrames

root = dirname(pwd())

function lexiconFile(basedir)
    basedir * "/lexicon/hc.cex"
end

function targetDir(basedir)
    basedir * "/offline/Lexicon/"
end


"Build a DataFrame for our lexicon data."
function loadLexiconDF(basedir)
    lexiconfile = lexiconFile(basedir)
    lexicon = CSV.File(lexiconfile, delim="|") |> Array
    xcribed = filter(lex -> ! ismissing(lex.lemma), lexicon)

    urns = map(l -> l.urn, xcribed)
    lemmas = map(l -> l.lemma, xcribed)
    xlits = map(l -> l.xlit, xcribed)
    articles = map(l -> l.article, xcribed)
    letters = map(l -> replace(l.lemma, "-" => "")[1], xcribed)

    DataFrame(letter = letters, urn = urns, lemma = lemmas, xlit = xlits, article = articles)
end



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


function printLetter(dictentries, outfile, letter)
    xlitletter =  dictentries[1, :xlit][1]
    
    top = yamlplus(letter, xlitletter)
    mdlines = []
    for entry in eachrow(dictentries)
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


function printLexicon(root)
    offlinelex = targetDir(root)

    # The lexicon
    lexdf = loadLexiconDF(root)
    # Grouped by letter
    grouped = groupby(lexdf, :letter)

    for k in keys(grouped)
        string(offlinelex, k.letter)
        entries = grouped[k]
        #xlitletter =  grouped[k][1, :xlit][1]
        outfile = outputfile(offlinelex, string("Letter ", k.letter))
        printLetter(entries, outfile, k.letter)
    end
end

