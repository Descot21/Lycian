### A Pluto.jl notebook ###
# v0.12.18

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 0589b23a-5736-11eb-2cb7-8b122e101c35
begin
	import Pkg
	Pkg.activate(".")
	Pkg.add("PlutoUI")
	Pkg.add("CitableText")
	Pkg.add("CitableObject")
	Pkg.add("CitableImage")
	Pkg.add("CitableTeiReaders")
	Pkg.add("CSV")
	Pkg.add("HTTP")
	Pkg.add("DataFrames")
	Pkg.add("EditorsRepo")
	Pkg.add("Orthography")
	Pkg.add("EditionBuilders")
	

	
	using PlutoUI
	using CitableText
	using CitableObject
	using CitableImage
	using CitableTeiReaders
	using CSV
	using DataFrames
	using HTTP
	using EditorsRepo
	using Orthography	
	using Markdown
	
	using EditionBuilders


end

# ╔═╡ 7ee4b3a6-573d-11eb-1470-67a241783b23
@bind loadem Button("Load/reload data")

# ╔═╡ 6b4decf8-573b-11eb-3ef3-0196c9bb5b4b
md"**CTS URNs of all cataloged texts**"

# ╔═╡ 4010cf78-573c-11eb-03cf-b7dd1ae23b60
md"**CITE2 URNS of all indexed surfaces**"

# ╔═╡ 558e587a-573c-11eb-3364-632f0b0703da
md"""

> ## Verification: DSE indexing

"""

# ╔═╡ f1f5643c-573d-11eb-1fd1-99c111eb523f
md"Maximum width of image: $(@bind w Slider(200:1200, show_value=true))"


# ╔═╡ 13e8b16c-574c-11eb-13a6-61c5f05dfca2
md"""

> ## Verification:  orthography

"""

# ╔═╡ a7903abe-5747-11eb-310e-ffe2ee128f1b
md"""

> ## Data sets

"""

# ╔═╡ 37258038-574c-11eb-3acd-fb67db0bf1c8
md"Full details of the repository's contents."

# ╔═╡ 61bf76b0-573c-11eb-1d23-855b40e06c02
md"""

> Text corpora built from repository

"""

# ╔═╡ 562b460a-573a-11eb-321b-678429a06c0c
md"All citable nodes in **diplomatic** form."

# ╔═╡ 9118b6d0-573a-11eb-323b-0347fef8d3e6
md"All citable nodes in **normalized** form."

# ╔═╡ 100a1942-573c-11eb-211e-371998789bfa
md"""

> DSE tables

"""

# ╔═╡ 43f724c6-573b-11eb-28d6-f9ec8adebb8a
md"""


> Text catalog and configuration

"""

# ╔═╡ 0cabc908-5737-11eb-2ef9-d51aedfbbe5f
md"""

> ## Configuring the repository

"""

# ╔═╡ a7142d7e-5736-11eb-037b-5540068734e6
reporoot = dirname(pwd())

# ╔═╡ 6876c1d6-5749-11eb-39fe-29ef948bec69
md"Values read from `.toml` configuration files:"

# ╔═╡ 1053c2d8-5749-11eb-13c1-71943988978f
nbversion = begin
	loadem
	Pkg.TOML.parse(read("Project.toml", String))["version"]
end


# ╔═╡ fef09e62-5748-11eb-0944-c983eef98e1b
md"This is version **$(nbversion)** of the MID validation notebook."

# ╔═╡ 6182ebc0-5749-11eb-01b3-e35b891381ae
projectname = begin
	loadem
	Pkg.TOML.parse(read("MID.toml", String))["projectname"]
end

# ╔═╡ 269f23ac-58cf-11eb-2d91-3d46d28360d7
github = begin
	loadem
	Pkg.TOML.parse(read("MID.toml", String))["github"]
end

# ╔═╡ 59301396-5736-11eb-22d3-3d6538b5228c
md"""
Subdirectories in the repository:

| Content | Subdirectory |
|--- | --- |
| Configuration files are in | $(@bind configdir TextField(default="config")) |
| XML editions are in | $(@bind editions TextField(default="editions")) |
| DSE tables are in | $(@bind dsedir TextField(default="dse")) |

"""

# ╔═╡ 2fdc8988-5736-11eb-262d-9b8d44c2e2cc
catalogedtexts = begin
	loadem
	fromfile(CatalogedText, reporoot * "/" * configdir * "/catalog.cex")
end

# ╔═╡ 0bd05af4-573b-11eb-1b90-31d469940e5b
urnlist = catalogedtexts[:, :urn]

# ╔═╡ e3578474-573c-11eb-057f-27fc9eb9b519
md"This is the `EditingRepository` built from these settings:"

# ╔═╡ 7829a5ac-5736-11eb-13d1-6f5430595193
editorsrepo = EditingRepository(reporoot, editions, dsedir, configdir)

# ╔═╡ 547c4ffa-574b-11eb-3b6e-69fa417421fc
uniquesurfaces = EditorsRepo.surfaces(editorsrepo)

# ╔═╡ 2a84a042-5739-11eb-13f1-1d881f215521
diplomaticpassages = begin
	#diplomaticnodes(editorsrepo, urnlist[1])
	diplomaticarrays = map(u -> diplomaticnodes(editorsrepo, u), urnlist)
	reduce(vcat, diplomaticarrays)
end

# ╔═╡ 9974fadc-573a-11eb-10c4-13c589f5810b
normalizedpassages =  begin
	normalizedarrays = map(u -> normalizednodes(editorsrepo, u), urnlist)
	reduce(vcat, normalizedarrays)
end

# ╔═╡ 175f2e58-573c-11eb-3a36-f3142c341d93
alldse = begin
	loadem
	dse_df(editorsrepo)
end

# ╔═╡ 4fa5738a-5737-11eb-0e78-0155bfc12112
textconfig = begin
	loadem
	citation_df(editorsrepo)
end

# ╔═╡ 70ac0236-573e-11eb-1efd-c3be076018aa
md"""

> Configuring image services

"""

# ╔═╡ 97415fa4-573e-11eb-03df-81e1567ec34e
md"""
Image Citation Tool URL: 
$(@bind ict TextField((55,1), default="http://www.homermultitext.org/ict2/?"))
"""

# ╔═╡ 77a302c4-573e-11eb-311c-7102e8b377fa
md"""
IIIF URL: 
$(@bind iiif TextField((55,1), default="http://www.homermultitext.org/iipsrv"))
"""

# ╔═╡ 8afeacec-573e-11eb-3da5-6b6d6bd764f8
md"""
IIIF image root: $(@bind iiifroot TextField((55,1), default="/project/homer/pyramidal/deepzoom"))

"""

# ╔═╡ c3efd710-573e-11eb-1251-75295cced219
md"This is the IIIF Service built from these settings:"

# ╔═╡ bd95307c-573e-11eb-3325-ad08ee392a2f
# CitableImage access to a IIIF service
iiifsvc = begin
	baseurl = iiif
	root = iiifroot
	IIIFservice(baseurl, root)
end

# ╔═╡ 1fbce92e-5748-11eb-3417-579ae03a8d76
md"""

> ## Formatting the notebook

"""

# ╔═╡ 17d926a4-574b-11eb-1180-9376c363f71c
# Format HTML header for notebook.
function hdr() 
	HTML("<blockquote  class='center'><h1>MID validation notebook</h1>" *
		"<h3>" * projectname * "</h3>" 		*
		"<p>On github at <a href=\"" * github * "\">" * github * "</a></p>" *
		"<p>Editing project from repository in:</p><h5><i>" * reporoot * "</i></h5></blockquote>")
end

# ╔═╡ 22980f4c-574b-11eb-171b-170c4a68b30b
hdr()

# ╔═╡ 0da08ada-574b-11eb-3d9a-11226200f537
css = html"""
<style>
.danger {
     background-color: #fbf0f0;
     border-left: solid 4px #db3434;
     line-height: 18px;
     overflow: hidden;
     padding: 15px 60px;
   font-style: normal;
	  }
.warn {
     background-color: 	#ffdd00;
     border-left: solid 4px  black;
     line-height: 18px;
     overflow: hidden;
     padding: 15px 60px;
   font-style: normal;
  }

  .danger h1 {
	color: red;
	}

 .invalid {
	text-decoration-line: underline;
  	text-decoration-style: wavy;
  	text-decoration-color: red;
}
 .center {
text-align: center;
}
.highlight {
  background: yellow;  
}
.urn {
	color: silver;
}
  .note { -moz-border-radius: 6px;
     -webkit-border-radius: 6px;
     background-color: #eee;
     background-image: url(../Images/icons/Pencil-48.png);
     background-position: 9px 0px;
     background-repeat: no-repeat;
     border: solid 1px black;
     border-radius: 6px;
     line-height: 18px;
     overflow: hidden;
     padding: 15px 60px;
    font-style: italic;
 }


.instructions {
     background-color: #f0f7fb;
     border-left: solid 4px  #3498db;
     line-height: 18px;
     overflow: hidden;
     padding: 15px 60px;
   font-style: normal;
  }



</style>
"""

# ╔═╡ 2d218414-573e-11eb-33dc-af1f2df86cf7
# Select a node from list of diplomatic nodes
function diplnode(urn)
	filtered = filter(cn -> dropversion(cn.urn) == dropversion(urn), diplomaticpassages)
	if length(filtered) > 0
		filtered[1].text
	else 
		""
	end
	#"Found stuffs " * le
end

# ╔═╡ bf77d456-573d-11eb-05b6-e51fd2be98fe
function mdForRow(row::DataFrameRow)
	citation = "**" * passagecomponent(row.passage)  * "** "

	
	txt = diplnode(row.passage)
	caption = passagecomponent(row.passage)
	
	img = linkedMarkdownImage(ict, row.image, iiifsvc, w, caption)
	
	#urn
	record = """$(citation) $(txt)
	
$(img)
	
---
"""
	record
end


# ╔═╡ bec00462-596a-11eb-1694-076c78f2ba95
# Compose HTML reporting on status of text cataloging
function catalogcheck()
	if citationmatches(catalogedtexts, textconfig) # citationcomplete()
		md"> Summary of cataloged content"
	else
		
		missingcats = catalogony(catalogedtexts, textconfig) #catalogonly()
		catitems = map(c -> "<li>" * c.urn * "</li>", missingcats)
		catlist = "<p>In catalog, but not <code>citation.cex</code>:</p><ul>" * join(catitems,"\n") * "</ul>"
		cathtml = isempty(catitems) ? "" : catlist
		
		
		missingcites = citationonly(catalogedtexts, textconfig)
		citeitems = map(c -> "<li>" * c.urn * "</li>", missingcites)
		citelist = "<p>In <code>citation.cex</code>, but not text catalog:</p><ul>" * join(citeitems,"\n") * "</ul>"
		citehtml = isempty(citeitems) ? "" : citelist
		
		cataloginghtml = "<div class='danger'><h1>🧨🧨 Configuration error 🧨🧨</h1>" *  cathtml * "\n" * citehtml * "</div>"
		
		
		HTML(cataloginghtml)
	end
end

# ╔═╡ c9652ac8-5974-11eb-2dd0-654e93786446
begin
	loadem
	catalogcheck()
end

# ╔═╡ 4133cbbc-5971-11eb-0bcd-658721f886f1
# Compose HTML reporting on correctness of file cataloging
function fileinventory()
	if filesmatch(editorsrepo, textconfig)
		md""
	else
		missingfiles = filesonly(editorsrepo, textconfig)
		if isempty(missingfiles)
			notondisk = citedonly(editorsrepo, textconfig)
			nofiletems = map(f -> "<li>" * f * "</li>", notondisk)
			nofilelist = "<p>Configured files found on disk: </p><ul>" * join(nofiletems, "\n") * "</ul>"
			nofilehtml = "<div class='danger'><h1>🧨🧨 Configuration error 🧨🧨 </h1>" *
				"<p>No files matching configured name:</p>" * nofilelist
			HTML(nofilehtml)
			
		else 
			fileitems = map(f -> "<li>" * f * "</li>", missingfiles)
			filelist = "<p>Uncataloged files found on disk: </p><ul>" * join(fileitems,"\n") * "</ul>"
			fileshtml = "<div class='warn'><h1>⚠️ Warning</h1>" *  filelist  * "</div>"
			HTML(fileshtml)
					
		end

	end
end

# ╔═╡ 925647c6-5974-11eb-1886-1fa2b12684f5
begin
	loadem
	fileinventory()
end

# ╔═╡ 9ac99da0-573c-11eb-080a-aba995c3fbbf
md"""

> Formatting DSE selections for verification

"""

# ╔═╡ b899d304-574b-11eb-1d50-5b7813ea201e
md"Menu choices for popup menu of all unique surface URNs:"

# ╔═╡ 356f7236-573c-11eb-18b5-2f5a6bfc545d
surfacemenu = begin 
	loadem
	surfurns = EditorsRepo.surfaces(editorsrepo)
	surflist = map(u -> u.urn, surfurns)
	# Add a blank entry so popup menu can come up without a selection
	pushfirst!( surflist, "")
end

# ╔═╡ e08d5418-573b-11eb-2375-35a717b36a30
md"""
*Choose a surface to verify*: 
$(@bind surface Select(surfacemenu))
"""

# ╔═╡ 1fde0332-574c-11eb-1baf-01d335b27912
begin
	if surface == ""
		md""
	else

	html"""
	<blockquote>Tokens including invalid characters are highlighted
	like <span class='invalid'>this</span>.</blockquote>
"""
	end
end

# ╔═╡ cb954628-574b-11eb-29e3-a7f277852b45
md"Currently selected surface:"

# ╔═╡ 901ae238-573c-11eb-15e2-3f7611dacab7
surfurn = begin
	if surface == ""
		""
	else
		Cite2Urn(surface)
	end
end

# ╔═╡ d9495f98-574b-11eb-2ee9-a38e09af22e6
md"DSE records for selected surface:"

# ╔═╡ e57c9326-573b-11eb-100c-ed7f37414d79
surfaceDse = filter(row -> row.surface == surfurn, alldse)

# ╔═╡ c9a3bd8c-573d-11eb-2034-6f608e8bf414
begin
	if surface == ""
		md""
	else
		md"*Found **$(nrow(surfaceDse))** citable text passages for $(objectcomponent(surfurn))*"
	end
end

# ╔═╡ 00a9347c-573e-11eb-1b25-bb15d56c1b0d
# display DSE records for verification
begin
	if surface == ""
		md""
	else
		cellout = []
		for r in eachrow(surfaceDse)
			push!(cellout, mdForRow(r))
		end
		Markdown.parse(join(cellout,"\n"))
	end
end

# ╔═╡ 926873c8-5829-11eb-300d-b34796359491
begin
	if surface == ""
		md""
	else
		md"*Verifying orthography of **$(nrow(surfaceDse))** citable text passages for $(objectcomponent(surfurn) )*"
	end
end

# ╔═╡ aac2d102-5829-11eb-2e89-ad4510c25f28
md"""

> Formatting tokenized text for verifying orthography

"""

# ╔═╡ 6dd532e6-5827-11eb-1dea-696e884652ac
function formatToken(ortho, s)
	if validstring(ortho, s)
			s
	else
		"""<span class='invalid'>$(s)</span>"""
	end
end

# ╔═╡ bdeb6d18-5827-11eb-3f90-8dd9e41a8c0e
# Compose string of HTML for a tokenized row including
# tagging of invalid tokens
function tokenizeRow(row)
	ortho = orthographyforurn(textconfig, row.passage)
	citation = "<b>" * passagecomponent(row.passage)  * "</b> "
	txt = diplnode(row.passage)
	tokenstart::Array{OrthographicToken} = []
	tokens = tokenize(ortho, txt,tokenstart)
	highlighted = map(t -> formatToken(ortho, t.text), tokens)
	html = join(highlighted, " ")
	"<p>$(citation) $(html)</p>"
	
end

# ╔═╡ aa385f1a-5827-11eb-2319-6f84d3201a7e
# display highlighted tokens for verification
begin
	if surface == ""
		md""
	else
		htmlout = []
		for r in eachrow(surfaceDse)
			push!(htmlout, tokenizeRow(r))
		end
		HTML(join(htmlout,"\n"))
	end
end

# ╔═╡ Cell order:
# ╟─0589b23a-5736-11eb-2cb7-8b122e101c35
# ╟─fef09e62-5748-11eb-0944-c983eef98e1b
# ╟─22980f4c-574b-11eb-171b-170c4a68b30b
# ╟─7ee4b3a6-573d-11eb-1470-67a241783b23
# ╟─c9652ac8-5974-11eb-2dd0-654e93786446
# ╟─925647c6-5974-11eb-1886-1fa2b12684f5
# ╟─6b4decf8-573b-11eb-3ef3-0196c9bb5b4b
# ╟─0bd05af4-573b-11eb-1b90-31d469940e5b
# ╟─4010cf78-573c-11eb-03cf-b7dd1ae23b60
# ╟─547c4ffa-574b-11eb-3b6e-69fa417421fc
# ╟─558e587a-573c-11eb-3364-632f0b0703da
# ╟─e08d5418-573b-11eb-2375-35a717b36a30
# ╟─c9a3bd8c-573d-11eb-2034-6f608e8bf414
# ╟─f1f5643c-573d-11eb-1fd1-99c111eb523f
# ╟─00a9347c-573e-11eb-1b25-bb15d56c1b0d
# ╟─13e8b16c-574c-11eb-13a6-61c5f05dfca2
# ╟─926873c8-5829-11eb-300d-b34796359491
# ╟─1fde0332-574c-11eb-1baf-01d335b27912
# ╟─aa385f1a-5827-11eb-2319-6f84d3201a7e
# ╟─a7903abe-5747-11eb-310e-ffe2ee128f1b
# ╟─37258038-574c-11eb-3acd-fb67db0bf1c8
# ╟─61bf76b0-573c-11eb-1d23-855b40e06c02
# ╟─562b460a-573a-11eb-321b-678429a06c0c
# ╟─2a84a042-5739-11eb-13f1-1d881f215521
# ╟─9118b6d0-573a-11eb-323b-0347fef8d3e6
# ╟─9974fadc-573a-11eb-10c4-13c589f5810b
# ╟─100a1942-573c-11eb-211e-371998789bfa
# ╟─175f2e58-573c-11eb-3a36-f3142c341d93
# ╟─43f724c6-573b-11eb-28d6-f9ec8adebb8a
# ╟─2fdc8988-5736-11eb-262d-9b8d44c2e2cc
# ╟─4fa5738a-5737-11eb-0e78-0155bfc12112
# ╟─0cabc908-5737-11eb-2ef9-d51aedfbbe5f
# ╟─a7142d7e-5736-11eb-037b-5540068734e6
# ╟─6876c1d6-5749-11eb-39fe-29ef948bec69
# ╟─1053c2d8-5749-11eb-13c1-71943988978f
# ╟─6182ebc0-5749-11eb-01b3-e35b891381ae
# ╟─269f23ac-58cf-11eb-2d91-3d46d28360d7
# ╟─59301396-5736-11eb-22d3-3d6538b5228c
# ╟─e3578474-573c-11eb-057f-27fc9eb9b519
# ╟─7829a5ac-5736-11eb-13d1-6f5430595193
# ╟─70ac0236-573e-11eb-1efd-c3be076018aa
# ╟─97415fa4-573e-11eb-03df-81e1567ec34e
# ╟─77a302c4-573e-11eb-311c-7102e8b377fa
# ╟─8afeacec-573e-11eb-3da5-6b6d6bd764f8
# ╟─c3efd710-573e-11eb-1251-75295cced219
# ╟─bd95307c-573e-11eb-3325-ad08ee392a2f
# ╟─1fbce92e-5748-11eb-3417-579ae03a8d76
# ╟─17d926a4-574b-11eb-1180-9376c363f71c
# ╟─0da08ada-574b-11eb-3d9a-11226200f537
# ╟─bf77d456-573d-11eb-05b6-e51fd2be98fe
# ╟─2d218414-573e-11eb-33dc-af1f2df86cf7
# ╟─bec00462-596a-11eb-1694-076c78f2ba95
# ╟─4133cbbc-5971-11eb-0bcd-658721f886f1
# ╟─9ac99da0-573c-11eb-080a-aba995c3fbbf
# ╟─b899d304-574b-11eb-1d50-5b7813ea201e
# ╟─356f7236-573c-11eb-18b5-2f5a6bfc545d
# ╟─cb954628-574b-11eb-29e3-a7f277852b45
# ╟─901ae238-573c-11eb-15e2-3f7611dacab7
# ╟─d9495f98-574b-11eb-2ee9-a38e09af22e6
# ╟─e57c9326-573b-11eb-100c-ed7f37414d79
# ╟─aac2d102-5829-11eb-2e89-ad4510c25f28
# ╟─bdeb6d18-5827-11eb-3f90-8dd9e41a8c0e
# ╟─6dd532e6-5827-11eb-1dea-696e884652ac
