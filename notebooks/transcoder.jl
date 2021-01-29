### A Pluto.jl notebook ###
# v0.12.20

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

# ╔═╡ dd8a5dd0-6230-11eb-155e-51ac726bff7b
begin
	using Pkg
	Pkg.add("Lycian")
	Pkg.add("PlutoUI")
	
	using Lycian
	using PlutoUI
end

# ╔═╡ c5f70fae-6230-11eb-27e8-0d77dee7fc27
md"Lycian transcoder"

# ╔═╡ 26ce4608-6231-11eb-2a3b-894aba4cb7fd
md"*Text in ASCII-based form*: $(@bind src TextField())"

# ╔═╡ 419e610c-6231-11eb-07a7-dd07c6c95500
begin
	if isempty(src)
		md""
	else
		md"""
		### $(Lycian.ucode(src))
		"""
	end
end

# ╔═╡ Cell order:
# ╟─dd8a5dd0-6230-11eb-155e-51ac726bff7b
# ╟─c5f70fae-6230-11eb-27e8-0d77dee7fc27
# ╟─26ce4608-6231-11eb-2a3b-894aba4cb7fd
# ╟─419e610c-6231-11eb-07a7-dd07c6c95500
