
# Index persName elements in corpus c
function indexnames(c::CitableTextCorpus)
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
