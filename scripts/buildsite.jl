# Run this script from the scripts directory
using Pkg
Pkg.activate(".")

using LycianUtils
root = dirname(pwd())
publishsite(root)


