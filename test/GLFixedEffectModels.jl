# this script tests whether RegressionTables works with GLFixedEffectModels.jl

using GLFixedEffectModels, GLM, RDatasets, Test

# include("src/RegressionTables.jl")
df = dataset("datasets", "iris")
df[!, :isSmall] = df[!, :SepalWidth] .< 2.9
df[!, :isWide] = df[!, :SepalWidth] .> 2.5
df[!, :binary] = @. ifelse(df[!, :PetalWidth] .> 1.0, 1.0, 0.0)

# One FE, Poisson
m = GLFixedEffectModels.@formula SepalLength ~ SepalWidth + GLFixedEffectModels.fe(Species)
rr1 = GLFixedEffectModels.nlreg(df, m, Poisson(), LogLink() , start = [0.2] )
# Two FE, Poisson
m = GLFixedEffectModels.@formula SepalLength ~ SepalWidth + PetalLength + GLFixedEffectModels.fe(Species) +  GLFixedEffectModels.fe(isSmall)
rr2 = GLFixedEffectModels.nlreg(df, m, Poisson(), LogLink() , start = [0.2;0.2] )

m = GLFixedEffectModels.@formula binary ~ SepalWidth + PetalLength + GLFixedEffectModels.fe(Species)
rr3 = GLFixedEffectModels.nlreg(df, m, Binomial(), LogitLink(), GLFixedEffectModels.Vcov.robust() , start = [0.2, 0.2] )

m = GLFixedEffectModels.@formula SepalLength ~ SepalWidth + PetalLength + GLFixedEffectModels.fe(Species) +  GLFixedEffectModels.fe(isSmall)
rr4 = GLFixedEffectModels.nlreg(df, m, Poisson(), LogLink() , start = [0.2;0.2] )

RegressionTables.regtable(rr1,rr2,rr3,rr4; renderSettings = RegressionTables.asciiOutput(joinpath(dirname(@__FILE__), "tables", "glftest1.txt")), regression_statistics = [:nobs, :r2, :adjr2, :r2_within, :f, :p, :f_kp, :p_kp, :dof])
@test checkfilesarethesame(joinpath(dirname(@__FILE__), "tables", "glftest1.txt"), joinpath(dirname(@__FILE__), "tables", "glftest1_reference.txt"))

rm(joinpath(dirname(@__FILE__), "tables", "glftest1.txt"))

# using Econometrics
# data = RDatasets.dataset("Ecdat", "PSID")
# data = data[data.Earnings .> 0 .&
#             data.Kids .< 98,:]
