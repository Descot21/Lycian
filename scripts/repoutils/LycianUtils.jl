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


export analysisdf, formsdf
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

end