# Run this script from the scripts directory
using Pkg
Pkg.activate(".")

using EditorsRepo
using CitableText
using CSV

function citation(repo::EditingRepository)
	arr = CSV.File(repo.root * "/" * repo.configs * "/citation.cex", skipto=2, delim="|", 
	quotechar='&', esca pechar='&') |> Array
end

function shorttitle(csvrow)
    string("*", csvrow.groupName, "*, ", csvrow.workTitle)
end

function editiondir(csvrow, basedir)
    urn = CtsUrn(csvrow.urn)
    parts = workparts(urn)
    editiondir = basedir * string(parts[1], "_", parts[2])
    if !isdir(editiondir)
        mkdir(editiondir)
    end
end

root = dirname(pwd())
textroot = root * "/offline/Texts/" 
repo = EditingRepository(root, "editions", "dse", "config")
textcat = textcatalog(repo, "catalog.cex")
online = filter(row -> row.online, textcat)

for txt in online
    editiondir(txt, textroot)
end


citeconf = citation(repo)
