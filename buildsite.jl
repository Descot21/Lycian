# Run this script from the repository root with:
#
# 
# 
using Pkg
Pkg.activate(".")
Pkg.instantiate()
push!(LOAD_PATH, "./repoutils")

using LycianUtils
publisher = LycianUtils.lycpublisher(pwd())

# This does the whole thing!
publishsite(publisher)


