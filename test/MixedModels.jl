using MixedModels, Test

# include("src/RegressionTables.jl")

m1 = fit(MixedModel, @formula(yield ~ 1 + (1|batch)), MixedModels.dataset(:dyestuff); progress=false)
gm1 = fit(MixedModel, @formula(use ~ 1 + urban + livch + age + abs2(age) + (1|dist)),
              MixedModels.dataset(:contra), Bernoulli(); progress=false)
ni1 = fit(MixedModel, @formula(yield ~ 1 + (1|batch)), MixedModels.dataset(:dyestuff), Normal(); progress=false)
gm2 = fit(MixedModel, @formula(yield ~ 1 + (1|batch)), MixedModels.dataset(:dyestuff),
    Normal(), SqrtLink(); progress=false)

RegressionTables.regtable(m1,gm1,ni1,gm2; renderSettings = RegressionTables.asciiOutput(joinpath(dirname(@__FILE__), "tables", "mmtest1.txt")), regression_statistics = [:nobs, :r2, :adjr2, :r2_within, :f, :p, :f_kp, :p_kp, :dof])
@test checkfilesarethesame(joinpath(dirname(@__FILE__), "tables", "mmtest1.txt"), joinpath(dirname(@__FILE__), "tables", "mmtest1_reference.txt"))

rm(joinpath(dirname(@__FILE__), "tables", "mmtest1.txt"))
