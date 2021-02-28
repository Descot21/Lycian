using Pkg
Pkg.activate(".")


using CSV
using CitableObject
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

function yamlplus(ltr, xlit, seq)
    lines = [
        "---",
        "title: " * string(ltr, " (", xlit, ")"),
        "layout:  page",
        "parent: Lexicon",
        "nav_order: " * string(seq),
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
    string("- ", entry.lemma, " (", entry.xlit, ") ", entry.article, " `", entry.urn, "`")
end


function printLetter(dictentries, outfile, letter, sequenceNum)
    rawlemma =  replace(dictentries[1, :xlit], "-" => "")
    xlitletter = rawlemma[1]

    top = yamlplus(letter, xlitletter, sequenceNum)
    mdlines = []
    for entry in eachrow(dictentries)
        push!(mdlines, mdrow(entry))
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

function alphabetize(lexdf)
    xlits = lexdf[:, :xlit]
    nohyphens = map(x -> replace(x, r"[-([]" => ""), xlits)
    sortedvalues = map(wd -> lowercase(wd[1]), nohyphens) |> unique |> sort
    dict = Dict{Char, Int}()
    for n in 1:length(sortedvalues)
        push!(dict, sortedvalues[n] => n)
    end
    dict
end

function initialAlpha(s)
    replace(s, r"[-([]" => "")[1]
end

function printLexicon(root)
    offlinelex = targetDir(root)
    
    # The lexicon
    lexdf = loadLexiconDF(root)
    # Grouped by letter
    grouped = groupby(lexdf, :letter)
    sequenceDict = alphabetize(lexdf)

    for k in keys(grouped)
        string(offlinelex, k.letter)
        entries = grouped[k]

        str = entries[1,:xlit]
        seq = sequenceDict[initialAlpha(lowercase(str))]
        outfile = outputfile(offlinelex, string("Letter ", k.letter))
        printLetter(entries, outfile, k.letter, seq)
    end
end


function singleyaml() 
    lines = [
        "---",
        "title: \"Lexicon\"",
        "layout:  page",
        "has_children: true",   
        "nav_order: 100",
        "---",
        "\n\n",
        "# Lexicon",
        "{: .no_toc }",
        "\n\n"
    ]
    join(lines, "\n")  
end

function entryhdr(row)
    id = Cite2Urn(row.urn) |> objectcomponent
    string("### ", id)
end


function singleLexicon(root)
    offlinelex = targetDir(root) 
    # The lexicon
    lexdf = loadLexiconDF(root)

    rows = []
    for r in eachrow(lexdf)
        # Figure out the nav link stuff!
        push!(rows, entryhdr(r))
        push!(rows, mdrow(r))
    end

    tail = "1. Contents\n{:toc}\n"
    doc = string(singleyaml(), join(rows, "\n\n"), "\n\n", tail)

    offlinelex = targetDir(root)
    outfile = offlinelex * "/index.md"
    

    open(outfile, "w") do io
        print(io, doc)
    end 
end