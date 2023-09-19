using RDatasets
using RegressionTables
using FixedEffectModels, GLM, MixedModels, GLFixedEffectModels, Documenter, Aqua
using Test

##

#=
ambiguities is tested separately since it defaults to recursive=true
but there are packages that have ambiguities that will cause the test
to fail
=#
Aqua.test_ambiguities(RegressionTables; recursive=false)
Aqua.test_all(RegressionTables; ambiguities=false)

tests = [
        "default_changes.jl",
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
    doctest(RegressionTables)
end