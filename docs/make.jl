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
df = RDatasets.dataset("datasets", "iris");
df = describe(df, :mean, :std, :q25, :median, :q75; cols=["SepalLength", "SepalWidth", "PetalLength", "PetalWidth"]);
RegressionTables.RegressionTable(names(df), Matrix(df))