# Some utilities for working with this
# repository.
#
# Add to load path, e.g., from notebooks
# directory:
#
# push!(LOAD_PATH, "repoutils/")

module LycianUtils

using CSV, DataFrames
using EditorsRepo
using CitableText
using CitableObject


export labelledforms
export repo, scriptrepo

function scriptrepo()
    repo(dirname(pwd()))
end

"""
Configure editorial repository for this project.

Example: invoked from scripts directory:

```julia
repo = repo(dirname(pwd()))
```
"""
function repo(root::AbstractString)
    EditingRepository(root, "editions", "dse", "config")
end






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

end