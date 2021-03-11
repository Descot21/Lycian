# Run this script from the scripts directory
using Pkg
Pkg.activate(".")

using LycianUtils
using EditorsRepo



root = dirname(pwd())
pub = lycpublisher(root)

publishtexts(pub)