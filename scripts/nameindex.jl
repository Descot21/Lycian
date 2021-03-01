# Run this script from the scripts directory
using Pkg
Pkg.activate(".")

root = dirname(pwd())
repo = EditingRepository(root, "editions", "dse", "config")
textcat = textcatalog(repo, "catalog.cex")
online = filter(row -> row.online, textcat)

function citation(repo::EditingRepository)
	arr = CSV.File(repo.root * "/" * repo.configs * "/citation.cex", skipto=2, delim="|", 
	quotechar='&', escapechar='&') |> Array
end


#xml = textforurn(repo, urn)
#converter = o2converter(repo, urn)

for txt in online
    urn = CtsUrn(txt.urn)
    println(urn)
    converter = o2converter(repo, urn)
    println(converter)
    xml = textforurn(repo, urn)	
    #ohco2forurn(CONF,urn)
    #println(xml)
    #converted = converter(xml, urn)
    #println(converted)
end