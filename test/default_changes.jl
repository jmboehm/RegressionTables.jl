#=
This tests whether changes to defaults work as intended

These are difficult to test elsewhere since they are global changes
which have the possibility to impact other tests if not within their
own test set
=#

using RegressionTables
using FixedEffectModels, GLM, RDatasets, Test

df = dataset("datasets", "iris")
df[!, :isSmall] = df[!, :SepalWidth] .< 2.9
df[!, :isWide] = df[!, :SepalWidth] .> 2.5

# FixedEffectModels.jl
rr1 = reg(df, @formula(SepalLength ~ SepalWidth))
rr2 = reg(df, @formula(SepalLength ~ SepalWidth + PetalLength + fe(Species)))
rr3 = reg(df, @formula(SepalLength ~ SepalWidth + PetalLength + PetalWidth + fe(Species) + fe(isSmall)))
rr4 = reg(df, @formula(SepalWidth ~ SepalLength + PetalLength + PetalWidth + fe(Species)))
rr5 = reg(df, @formula(SepalWidth ~ SepalLength + (PetalLength ~ PetalWidth) + fe(Species)))
rr6 = reg(df, @formula(SepalLength ~ SepalWidth + fe(Species)&fe(isWide) + fe(isSmall)))
rr7 = glm(@formula(isSmall ~ SepalLength + PetalLength), df, Binomial())
##

RegressionTables.default_digits(::AbstractRenderType, x::RegressionTables.AbstractRegressionStatistic) = 4
tab = regtable(rr1, rr2, rr3, rr4, rr5, rr6, rr7)

@test tab[3, 2] == "6.526***" # rr1 intercept coefficient
@test tab[8, end] == "(0.321)" # rr7 petalLength stdError
@test tab[18, 4] == "0.8673" # rr3 R2

RegressionTables.default_digits(render::AbstractRenderType, x::RegressionTables.AbstractRegressionStatistic) = RegressionTables.default_digits(render, RegressionTables.value(x))
##
RegressionTables.default_digits(::RegressionTables.AbstractAscii, x::RegressionTables.AbstractUnderStatistic) = 4
tab = regtable(rr1, rr2, rr3, rr4, rr5, rr6, rr7)
@test tab[3, 2] == "6.526***" # rr1 intercept coefficient
@test tab[8, end] == "(0.3210)" # rr7 petalLength stdError
@test tab[18, 4] == "0.867" # rr3 R2

tab2 = regtable(rr1, rr2, rr3, rr4, rr5, rr6, rr7, render = LatexTable())

@test tab2[8, end] == "(0.321)"

RegressionTables.default_digits(render::RegressionTables.AbstractAscii, x::RegressionTables.AbstractUnderStatistic) = RegressionTables.default_digits(render, RegressionTables.value(x))

##

RegressionTables.default_digits(::AbstractRenderType, x::RegressionTables.CoefValue) = 2

@test tab[3, 2] == "6.53***" # rr1 intercept coefficient
@test tab[8, end] == "(0.321)" # rr7 petalLength stdError
@test tab[18, 4] == "0.867" # rr3 R2

RegressionTables.default_digits(render::AbstractRenderType, x::RegressionTables.CoefValue) = RegressionTables.default_digits(render, RegressionTables.value(x))

##

RegressionTables.default_digits(::AbstractRenderType, x) = 4

tab = regtable(rr1, rr2, rr3, rr4, rr5, rr6, rr7)

@test tab[3, 2] == "6.5262***" # rr1 intercept coefficient
@test tab[8, end] == "(0.3210)" # rr7 petalLength stdError
@test tab[18, 4] == "0.8673" # rr3 R2

RegressionTables.default_digits(::AbstractRenderType, x) = 3

##

RegressionTables.default_align(::AbstractRenderType) = :c

tab = regtable(rr1, rr2, rr3, rr4, rr5, rr6, rr7)
@test tab.align == "lccccccc"

RegressionTables.default_align(render::AbstractRenderType) = :r

##

RegressionTables.default_header_align(::AbstractRenderType) = :l

tab = regtable(rr1, rr2, rr3, rr4, rr5, rr6, rr7)
@test tab.data[1].align == "lllll"

RegressionTables.default_header_align(render::AbstractRenderType) = :c

##

@test tab[1, 2] == "SepalLength"

RegressionTables.default_depvar(::AbstractRenderType) = false

tab = regtable(rr1, rr2, rr3, rr4, rr5, rr6, rr7)

@test tab[1, 2] == "(1)"

RegressionTables.default_depvar(::AbstractRenderType) = true

##

RegressionTables.default_number_regressions(render::AbstractRenderType, rrs) = false

tab = regtable(rr1, rr2, rr3, rr4, rr5, rr6, rr7)
@test tab[2, 2] == "6.526***"

RegressionTables.default_number_regressions(render::AbstractRenderType, rrs) = length(rrs) > 1

##

RegressionTables.default_print_fe(render::AbstractRenderType, rrs) = false

tab = regtable(rr1, rr2, rr3, rr4, rr5, rr6, rr7)

@test tab[13, 1] == "Estimator"
@test tab[14, 1] == "N"

RegressionTables.default_print_fe(render::AbstractRenderType, rrs) = true

##

RegressionTables.default_keep(render::AbstractRenderType, rrs) = [1:3]
tab = regtable(rr1, rr2, rr3, rr4, rr5, rr6, rr7)
@test length(tab.data) == 18

RegressionTables.default_keep(render::AbstractRenderType, rrs) = String[]

##

RegressionTables.default_drop(render::AbstractRenderType, rrs) = [1:3]
tab = regtable(rr1, rr2, rr3, rr4, rr5, rr6, rr7)
@test length(tab.data) == 16

RegressionTables.default_drop(render::AbstractRenderType, rrs) = String[]

##

RegressionTables.default_order(render::AbstractRenderType, rrs) = ["PetalLength"]

tab = regtable(rr1, rr2, rr3, rr4, rr5, rr6, rr7)
@test tab[3, 1] == "PetalLength"

RegressionTables.default_order(render::AbstractRenderType, rrs) = String[]

##

RegressionTables.default_fixedeffects(render::AbstractRenderType, rrs) = [r"Species"]

tab = regtable(rr1, rr2, rr3, rr4, rr5, rr6, rr7)
@test length(tab.data) == 20

RegressionTables.default_fixedeffects(render::AbstractRenderType, rrs) = String[]

##

RegressionTables.default_labels(render::AbstractRenderType, rrs) = Dict("SepalLength" => "Sepal Length")

tab = regtable(rr1, rr2, rr3, rr4, rr5, rr6, rr7)

@test tab[11, 1] == "Sepal Length"
@test tab[9, 1] == "PetalWidth"

RegressionTables.default_labels(render::AbstractRenderType, rrs) = Dict{String, String}()

##

RegressionTables.default_below_statistic(render::AbstractRenderType) = TStat

tab = regtable(rr1, rr2, rr3, rr4, rr5, rr6, rr7)
@test tab[4, 2] == "(13.628)"
@test tab[6, 3] == "(5.310)"

RegressionTables.default_below_statistic(render::AbstractRenderType) = StdError

##

RegressionTables.default_stat_below(render::AbstractRenderType) = false

tab = regtable(rr1, rr2, rr3, rr4, rr5, rr6, rr7)

@test tab[3, 2] == "6.526*** (0.479)"

RegressionTables.default_stat_below(render::AbstractRenderType) = true

##

RegressionTables.label_p(render::AbstractRenderType) = "P"
RegressionTables.interaction_combine(render::AbstractRenderType) = " x "
RegressionTables.wrapper(render::RegressionTables.AbstractLatex, s) = "\$^{$s}\$"
RegressionTables.interaction_combine(render::RegressionTables.AbstractLatex) = " \\& "
RegressionTables.categorical_equal(render::RegressionTables.AbstractLatex) = " ="

rr1 = reg(df, @formula(SepalLength ~ SepalWidth))
rr2 = reg(df, @formula(SepalLength ~ SepalWidth + PetalLength + Species))
rr3 = reg(df, @formula(SepalLength ~ SepalWidth * PetalLength + PetalWidth + fe(Species) + fe(isSmall)))

tab = regtable(rr1, rr2, rr3; regression_statistics=[Nobs, R2, FStatPValue])

@test tab[21, 1] == "F-test P value"
@test tab[15, 1] == "SepalWidth x PetalLength"
@test tab[11, 1] == "Species: virginica"

tab = regtable(rr1, rr2, rr3; regression_statistics=[Nobs, R2, FStatPValue], render=LatexTable())

@test tab[21, 1] == "\$F\$-test \$P\$ value"
@test tab[15, 1] == "SepalWidth \\& PetalLength"
@test tab[11, 1] == "Species = virginica"

RegressionTables.label_p(render::AbstractRenderType) = "p"
RegressionTables.interaction_combine(render::AbstractRenderType) = " & "
RegressionTables.wrapper(render::RegressionTables.AbstractLatex, s) = s
RegressionTables.interaction_combine(render::RegressionTables.AbstractLatex) = " \$\\times\$ "
RegressionTables.categorical_equal(render::RegressionTables.AbstractLatex) = ":"