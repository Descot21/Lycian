


function publishtexts(publisher)
    textcat = textcatalog(publisher.editorsrepo, "catalog.cex")
    online = filter(row -> row.online, textcat) 
    for txt in online
        publishtext(publisher, txt)
    end
end

"""
- catalogrow: One row of catalog
- dse: DataFrame of DSE records
- target: destination directory for web site
"""
function publishtext(
    publisher,
    catalogrow;
    w = 100
    )

    urn = CtsUrn(catalogrow.urn)
    dse = dse_df(publisher.editorsrepo)
    rowmatches  = filter(dserow -> urncontains(urn, dserow.passage), dse)
    # Can directly convert diplomatic from nodes:
    dipl = diplomaticnodes(publisher.editorsrepo,urn)

    citedf = citation_df(publisher.editorsrepo)


    fname = editionfile(catalogrow, publisher.target)
    top = yamlplus(catalogrow)

    urnlabel = string("`", catalogrow.urn, "`\n\n")
  
    thumb = ""
    fname = editionfile(catalogrow, publisher.target)
    top = yamlplus(catalogrow)

    #converter = o2converter(editorsrepo, urn)

 

    linkedimgs = imgs_for_dse(rowmatches, dipl, publisher.ict, publisher.iiifsvc)


    # But need an xml corpus to build normalized:
     xml = textforurn(publisher.editorsrepo, urn)
     reader = ohco2forurn(citedf, urn)
     xmlcorpus = reader(xml, urn)

     
     normbuilder = normalizerforurn(citedf, urn)
     normcorp = edition(normbuilder, xmlcorpus)
     normed = normcorp.corpus

     document = join([top, urnlabel], "\n\n")    
     open(fname, "w") do io
         try 
             print(io, document, thumb, tablemarkdown(dipl, normed, linkedimgs))
         catch e
             groupurn = droppassage(dipl[1].urn)
             println("FAILED in ", groupurn, " with ", length(dipl), " diplomatic lines and ", length(linkedimgs), " DSE records." )
         end
     end
     document
end


function imgs_for_dse(dserows, textnodes, ict, iiifsvc; w = 100)

    linkedimgs = [] 
    if (length(textnodes) != nrow(dserows))
        for row in eachrow(dserows)
            push!(linkedimgs, "Invalid indexing of text to source images.")
        end
    else 
        for row in eachrow(dserows)
           push!(linkedimgs, linkedMarkdownImage(ict, row.image, iiifsvc, w, "image"))
        end
    end
    linkedimgs
end

# Compose markdown string for page title
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
