# Run this script from the scripts directory
using Pkg
Pkg.activate(".")

using CitableTeiReaders
using CitableText
using CitableObject
using CSV
using EditorsRepo
using EzXML

reporoot = dirname(pwd())
repo = EditingRepository(reporoot, "editions", "dse", "config")

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

# Create a dictionary mapping URNs for 
# persNames to lists of  URNs for text passages.
function indexnames(c::CitableCorpus)
    dict = Dict()
    for cn in c.corpus
        xml = parsexml(cn.text)
        pns = findall("//persName", xml)
        for pn in pns
            if haskey(pn, "n")
                n = pn["n"]
                if haskey(dict, n)
                    #Already seen
                    prev = dict[n]
                    push!(dict, n => push!(prev, cn.urn))
                else
                    #First time
                    push!(dict, n => [cn.urn])
                end
            end 
        end
    end
    dict
end

function editionlink(u::CtsUrn)
    lnk = "../../Texts/" * workparts(u)[1] * "_" * workparts(u)[2]
    label = string("*", workparts(u)[1], "* ",workparts(u)[2],", ", passagecomponent(u) )
    "[" * label * "](" * lnk * ")"
end

function mdlist(psgs)
    items = map(psg -> "- " * editionlink(psg), psgs)
    "\n\n## Appears in\n\n" * join(items, "\n")
end

function printindex(dict, dir)
    for k in keys(dict)
        u = Cite2Urn(k)
        fname = dir * objectcomponent(u) * "/index.md"
        println("Append to ", fname)
        md = mdlist(dict[k])
        open(fname, "a") do io
            print(io, md)
        end
    end
end


c = xmlcorpus(repo)
namesidx = indexnames(c)
printindex(namesidx, reporoot * "/offline/Divinities/")


