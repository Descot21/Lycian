# Run this script from the scripts directory
using Pkg
Pkg.activate(".")

using LycianUtils
using EditingRepository
using CitableText
using CitableImage


root = dirname(pwd())
textroot = root * "/offline/texts/" 
repo = edrepo(root)
# Citable Image service
baseiifurl = "http://www.homermultitext.org/iipsrv"
imgroot = "/project/homer/pyramidal/deepzoom"
iiifsvc = IIIFservice(baseiifurl, imgroot)

lycpublisher = Publisher(repo,
    "http://www.homermultitext.org/ict2/?",
    iiifsvc,
    textroot
)





# These two are Arrays of CSV.Rows
textcat = textcatalog(repo, "catalog.cex")
online = filter(row -> row.online, textcat) 
for txt in online
    publishtext(lycpublisher, txt)
end





#=

# These two are DataFrames
citedf = citation_df(repo)
dse = dse_df(repo)
=#

