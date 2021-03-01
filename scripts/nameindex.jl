# Run this script from the scripts directory
using Pkg
Pkg.activate(".")

using CitableText
using CSV
using EditorsRepo
using EzXML

root = dirname(pwd())
repo = EditingRepository(root, "editions", "dse", "config")

#=
function citation(repo::EditingRepository)
	arr = CSV.File(repo.root * "/" * repo.configs * "/citation.cex", skipto=2, delim="|", 
	quotechar='&', escapechar='&') |> Array
end
=#

# This should be in EditorsRepo!
function xmlcorpus(repo::EditingRepository)
    textcat = textcatalog(repo, "catalog.cex")
    online = filter(row -> row.online, textcat)
    corpora = []
    for txt in online
        urn = CtsUrn(txt.urn)
        reader = o2converter(repo, urn) |> Meta.parse |> eval
        xml = textforurn(repo, urn)	
        push!(corpora, reader(xml, urn))
    end
    composite_array(corpora)
end

c = xmlcorpus(repo)
for cn in cn.corpus

end