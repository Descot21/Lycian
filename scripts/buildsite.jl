# Run this script from the scripts directory
using Pkg
Pkg.activate(".")
push!(LOAD_PATH, "repoutils")

using LycianUtils
root = dirname(pwd())
publishsite(root)


