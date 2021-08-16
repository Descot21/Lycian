# Run this script from the repository root!
using Pkg
Pkg.activate(".")
Pkg.instantiate()
push!(LOAD_PATH, "repoutils")

using LycianUtils
publisher = LycianUtils.lycpublisher(pwd())

#publishsite(root)


