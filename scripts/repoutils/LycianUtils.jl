# Some utilities for working with this
# repository.
#
# Add to load path, e.g., from notebooks
# directory:
#
# push!(LOAD_PATH, "repoutils/")

module LycianUtils

using CitableImage
using CitableObject
using CitableText
using CitableTeiReaders
using CSV
using DataFrames
using EditionBuilders
using EditorsRepo
using Lycian


export Publisher, publishtext, publishtexts
export edrepo


include("editions.jl")
include("editionpublisher.jl")
include("morphology.jl")






"""
Configure editorial repository for this project.

Example: invoked from scripts directory:

```julia
repo = repo(dirname(pwd()))
```
"""
function edrepo(root::AbstractString)
    EditingRepository(root, "editions", "dse", "config")
end




end