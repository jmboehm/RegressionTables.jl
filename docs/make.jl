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
        "Customization and Defaults" => "customization.md",
        "Function and Type Reference" => "function_reference.md"
    ]
)

