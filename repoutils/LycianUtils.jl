# Some utilities for working with this
# repository.
#
# Add to load path, e.g., from notebooks
# directory:
#
# push!(LOAD_PATH, "repoutils/")
#
module LycianUtils

using CitableImage, CitableObject, CitableText, CitableCorpus
using CitableTeiReaders, EditionBuilders, Orthography
using CSV, DataFrames, EzXML
using EditorsRepo
using Lycian

using Documenter, DocStringExtensions

export publishsite
export Publisher, publishtext, publishtexts 
export publishconcordance
export publisharticles

export normalcorpus, indexcorpus, xmlcorpus
export indexnames, flatindex

include("publisher.jl")

include("editions.jl")
include("editionpublisher.jl")

include("concordance.jl")
include("concordancepublisher.jl")

include("names.jl")
include("namespublisher.jl")

include("lexicon.jl")

include("morphology.jl")


end