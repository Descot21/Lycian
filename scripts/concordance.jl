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
using Orthography

# Read citation configuration in an Array
function citation(repo::EditingRepository)
	arr = CSV.File(repo.root * "/" * repo.configs * "/citation.cex", skipto=2, delim="|", 
	quotechar='&', escapechar='&') |> Array
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


# Build a single epigraphically normalized corpus
# for the whole repository
function normalcorpus(repo) 
    textcat = textcatalog(repo, "catalog.cex")
    citedf = citation_df(repo)

    online = filter(row -> row.online, textcat)
    documents = []

    for txt in online
        urn = CtsUrn(txt.urn)
        xml = textforurn(repo, urn)
        # Need an xml corpus to build epigraphically normalized:
        reader = ohco2forurn(citedf, urn)
        normbuilder = normalizerforurn(citedf, urn)
        xmlcorpus = reader(xml, urn)
        normcorp = edition(normbuilder, xmlcorpus)
        push!(documents, normcorp)
    end
    onecorpus  = CitableText.composite_array(documents)

end

# Index a corpus of Lycian
function indexcorpus(c)
    orthography = lycianAscii()
    concordance = []
    for n in c.corpus
        tkns = orthography.tokenizer(n.text)
        lextokens = filter(t -> t.tokencategory == Orthography.LexicalToken(), tkns)
        pairs = map(tkn -> (tkn.text, n.urn), lextokens)
        push!(concordance, pairs)
    end
    idx = collect(Iterators.flatten(concordance))
    terms = map(entry -> entry[1], idx)
    urns = map(entry -> entry[2], idx)
    df = DataFrame( term = terms, urn = urns,)
    groupby(df, :term)
end


function mdrow(pr)
    hdg = "**" * pr[1] * "** (" * Lycian.ucode(pr[1]) * ")"
    
     hdg * ":  " * pr[2]
end
function editionlink(u::CtsUrn)
    lnk = "../Texts/" * workparts(u)[1] * "_" * workparts(u)[2]
    label = string("*", workparts(u)[1], "* ",workparts(u)[2],", ", passagecomponent(u) )
    "[" * label * "](" * lnk * ")"
end
function mdpage(gdf)
    delimited = []
    for k in keys(gdf)
        term = k.term
        vals = idx[k]
        urns = vals[!, :urn]
     

        urnlabels = map(u ->  editionlink(u), urns)
        push!(delimited, term * "|" * join(urnlabels,"; "))
    end
    sorted = sort(delimited)
    paired = map(ln -> split(ln, "|"), sorted)
    rows = map(pr -> mdrow(pr), paired)
    join(rows, "\n\n")
end


function yamlplus()
    lines = [
        "---",
        "title: Concordance",
        "layout: page",
        "nav_order: 8",
        "---",
        "\n\n",
        "# Concordance of lexical tokens",
        "\n\n",
        """Hyphens indicate line breaks when lexical tokens 
        span more than one line.  References in the concordance
        are to the line where the lexical token begins.""",
        "\n\n"
    ]
    join(lines,"\n")
end


root = dirname(pwd())
repo = EditingRepository(root, "editions", "dse", "config")

# A CitableCorpus:
indexable = normalcorpus(repo)
# A GroupedDataFrame keyed by term
idx = indexcorpus(indexable)
fname = root * "/offline/Concordance/index.md" 
open(fname, "w") do io
    print(io, yamlplus(), mdpage(idx))
end