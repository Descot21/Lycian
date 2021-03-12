# Some utilities for working with this
# repository.
#
# Add to load path, e.g., from notebooks
# directory:
#
# push!(LOAD_PATH, "repoutils/")

module LycianUtils

using CitableImage, CitableObject, CitableText
using CitableTeiReaders, EditionBuilders, Orthography
using CSV, DataFrames, EzXML
using EditorsRepo
using Lycian

export publishsite
export Publisher, publishtext, publishtexts 
export publishconcordance
export publisharticles
export edrepo
export normalcorpus, indexcorpus, xmlcorpus
export indexnames, flatindex

include("publisher.jl")

include("editions.jl")
include("editionpublisher.jl")

include("concordance.jl")
include("concordancepublisher.jl")

include("names.jl")
include("namespublisher.jl")

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