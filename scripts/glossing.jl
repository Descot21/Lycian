using CSV
using CitableText
using CitableObject
using DataFrames
using EditorsRepo

reporoot = dirname(pwd())
repo = EditingRepository(reporoot, "editions", "dse", "config")


function analysisdf(repo)
    morphids = repo.root * "/morphology/analyses.cex"
    arr = CSV.File(morphids, skipto=2, delim="|") |> Array
    urns = map(row -> Cite2Urn(row.lexicon), arr)
    words = map(row -> row.word, arr)
    forms = map(row -> Cite2Urn(row.form), arr)
    DataFrame(urn = urns, word = words, form = forms)
end



function formsdf(repo)
    morphids = repo.root * "/morphology/formids.cex"
    arr = CSV.File(morphids, skipto=2, delim="|") |> Array
    urns = map(row -> Cite2Urn(row.urn), arr)
    labels = map(row -> row.label, arr)
    
    DataFrame(urn = urns, label = labels)
end