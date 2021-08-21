
#=
function publishtexts(reporoot::AbstractString)
    lycpublisher(reporoot) |> publishtexts
end
=#

function publishtexts(publisher::Publisher)
    textcat = textcatalog(publisher.editorsrepo, "catalog.cex")
    online = filter(row -> row.online, textcat) 
    for txt in online
        publishtext(publisher, txt)
    end
end

"""Write web page for a single text.

- publisher: configured Publisher object
- catalogrow: a single row of DataFrame of DSE records for texts
"""
function publishtext(
    publisher,
    catalogrow;
    w = 100
    )
    urn = CtsUrn(catalogrow.urn) |> dropversion
    # Can directly extract diplomatic and normalized text from editors repo
    # by urn:
    dipl = diplomaticnodes(publisher.editorsrepo,urn)
    normed = normalizednodes(publisher.editorsrepo,urn)

    # Compute output file name
    citedf = citation_df(publisher.editorsrepo)
    fname = editionfile(catalogrow, publisher.target)

    # Compose linked images for passages:
    dse = dse_df(publisher.editorsrepo)
    rowmatches  = filter(dserow -> CitableText.urncontains(urn, dserow.passage), dse)
    linkedimgs = imgs_for_dse(rowmatches, dipl, publisher.ict, publisher.iiifsvc)

    # Compose markdown for page:
    top = yamlplus(catalogrow)
    urnlabel = string("`", catalogrow.urn, "`\n\n")
    document = join([top, urnlabel], "\n\n")    
    open(fname, "w") do io
        try 
            print(io, document, tablemarkdown(dipl, normed, linkedimgs))
        catch e
             groupurn = droppassage(dipl[1].urn)
             println("FAILED to write edition for ", groupurn, " with ", length(dipl), " diplomatic lines and ", length(linkedimgs), " DSE records." )
             msg = string(e)
             @warn(msg)
             #error(e)
        end
    end
    document
end


function imgs_for_dse(dserows, textnodes, ict, iiifsvc; w = 100)
    @info(string(length(textnodes), " text nodes and ", nrow(dserows), " dse rows."))
   
    linkedimgs = [] 
    if (length(textnodes) != nrow(dserows))
        for row in eachrow(dserows)
            push!(linkedimgs, "Invalid indexing of text to source images.")
            @info("Failure with dserow ", row.passage)
        end
    else 
  
        for row in eachrow(dserows)
           push!(linkedimgs, linkedMarkdownImage(ict, row.image, iiifsvc; ht=w, caption="image"))
        end
    end
    linkedimgs
end

"""Compose markdown string for page title

$(SIGNATURES)
"""
function mdtitle(csvrow)
    string("*", csvrow.groupName, "*, ", csvrow.workTitle)
end

# Compose title for use in yaml header
# (no markdown supported in yaml)
function shorttitle(csvrow)
    string("\"", csvrow.groupName, ", ", csvrow.workTitle, "\"")
end


# Compose yaml header and title header for page
function yamlplus(csvrow)
    title = shorttitle(csvrow)
    titlehdr = mdtitle(csvrow)
    lines = [
        "---",
        "title: " * title,
        "layout: page",
        "parent: Texts",
        "nav_order: " * csvrow.workTitle,
        "---",
        "\n\n",
        "# " * titlehdr,
        "\n\n"
    ]
    join(lines,"\n")
end


# Compose tabular display of editions
# from lists of citable nodes
function tablemarkdown(dipllist, normlist, linkedimages)
   
    diplitems = map(cn -> "| `" * passagecomponent(cn.urn) * "` | " * cn.text * " | " *  Lycian.ucode(cn.text) * " |", dipllist)
    illustrateddipl = []
    for i in 1:length(diplitems)
        push!(illustrateddipl, diplitems[i] *  linkedimages[i] * " |")
    end
    dipltable = [
        "|  | Transcription | Lycian | Image link |",
        "| :---: | :------ | :------ | --- |",
      
        join(illustrateddipl, "\n")
    ]

    normitems = map(cn -> "| `" * passagecomponent(cn.urn) * "` | " * cn.text * " | " *  Lycian.ucode(cn.text) * " |", normlist)
    normtable = [
        "|  | Transcription | Lycian |",
        "| :---: | :------ | :------ |",
        join(normitems, "\n")
    ]

    blocks = [
        "## Diplomatic edition",
        join(dipltable,"\n"),
        "## Normalized edition",
        join(normtable,"\n"),
    ]
    join(blocks, "\n\n")
end
