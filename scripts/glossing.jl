using Pkg
Pkg.activate(".")
push!(LOAD_PATH, "repoutils/")

using LycianUtils
using CSV
using CitableText
using CitableObject
using DataFrames
using EditorsRepo


r =  scriptrepo()
analyses = r |> analysisdf
forms = r |> formsdf


 