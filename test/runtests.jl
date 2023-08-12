using RDatasets
using RegressionTables
using FixedEffectModels, GLM, MixedModels, GLFixedEffectModels, Documenter
using Test

##
tests = [
        "RegressionTables.jl",
        "decorations.jl",
        "label_transforms.jl",
        "GLFixedEffectModels.jl",
        "MixedModels.jl"
    ]

for test in tests
    @testset "$test" begin
        include(test)
    end
end

DocMeta.setdocmeta!(
    RegressionTables,
    :DocTestSetup,
    quote
        using RegressionTables
    end;
    recursive=true
)

@testset "Regression Tables Documentation" begin
    doctest(RegressionTables; manual=false)
end