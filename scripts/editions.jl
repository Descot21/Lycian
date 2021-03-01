# Run this script from the scripts directory
using Pkg
Pkg.activate(".")

using CitableImage
using CitableObject
using CitableText
using CitableTeiReaders
using CSV
using DataFrames
using EditionBuilders
using EditorsRepo
using Lycian

# Read citation configuration in an Array
function citation(repo::EditingRepository)
	arr = CSV.File(repo.root * "/" * repo.configs * "/citation.cex", skipto=2, delim="|", 
	quotechar='&', escapechar='&') |> Array
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

# Compose full path to file for a single
# row of configuration table
function editionfile(csvrow, basedir)
    urn = CtsUrn(csvrow.urn)
    parts = workparts(urn)
    editiondir = basedir * string(parts[1], "_", parts[2])
    if !isdir(editiondir)
        mkdir(editiondir)
    end
    editiondir * "/index.md"
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

# Read XML text from  local file for a
# document identified by URN
function textforurn_df(df, urn)
	row = filter(r -> droppassage(urn) == r[:urn], df)
	if nrow(row) == 0
		nothing
	else 
		f= repo.root * "/" * repo.editions * "/" *	row[1,:file]
		contents = open(f) do file
			read(file, String)
		end
		contents
	end
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

root = dirname(pwd())
textroot = root * "/offline/texts/" 
repo = EditingRepository(root, "editions", "dse", "config")
textcat = textcatalog(repo, "catalog.cex")
online = filter(row -> row.online, textcat)
citedf = citation_df(repo)
dse = dse_df(repo)
baseiifurl = "http://www.homermultitext.org/iipsrv"
ict = "http://www.homermultitext.org/ict2/?"
imgroot = "/project/homer/pyramidal/deepzoom"
iiifsvc = IIIFservice(baseiifurl, imgroot)

w = 100
for txt in online
    fname = editionfile(txt, textroot)
    top = yamlplus(txt)

    urnlabel = string("`", txt.urn, "`\n\n")
    urn = CtsUrn(txt.urn)
    thumb = ""
    rowmatches  = filter(row -> urncontains(urn, row.passage), dse)
    if nrow(rowmatches) > 0
        imgurn = rowmatches[1, :image]
        thumburn = CitableObject.dropsubref(imgurn)
        thumb = "\n\nAll images are linked to pannable/zoomable versions\n\n" * linkedMarkdownImage(ict,thumburn, iiifsvc, 200, "thumb") * "\n\n"
    end
        
    xml = textforurn(repo, urn)
    converter = o2converter(repo, urn)
    # Can directly convert diplomatic from nodes:
    dipl = diplomaticnodes(repo,urn)
    

    linkedimgs = [] 
    if (length(dipl) != nrow(rowmatches))
        for row in eachrow(rowmatches)
            push!(linkedimgs, "Invalid indexing of text to source images.")
        end
    else 
        for row in eachrow(rowmatches)
           push!(linkedimgs, linkedMarkdownImage(ict, row.image, iiifsvc, w, "image"))
        end
    end
    #println(dipl, linkedimgs)
    

    # But need an xml corpus to build normalized:
    reader = ohco2forurn(citedf, urn)
	normbuilder = normalizerforurn(citedf, urn)
    xmlcorpus = reader(xml, urn)
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
    
end


