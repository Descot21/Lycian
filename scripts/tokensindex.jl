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
    collect(Iterators.flatten(concordance))
end


root = dirname(pwd())
textroot = root * "/offline/Texts/" 
repo = EditingRepository(root, "editions", "dse", "config")

indexable = normalcorpus(repo)

