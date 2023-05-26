### A Pluto.jl notebook ###
# v0.19.11

using Markdown
using InteractiveUtils

# ╔═╡ 015cae43-5c06-402a-a139-5e4b31a42e55
begin
	import Pkg
	Pkg.activate(Base.current_project())
	Pkg.instantiate()
	using RegressionTables, DataFrames, FixedEffectModels, RDatasets, CategoricalArrays
	using PlutoUI
end

# ╔═╡ 2f2fd83d-398a-4c1a-bbe4-9e0579caee9f
begin
	df = dataset("datasets", "iris")
	df[!,:SpeciesDummy] = categorical(df[!,:Species])
	
	rr1 = reg(df, @formula(SepalLength ~ SepalWidth + fe(SpeciesDummy)))
	rr2 = reg(df, @formula(SepalLength ~ SepalWidth + PetalLength + fe(SpeciesDummy)))
	rr3 = reg(df, @formula(SepalLength ~ SepalWidth + PetalLength + PetalWidth + fe(SpeciesDummy)))
	rr4 = reg(df, @formula(SepalWidth ~ SepalLength + PetalLength + PetalWidth + fe(SpeciesDummy)))
end

# ╔═╡ 72683392-8220-4c52-92e6-ac538c8178a6
md"""
## Standard Output to Terminal

Not great in Pluto.jl because it has to simulate a terminal window (it's great that Pluto is able to do that!). We can't really use output flushed through `stdout` in Pluto - we want to display content directly (images or text or videos)
"""

# ╔═╡ e9e8d958-a10b-4321-b9ac-09725f657e1a
regtable(rr1,rr2,rr3,rr4; renderSettings = asciiOutput())

# ╔═╡ 84608bf7-0a01-4fd3-89c2-bd5b87079bfa
md"""
## Output to Browser as HTML 🎉

yay
"""

# ╔═╡ 928c4ee3-5f08-4cd3-9e17-69b18d9d5922
Show(MIME"text/html"(), String(regtable(rr1,rr2,rr3,rr4; renderSettings = htmlOutput(), print_result = false)))

# ╔═╡ Cell order:
# ╠═015cae43-5c06-402a-a139-5e4b31a42e55
# ╠═2f2fd83d-398a-4c1a-bbe4-9e0579caee9f
# ╟─72683392-8220-4c52-92e6-ac538c8178a6
# ╠═e9e8d958-a10b-4321-b9ac-09725f657e1a
# ╟─84608bf7-0a01-4fd3-89c2-bd5b87079bfa
# ╠═928c4ee3-5f08-4cd3-9e17-69b18d9d5922
