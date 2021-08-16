
function cp_articles(root)
    divs = root * "/divinities-articles/"
    offlinedivs = root * "/offline/Divinities/"
    cp(divs, offlinedivs, force=true)
end

function publisharticles(root)
    target = root *  "/offline/Divinities/"
    cp_articles(root)
    c = xmlcorpus(root)
    namesidx = indexnames(c)
    names_printindex(namesidx, target)
end


function names_editionlink(u::CtsUrn)
    lnk = "../../Texts/" * workparts(u)[1] * "_" * workparts(u)[2]
    label = string("*", workparts(u)[1], "* ",workparts(u)[2],", ", passagecomponent(u) )
    "[" * label * "](" * lnk * ")"
end

function names_mdlist(psgs)
    items = map(psg -> "- " * names_editionlink(psg), psgs)
    "\n\n## Appears in\n\n" * join(items, "\n")
end

function names_printindex(dict, dir)
    for k in keys(dict)
        u = Cite2Urn(k)
        fname = dir * objectcomponent(u) * "/index.md"
        println("Append names index to ", fname)
        md = names_mdlist(dict[k])
        open(fname, "a") do io
            print(io, md)
        end
    end
end