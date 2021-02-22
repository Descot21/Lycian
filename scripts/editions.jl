# Run this script from the scripts directory
using Pkg
Pkg.activate(".")

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
function tablemarkdown(dipllist, normlist)
   
    diplitems = map(cn -> "| `" * passagecomponent(cn.urn) * "` | " * cn.text * " | " *  Lycian.ucode(cn.text) * " |", dipllist)
    dipltable = [
        "|  | Transcription | Lycian |",
        "| :---: | :------ | :------ |",
        join(diplitems, "\n")
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
textroot = root * "/offline/Texts/" 
repo = EditingRepository(root, "editions", "dse", "config")
textcat = textcatalog(repo, "catalog.cex")
online = filter(row -> row.online, textcat)
citedf = citation_df(repo)

for txt in online
    fname = editionfile(txt, textroot)
    top = yamlplus(txt)

    urnlabel = string("`", txt.urn, "`\n\n")
    urn = CtsUrn(txt.urn)
    xml = textforurn(repo, urn)
    converter = o2converter(repo, urn)
    # Can directly convert diplomatic from nodes:
    dipl = diplomaticnodes(repo,urn)
    # But need an xml corpus to build normalized:
    reader = ohco2forurn(citedf, urn)
	normbuilder = normalizerforurn(citedf, urn)
    xmlcorpus = reader(xml, urn)
    normcorp = edition(normbuilder, xmlcorpus)
    normed = normcorp.corpus
    
    document = join([top, urnlabel], "\n\n")    
    open(fname, "w") do io
        print(io, document, tablemarkdown(dipl, normed))
    end
end



