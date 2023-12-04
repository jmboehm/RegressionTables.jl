using MixedModels, Test, RegressionTables

# include("src/RegressionTables.jl")

m1 = fit(MixedModel, @formula(yield ~ 1 + (1|batch)), MixedModels.dataset(:dyestuff); progress=false)
gm1 = fit(MixedModel, @formula(use ~ 1 + urban + livch + age + abs2(age) + (1|dist)),
              MixedModels.dataset(:contra), Bernoulli(); progress=false)
ni1 = fit(MixedModel, @formula(yield ~ 1 + (1|batch)), MixedModels.dataset(:dyestuff), Normal(); progress=false)
gm2 = fit(MixedModel, @formula(yield ~ 1 + (1|batch)), MixedModels.dataset(:dyestuff),
    Normal(), SqrtLink(); progress=false)

regtable(m1,gm1,ni1,gm2; file = joinpath(dirname(@__FILE__), "tables", "mmtest1.txt"), regression_statistics = [Nobs, R2, AdjR2, R2Within, FStat, FStatPValue, FStatIV, FStatIVPValue, DOF], digits= 1, digits_stats = 1, print_randomeffects=false)
@test checkfilesarethesame(joinpath(dirname(@__FILE__), "tables", "mmtest1.txt"), joinpath(dirname(@__FILE__), "tables", "mmtest1_reference.txt"))

rm(joinpath(dirname(@__FILE__), "tables", "mmtest1.txt"))
