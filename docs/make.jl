using Revise
using RegressionTables, RDatasets, GLM, FixedEffectModels
using Documenter


DocMeta.setdocmeta!(
    RegressionTables,
    :DocTestSetup,
    quote
        using RegressionTables
    end;
    recursive=true
)

Documenter.makedocs(
    modules = [RegressionTables],
    sitename = "RegressionTables.jl",
    pages = [
        "Introduction" => "index.md",
        "Regression Statistics" => "regression_statistics.md",
        "Examples" => "examples.md",
        "Keep Drop and Order Arguments" => "keep_drop_order.md",
        "API" => "api.md",
    ]
)

##
using RegressionTables, DataFrames, RDatasets, FixedEffectModels, CategoricalArrays;
df = dataset("datasets", "iris");
df[!,:SpeciesDummy] = categorical(df[!,:Species]);
df[!,:isSmall] = categorical(df[!,:SepalWidth] .< 2.9);
rr1 = reg(df, @formula(SepalLength ~ SepalWidth));
rr2 = reg(df, @formula(SepalLength ~ SepalWidth + PetalLength + fe(SpeciesDummy)));
rr3 = reg(df, @formula(SepalLength ~ SepalWidth + PetalLength + PetalWidth + fe(SpeciesDummy) + fe(isSmall)));
rr4 = reg(df, @formula(SepalWidth ~ SepalLength + PetalLength + PetalWidth + fe(SpeciesDummy)));
rr5 = reg(df, @formula(SepalWidth ~ SepalLength + (PetalLength ~ PetalWidth) + fe(SpeciesDummy)));
##
regtable(rr1,rr2,rr4,rr3; groups = ["My Group:", "grp1" => 2:3, "grp2" => 4:5])
##
x = DataRow(["  ", "Group 1" => 2:3, "Group 2" => 4:5]; print_underlines=[false, false, true])
##
DataRow(["", "Group 1" => 2:3, "Group 2" => 4:5]; colwidths=[20, 20, 20], align="lcr", print_underlines=true)# colwidths set to show alignment
##

julia> DataRow(["", "Group 1" => 2:3, "Group 2" => 4:5])

julia> DataRow(["", "Group 1", "Group 1", "Group 2", "Group 2"]; combine_equals=true)
#   Group 1   Group 2

julia> DataRow(["", "Group 1" => 2:3, "Group 2" => 4:5]; print_underlines=true)
#   Group 1   Group 2

julia> DataRow(["   ", "Group 1" => 2:3, "Group 2" => 4:5]; print_underlines=[false, false, true])
#     Group 1   Group 2
               -------

julia> DataRow(["", "Group 1" => 2:3, "Group 2" => 4:5]; colwidths=[20, 20, 20], align="lcr", print_underlines=true)# colwidths set to show alignment
#                              Group 1                      Group 2
#                       --------------------   --------------------

julia> DataRow(["", "Group 1" => 2:3, "Group 2" => 4:5]; rndr=LatexTable())
# & \\multicolumn{2}{r}{Group 1} & \\multicolumn{2}{r}{Group 2} \\\\ 

##

```jldoctest
julia> DataRow(["", "Group 1" => 2:3, "Group 2" => 4:5])
   Group 1   Group 2

julia> DataRow(["", "Group 1", "Group 1", "Group 2", "Group 2"]; combine_equals=true)
   Group 1   Group 2

julia> DataRow(["", "Group 1" => 2:3, "Group 2" => 4:5])
   Group 1   Group 2

julia> DataRow(["   ", "Group 1" => 2:3, "Group 2" => 4:5]; print_underlines=[false, false, true])
     Group 1   Group 2
               -------

julia> DataRow(["", "Group 1" => 2:3, "Group 2" => 4:5]; colwidths=[20, 20, 20], align="lcr", print_underlines=true)# colwidths set to show alignment
                              Group 1                      Group 2
                       --------------------   --------------------

julia> DataRow(["", "Group 1" => 2:3, "Group 2" => 4:5]; rndr=LatexTable())
 & \\multicolumn{2}{r}{Group 1} & \\multicolumn{2}{r}{Group 2} \\\\ 
```