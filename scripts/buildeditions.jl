# Run this script from the scripts directory
using Pkg
Pkg.activate(".")

using LycianUtils
using EditorsRepo
using CitableImage


root = dirname(pwd())
pub = lycpublisher(root)

## These two are Arrays of CSV.Rows
textcat = textcatalog(edrepo(root), "catalog.cex")
online = filter(row -> row.online, textcat) 
for txt in online
    publishtext(pub, txt)
end


=#