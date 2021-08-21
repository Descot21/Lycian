"""Publish Lycian lexicon as a series of individual pages, one for
each letter of the Lycian alphabet.

$(SIGNATURES)
"""
function publishlexicon(publisher::Publisher)    
    target = publisher.root * "/offline/Lexicon/"
    lexdf = loadLexiconDF(publisher)
    grouped = groupby(lexdf, :letter)
    sequenceDict = LycianUtils.alphabetize(lexdf)

    for k in keys(grouped)
        string(target, k.letter)
        entries = grouped[k]

        str = entries[1,:xlit]
        seq = sequenceDict[LycianUtils.initialAlpha(lowercase(str))]
        outfile = LycianUtils.outputfile(target, string("Letter ", k.letter))
        @info(outfile)
        LycianUtils.writeLetter(entries, outfile, k.letter, seq)
    end
end



"""Build a DataFrame for our lexicon data.

$(SIGNATURES)
"""
function loadLexiconDF(publisher::Publisher)
    src = publisher.root *  "/lexicon/hc.cex"
    lexicon = CSV.File(src, delim="|") |> Array
    xcribed = filter(lex -> ! ismissing(lex.lemma), lexicon)

    urns = map(l -> l.urn, xcribed)
    lemmas = map(l -> l.lemma, xcribed)
    xlits = map(l -> l.xlit, xcribed)
    articles = map(l -> l.article, xcribed)
    letters = map(l -> replace(l.lemma, "-" => "")[1], xcribed)

    DataFrame(letter = letters, urn = urns, lemma = lemmas, xlit = xlits, article = articles)
end

"""Compose YAML header for the page in the lexicon for a single letter.

$(SIGNATURES)
"""
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


"""Construct full path to output file for a lexicon entry.

$(SIGNATURES)
"""
function outputfile(basedir, ltr)
    outputdir = string(basedir, ltr)
    if !isdir(outputdir)
        mkdir(outputdir)
    end
    outputdir * "/index.md"
end


"""Compose markdown lexicon entry for a single article.

$(SIGNATURES)
"""
function mdrow(entry)
    string("- ", entry.lemma, " (", entry.xlit, ") ", entry.article, " `", entry.urn, "`")
end


"""Write lexicon file for given letter.

$(SIGNATURES)
"""
function writeLetter(dictentries, outfile, letter, sequenceNum)
    rawlemma =  replace(dictentries[1, :xlit], "-" => "")
    xlitletter = rawlemma[1]

    top = yamlplus(letter, xlitletter, sequenceNum)
    mdlines = []
    for entry in eachrow(dictentries)
        push!(mdlines, mdrow(entry))
    end
    
    #@info("Writing to " * outfile, " with ", length(mdlines), " lines of entries." )
    doc = top * join(mdlines,"\n")
    open(outfile, "w") do io
        try 
            print(io, doc)
        catch e
            @warn("Failed to write file " * outfile)
        end
    end 
end



"""Alphabetize entries in DataFrame according to Lycian alphabet.

$(SIGNATURES)
"""
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

"""Extract initial alphabetic character from markdown list item.

$(SIGNATURES)
"""
function initialAlpha(s)
    replace(s, r"[-([]" => "")[1]
end

"""Comose markdown header for lexicon entry.

$(SIGNATURES)
"""
function entryhdr(row)
    id = Cite2Urn(row.urn) |> objectcomponent
    string("### ", id)
end


#=
function singleyaml() 
    lines = [
        "---",
        "title: \"Lexicon\"",
        "layout:  page",
        "has_children: true",   
        "nav_order: 30",
        "---",
        "\n\n",
        "# Lexicon",
        "{: .no_toc }",
        "\n\n"
    ]
    join(lines, "\n")  
end
=#





