# Run this script from the scripts directory
using Pkg
Pkg.activate(".")

using EditorsRepo
using CitableText
using CSV
using DataFrames


function citation(repo::EditingRepository)
	arr = CSV.File(repo.root * "/" * repo.configs * "/citation.cex", skipto=2, delim="|", 
	quotechar='&', escapechar='&') |> Array
end

function mdtitle(csvrow)
    string("*", csvrow.groupName, "*, ", csvrow.workTitle)
end

function shorttitle(csvrow)
    string("\"", csvrow.groupName, ", ", csvrow.workTitle, "\"")
end

function editionfile(csvrow, basedir)
    urn = CtsUrn(csvrow.urn)
    parts = workparts(urn)
    editiondir = basedir * string(parts[1], "_", parts[2])
    if !isdir(editiondir)
        mkdir(editiondir)
    end
    editiondir * "/index.md"
end

root = dirname(pwd())
textroot = root * "/offline/Texts/" 
repo = EditingRepository(root, "editions", "dse", "config")
textcat = textcatalog(repo, "catalog.cex")
online = filter(row -> row.online, textcat)


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


citedf = citation_df(repo)

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

for txt in online
    fname = editionfile(txt, textroot)
    top = yamlplus(txt)
    open(fname, "w") do io
        print(io, top)
    end
    xmlfile = textforun(citedf, CtsUrn(txt.urn))
    # now make it citable
    # then make it univocal
end



