

#=
These functions all take a single argument,
an editor's repository.
=#
function analysisdf(repo)
    morphids = repo.root * "/morphology/analyses.cex"
    arr = CSV.File(morphids, skipto=2, delim="|") |> Array
    urns = map(row -> Cite2Urn(row.lexicon), arr)
    words = map(row -> row.word, arr)
    forms = map(row -> Cite2Urn(row.form), arr)
    DataFrame(lexiconurn = urns, word = words, form = forms)
end

function formsdf(repo)
    morphids = repo.root * "/morphology/formids.cex"
    arr = CSV.File(morphids, skipto=2, delim="|") |> Array
    urns = map(row -> Cite2Urn(row.urn), arr)
    labels = map(row -> row.label, arr)
    
    DataFrame(form = urns, formlabel = labels)
end

function labelledforms(repo)
    a = analysisdf(repo)
    f = formsdf(repo)
    innerjoin(a,f, on = :form)
end
