using RDatasets
using RegressionTables
using FixedEffectModels, GLM, MixedModels, GLFixedEffectModels
using Test

##
tests = [
        "RegressionTables.jl",
        #"decorations.jl",
        #"label_transforms.jl",
        "GLFixedEffectModels.jl",
        "MixedModels.jl"
    ]

for test in tests
    @testset "$test" begin
        include(test)
    end
end
