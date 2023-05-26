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
rr7 = reg(df, @formula(SepalLength ~ SepalWidth + PetalLength&fe(isWide) + fe(isSmall)))

# GLM.jl
dobson = DataFrame(Counts = [18.,17,15,20,10,20,25,13,12],
    Outcome = repeat(["A", "B", "C"], outer = 3),
    Treatment = repeat(["a","b", "c"], inner = 3))

lm1 = fit(LinearModel, @formula(SepalLength ~ SepalWidth), df)
lm2 = fit(LinearModel, @formula(SepalLength ~ SepalWidth + PetalWidth), df)
lm3 = fit(LinearModel, @formula(SepalLength ~ SepalWidth * PetalWidth), df) # testing interactions
gm1 = fit(GeneralizedLinearModel, @formula(Counts ~ 1 + Outcome), dobson,
              Poisson())
              
# test of forula on lhs
lm4 = fit(LinearModel, @formula(log(SepalLength) ~ SepalWidth * PetalWidth), df) # testing interactions

function checkfilesarethesame(file1::String, file2::String)

    f1 = open(file1, "r")
    f2 = open(file2, "r")

    s1 = read(f1, String)
    s2 = read(f2, String)

    close(f1)
    close(f2)

    # Character-by-character comparison
    for i=1:length(s1)
        if s1[i]!=s2[i]
            println("Character $(i) different: $(s1[i]) $(s2[i])")
        end
    end

    if s1 == s2
        return true
    else
        return false
        println("File 1:")
        @show s1
        println("File 2:")
        @show s2
    end
end


# ASCII TABLES

# default
# regtable(rr1,rr2,rr3,rr4; renderSettings = asciiOutput())
#
# # display of statistics below estimates
# regtable(rr1,rr2,rr3,rr4; renderSettings = asciiOutput(), below_statistic = :blank)
# regtable(rr1,rr2,rr3,rr4; renderSettings = asciiOutput(), below_decoration = s -> "[$(s)]")
#
# # ordering of regressors, leaving out regressors
# regtable(rr1,rr2,rr3,rr4; renderSettings = asciiOutput(), regressors = ["SepalLength";"PetalWidth";"SepalWidth"])
#
# # format of the estimates
# regtable(rr1,rr2,rr3,rr4; renderSettings = asciiOutput(), estimformat = "%02.5f")
#
# # replace some variable names by other strings
# regtable(rr1,rr2,rr3; renderSettings = asciiOutput(), labels = Dict("SepalLength" => "My dependent variable: SepalLength", "PetalLength" => "Length of Petal", "PetalWidth" => "Width of Petal", "(Intercept)" => "Const." , "isSmall" => "isSmall Dummies", "SpeciesDummy" => "Species Dummies"))
#
# # do not print the FE block
# regtable(rr1,rr2,rr3,rr4; renderSettings = asciiOutput(), print_fe_section = false)
#
# # re-order fixed effects
# regtable(rr1,rr2,rr3,rr4; renderSettings = asciiOutput(), fixedeffects = ["isSmall", "SpeciesDummy"])
#
# # change the yes/no labels in the fixed effect section, and statistics labels
# regtable(rr1,rr2,rr3,rr4; renderSettings = asciiOutput(), labels = Dict("__LABEL_FE_YES__" => "Mhm.", "__LABEL_FE_NO__" => "Nope.", "__LABEL_STATISTIC_N__" => "Number of observations", "__LABEL_STATISTIC_R2__" => "R Squared"))
#
# # full set of available statistics
# regtable(rr1,rr2,rr3,rr5; renderSettings = asciiOutput(), regression_statistics = [:nobs, :r2, :adjr2, :r2_within, :f, :p, :f_kp, :p_kp, :dof])

# if you want to test locally...
# include("src/RegressionTables.jl")
# RegressionTables.regtable(rr1,rr2,rr3,rr5; renderSettings = RegressionTables.asciiOutput(), regression_statistics = [:nobs, :r2, :adjr2, :r2_within, :f, :p, :f_kp, :p_kp, :dof])
# RegressionTables.regtable(rr1,rr2,rr3,rr5,rr6,rr7; renderSettings = RegressionTables.asciiOutput(), regression_statistics = [:nobs, :r2, :adjr2, :r2_within, :f, :p, :f_kp, :p_kp, :dof])
# RegressionTables.regtable(lm1, lm2, gm1; renderSettings = RegressionTables.asciiOutput(), regression_statistics = [:nobs, :r2, :adjr2, :r2_within, :f, :p, :f_kp, :p_kp, :dof])
# RegressionTables.regtable(lm1, lm2, gm1; renderSettings = RegressionTables.asciiOutput(), regression_statistics = [:nobs, :r2], standardize_coef = true)
# RegressionTables.regtable(rr1,rr2,rr3,rr5; renderSettings = RegressionTables.latexOutput(), regression_statistics = [:nobs, :r2, :adjr2, :r2_within, :f, :p, :f_kp, :p_kp, :dof])
# RegressionTables.regtable(lm1, lm2, gm1; renderSettings = RegressionTables.latexOutput(), regression_statistics = [:nobs, :r2])
# RegressionTables.regtable(lm1, lm2, lm3, gm1; renderSettings = RegressionTables.latexOutput(), regression_statistics = [:nobs, :r2], transform_labels = RegressionTables.escape_ampersand)
# RegressionTables.regtable(rr1,rr2,rr3,rr5; renderSettings = RegressionTables.htmlOutput(), regression_statistics = [:nobs, :r2, :adjr2, :r2_within, :f, :p, :f_kp, :p_kp, :dof])
# RegressionTables.regtable(lm1, lm2, gm1; renderSettings = RegressionTables.htmlOutput(), regression_statistics = [:nobs, :r2])
# --------------
# RegressionTables.regtable(rr1,rr2,rr3,rr5; renderSettings = RegressionTables.latexOutput("test2.tex"), regression_statistics = [:nobs, :r2, :adjr2, :r2_within, :f, :p, :f_kp, :p_kp, :dof])
# RegressionTables.regtable(lm1, lm2, gm1; renderSettings = RegressionTables.latexOutput("test4.tex"), regression_statistics = [:nobs, :r2])
# RegressionTables.regtable(lm1, lm2, lm3, gm1; renderSettings = RegressionTables.latexOutput("test6.tex"), regression_statistics = [:nobs, :r2], transform_labels = RegressionTables.escape_ampersand)
# RegressionTables.regtable(rr1,rr2,rr3,rr5; renderSettings = RegressionTables.asciiOutput("test1.txt"), regression_statistics = [:nobs, :r2, :adjr2, :r2_within, :f, :p, :f_kp, :p_kp, :dof])
# RegressionTables.regtable(rr1,rr2,rr3,rr5,rr6,rr7; renderSettings = RegressionTables.asciiOutput("test7.txt"), regression_statistics = [:nobs, :r2, :adjr2, :r2_within, :f, :p, :f_kp, :p_kp, :dof])
# RegressionTables.regtable(lm1, lm2, gm1; renderSettings = RegressionTables.asciiOutput("test3.txt"), regression_statistics = [:nobs, :r2])
# RegressionTables.regtable(lm1, lm2, gm1; renderSettings = RegressionTables.asciiOutput("test5.txt"), regression_statistics = [:nobs, :r2], standardize_coef = true)
# RegressionTables.regtable(rr1,rr2,rr3,rr5; renderSettings = RegressionTables.latexOutput("test2.txt"), regression_statistics = [:nobs, :r2, :adjr2, :r2_within, :f, :p, :f_kp, :p_kp, :dof])
# RegressionTables.regtable(lm1, lm2, gm1; renderSettings = RegressionTables.latexOutput("test4.txt"), regression_statistics = [:nobs, :r2])
# RegressionTables.regtable(lm1, lm2, lm3, gm1; renderSettings = RegressionTables.latexOutput("test6.txt"), regression_statistics = [:nobs, :r2], transform_labels = RegressionTables.escape_ampersand)
# RegressionTables.regtable(rr1,rr2,rr3,rr5; renderSettings = RegressionTables.htmlOutput("test1.html"), regression_statistics = [:nobs, :r2, :adjr2, :r2_within, :f, :p, :f_kp, :p_kp, :dof])
# RegressionTables.regtable(lm1, lm2, gm1; renderSettings = RegressionTables.htmlOutput("test2.html"), regression_statistics = [:nobs, :r2])

# # new tests: all features
# RegressionTables.regtable(rr4,rr5,lm1, lm2, gm1; renderSettings = RegressionTables.asciiOutput("ftest1.txt"), regression_statistics = [:nobs, :r2, :adjr2, :r2_within, :f, :p, :f_kp, :p_kp, :dof])
# # regressors and labels
# RegressionTables.regtable(rr4,rr5,lm1, lm2, gm1; renderSettings = RegressionTables.asciiOutput("ftest2.txt"), regression_statistics = [:nobs, :r2, :adjr2, :r2_within, :f, :p, :f_kp, :p_kp, :dof], regressors = ["SepalLength", "PetalWidth"])
# # fixedeffects, estimformat, statisticformat, number_regressions_decoration
# RegressionTables.regtable(rr3,rr5,lm1, lm2, gm1; renderSettings = RegressionTables.asciiOutput("ftest3.txt"), fixedeffects = ["SpeciesDummy"], estimformat = "%0.4f", statisticformat = "%0.4f", number_regressions_decoration = i -> "[$i]")
# # estim_decoration, below_statistic, below_decoration, number_regressions
# function dec(s::String, pval::Float64)
#     if pval<0.0
#         error("p value needs to be nonnegative.")
#     end
#     if (pval > 0.05)
#         return "$s"
#     elseif (pval <= 0.05)
#         return "$s<-OMG!"
#     end
# end
# RegressionTables.regtable(rr3,rr5,lm1, lm2, gm1; renderSettings = RegressionTables.asciiOutput("ftest4.txt"), estim_decoration = dec, below_statistic = :tstat, below_decoration = s -> "[$s]", number_regressions = false)
# # print_fe_section, print_estimator_section
# RegressionTables.regtable(rr3,rr5,lm1, lm2, gm1; renderSettings = RegressionTables.asciiOutput("ftest5.txt"), print_fe_section = false, print_estimator_section = false)
# # transform_labels and custom labels
# RegressionTables.regtable(rr5,rr6,lm1, lm2, lm3; renderSettings = RegressionTables.asciiOutput("ftest6.txt"), regression_statistics = [:nobs, :r2, :adjr2, :r2_within, :f, :p, :f_kp, :p_kp, :dof], transform_labels = RegressionTables.escape_ampersand,
# labels = Dict("SepalLength" => "My dependent variable: SepalLength", "PetalLength" => "Length of Petal", "PetalWidth" => "Width of Petal", "(Intercept)" => "Const." , "isSmall" => "isSmall Dummies", "SpeciesDummy" => "Species Dummies"))


RegressionTables.regtable(rr4,rr5,lm1, lm2, gm1; renderSettings = RegressionTables.asciiOutput(joinpath(dirname(@__FILE__), "tables", "ftest1.txt")), regression_statistics = [:nobs, :r2, :adjr2, :r2_within, :f, :p, :f_kp, :p_kp, :dof])
@test checkfilesarethesame(joinpath(dirname(@__FILE__), "tables", "ftest1.txt"), joinpath(dirname(@__FILE__), "tables", "ftest1_reference.txt"))
# regressors and labels
RegressionTables.regtable(rr4,rr5,lm1, lm2, gm1; renderSettings = RegressionTables.asciiOutput(joinpath(dirname(@__FILE__), "tables", "ftest2.txt")), regression_statistics = [:nobs, :r2, :adjr2, :r2_within, :f, :p, :f_kp, :p_kp, :dof], regressors = ["SepalLength", "PetalWidth"])
@test checkfilesarethesame(joinpath(dirname(@__FILE__), "tables", "ftest2.txt"), joinpath(dirname(@__FILE__), "tables", "ftest2_reference.txt"))
# fixedeffects, estimformat, statisticformat, number_regressions_decoration
RegressionTables.regtable(rr3,rr5,lm1, lm2, gm1; renderSettings = RegressionTables.asciiOutput(joinpath(dirname(@__FILE__), "tables", "ftest3.txt")), fixedeffects = ["SpeciesDummy"], estimformat = "%0.4f", statisticformat = "%0.4f", number_regressions_decoration = i -> "[$i]")
@test checkfilesarethesame(joinpath(dirname(@__FILE__), "tables", "ftest3.txt"), joinpath(dirname(@__FILE__), "tables", "ftest3_reference.txt"))
# estim_decoration, below_statistic, below_decoration, number_regressions



function dec(s::String, pval::Float64)
    if pval<0.0
        error("p value needs to be nonnegative.")
    end
    if (pval > 0.05)
        return "$s"
    elseif (pval <= 0.05)
        return "$s<-OMG!"
    end
end
RegressionTables.regtable(rr3,rr5,lm1, lm2, gm1; renderSettings = RegressionTables.asciiOutput(joinpath(dirname(@__FILE__), "tables", "ftest4.txt")), estim_decoration = dec, below_statistic = :tstat, below_decoration = s -> "[$s]", number_regressions = false)
@test checkfilesarethesame(joinpath(dirname(@__FILE__), "tables", "ftest4.txt"), joinpath(dirname(@__FILE__), "tables", "ftest4_reference.txt"))
# print_fe_section, print_estimator_section
RegressionTables.regtable(rr3,rr5,lm1, lm2, gm1; renderSettings = RegressionTables.asciiOutput(joinpath(dirname(@__FILE__), "tables", "ftest5.txt")), print_fe_section = false, print_estimator_section = false)
@test checkfilesarethesame(joinpath(dirname(@__FILE__), "tables", "ftest5.txt"), joinpath(dirname(@__FILE__), "tables", "ftest5_reference.txt"))
# transform_labels and custom labels
RegressionTables.regtable(rr5,rr6,lm1, lm2, lm3; renderSettings = RegressionTables.asciiOutput(joinpath(dirname(@__FILE__), "tables", "ftest6.txt")), regression_statistics = [:nobs, :r2, :adjr2, :r2_within, :f, :p, :f_kp, :p_kp, :dof], transform_labels = :ampersand,
labels = Dict("SepalLength" => "My dependent variable: SepalLength", "PetalLength" => "Length of Petal", "PetalWidth" => "Width of Petal", "(Intercept)" => "Const." , "isSmall" => "isSmall Dummies", "SpeciesDummy" => "Species Dummies"))
@test checkfilesarethesame(joinpath(dirname(@__FILE__), "tables", "ftest6.txt"), joinpath(dirname(@__FILE__), "tables", "ftest6_reference.txt"))
# grouped regressions PR #61
# NOTE: behavior in ftest8 and ftest9 should be improved (Issue #63)
RegressionTables.regtable(rr1,rr5,rr2,rr4; renderSettings = RegressionTables.asciiOutput(joinpath(dirname(@__FILE__), "tables", "ftest7.txt")), groups=["grp1" "grp1" "grp2" "grp2"])
@test checkfilesarethesame(joinpath(dirname(@__FILE__), "tables", "ftest7.txt"), joinpath(dirname(@__FILE__), "tables", "ftest7_reference.txt"))
RegressionTables.regtable(rr1,rr5,rr2,rr4; renderSettings = RegressionTables.asciiOutput(joinpath(dirname(@__FILE__), "tables", "ftest8.txt")), groups=["grp1" "grp1" "looooooooooooooooogong grp2" "looooooooooooooooogong grp2"])
@test checkfilesarethesame(joinpath(dirname(@__FILE__), "tables", "ftest8.txt"), joinpath(dirname(@__FILE__), "tables", "ftest8_reference.txt"))
RegressionTables.regtable(rr5,rr1,rr2,rr4; renderSettings = RegressionTables.asciiOutput(joinpath(dirname(@__FILE__), "tables", "ftest9.txt")), groups=["grp1" "grp1" "grp2" "grp2"])
@test checkfilesarethesame(joinpath(dirname(@__FILE__), "tables", "ftest9.txt"), joinpath(dirname(@__FILE__), "tables", "ftest9_reference.txt"))

RegressionTables.regtable(rr1,rr2,rr3,rr5; renderSettings = RegressionTables.asciiOutput(joinpath(dirname(@__FILE__), "tables", "test1.txt")), regression_statistics = [:nobs, :r2, :adjr2, :r2_within, :f, :p, :f_kp, :p_kp, :dof])
@test checkfilesarethesame(joinpath(dirname(@__FILE__), "tables", "test1.txt"), joinpath(dirname(@__FILE__), "tables", "test1_reference.txt"))

RegressionTables.regtable(rr1,rr2,rr3,rr5,rr6,rr7; renderSettings = RegressionTables.asciiOutput(joinpath(dirname(@__FILE__), "tables", "test7.txt")), regression_statistics = [:nobs, :r2, :adjr2, :r2_within, :f, :p, :f_kp, :p_kp, :dof])
@test checkfilesarethesame(joinpath(dirname(@__FILE__), "tables", "test7.txt"), joinpath(dirname(@__FILE__), "tables", "test7_reference.txt"))

RegressionTables.regtable(lm1, lm2, gm1; renderSettings = RegressionTables.asciiOutput(joinpath(dirname(@__FILE__), "tables", "test3.txt")), regression_statistics = [:nobs, :r2])
@test checkfilesarethesame(joinpath(dirname(@__FILE__), "tables", "test3.txt"), joinpath(dirname(@__FILE__), "tables", "test3_reference.txt"))

RegressionTables.regtable(lm1, lm2, lm4; renderSettings = RegressionTables.asciiOutput(joinpath(dirname(@__FILE__), "tables", "test8.txt")), regression_statistics = [:nobs, :r2])
@test checkfilesarethesame(joinpath(dirname(@__FILE__), "tables", "test8.txt"), joinpath(dirname(@__FILE__), "tables", "test8_reference.txt"))

using Statistics
comments = ["Baseline", "Preferred"]
means = [Statistics.mean(df.SepalLength[rr1.esample]), Statistics.mean(df.SepalLength[rr2.esample])]
mystats = NamedTuple{(:comments, :means)}((comments, means))
RegressionTables.regtable(rr1, rr2; renderSettings = RegressionTables.asciiOutput(joinpath(dirname(@__FILE__), "tables", "test9.txt")), regression_statistics = [:nobs, :r2],custom_statistics = mystats, labels = Dict("__LABEL_CUSTOM_STATISTIC_comments__" => "Specification", "__LABEL_CUSTOM_STATISTIC_means__" => "My custom mean") )
@test checkfilesarethesame(joinpath(dirname(@__FILE__), "tables", "test9.txt"), joinpath(dirname(@__FILE__), "tables", "test9_reference.txt"))

# below_decoration = :none
RegressionTables.regtable(rr1,rr2,rr3,rr4; renderSettings = RegressionTables.asciiOutput(joinpath(dirname(@__FILE__), "tables", "test10.txt")), below_statistic = :none)
@test checkfilesarethesame(joinpath(dirname(@__FILE__), "tables", "test10.txt"), joinpath(dirname(@__FILE__), "tables", "test10_reference.txt"))


#regtable(lm1, lm2, gm1; renderSettings = asciiOutput(joinpath(dirname(@__FILE__), "tables", "test5.txt")), regression_statistics = [:nobs, :r2], standardize_coef = true)
#@test checkfilesarethesame(joinpath(dirname(@__FILE__), "tables", "test5.txt"), joinpath(dirname(@__FILE__), "tables", "test5_reference.txt"))

# LATEX TABLES

# # default
# regtable(rr1,rr2,rr3,rr4; renderSettings = latexOutput())
#
# # display of statistics below estimates
# regtable(rr1,rr2,rr3,rr4; renderSettings = latexOutput(), below_statistic = :blank)
# regtable(rr1,rr2,rr3,rr4; renderSettings = latexOutput(), below_decoration = s -> "[$(s)]")
#
# # ordering of regressors, leaving out regressors
# regtable(rr1,rr2,rr3,rr4; renderSettings = latexOutput(), regressors = ["SepalLength";"PetalWidth";"SepalWidth"])
#
# # format of the estimates
# regtable(rr1,rr2,rr3,rr4; renderSettings = latexOutput(), estimformat = "%02.5f")
#
# # replace some variable names by other strings
# regtable(rr1,rr2,rr3; renderSettings = latexOutput(), labels = Dict("SepalLength" => "My dependent variable: SepalLength", "PetalLength" => "Length of Petal", "PetalWidth" => "Width of Petal", "(Intercept)" => "Const." , "isSmall" => "isSmall Dummies", "SpeciesDummy" => "Species Dummies"))
#
# # do not print the FE block
# regtable(rr1,rr2,rr3,rr4; renderSettings = latexOutput(), print_fe_section = false)
#
# # re-order fixed effects
# regtable(rr1,rr2,rr3,rr4; renderSettings = latexOutput(), fixedeffects = ["isSmall", "SpeciesDummy"])
#
# # change the yes/no labels in the fixed effect section, and statistics labels
# regtable(rr1,rr2,rr3,rr4; renderSettings = latexOutput(), labels = Dict("__LABEL_FE_YES__" => "Mhm.", "__LABEL_FE_NO__" => "Nope.", "__LABEL_STATISTIC_N__" => "Number of observations", "__LABEL_STATISTIC_R2__" => "R Squared"))
#
# # full set of available statistics
# regtable(rr1,rr2,rr3,rr5; renderSettings = latexOutput(), regression_statistics = [:nobs, :r2, :adjr2, :r2_within, :f, :p, :f_kp, :p_kp, :dof])
#

RegressionTables.regtable(rr1,rr2,rr3,rr5; renderSettings = RegressionTables.latexOutput(joinpath(dirname(@__FILE__), "tables", "test2.tex")), regression_statistics = [:nobs, :r2, :adjr2, :r2_within, :f, :p, :f_kp, :p_kp, :dof])
@test checkfilesarethesame(joinpath(dirname(@__FILE__), "tables", "test2.tex"), joinpath(dirname(@__FILE__), "tables", "test2_reference.tex"))

RegressionTables.regtable(rr1,rr2,rr3,rr5; renderSettings = RegressionTables.latexOutput(joinpath(dirname(@__FILE__), "tables", "test3.tex")), 
                                           regression_statistics = [:nobs, :r2, :adjr2, :r2_within, :f, :p, :f_kp, :p_kp, :dof],
                                           align = :c)
@test checkfilesarethesame(joinpath(dirname(@__FILE__), "tables", "test3.tex"), joinpath(dirname(@__FILE__), "tables", "test3_reference.tex"))


RegressionTables.regtable(lm1, lm2, gm1; renderSettings = RegressionTables.latexOutput(joinpath(dirname(@__FILE__), "tables", "test4.tex")), regression_statistics = [:nobs, :r2])
@test checkfilesarethesame(joinpath(dirname(@__FILE__), "tables", "test4.tex"), joinpath(dirname(@__FILE__), "tables", "test4_reference.tex"))

RegressionTables.regtable(lm1, lm2, lm3, gm1; renderSettings = RegressionTables.latexOutput(joinpath(dirname(@__FILE__), "tables", "test6.tex")), regression_statistics = [:nobs, :r2], transform_labels = :ampersand)
@test checkfilesarethesame(joinpath(dirname(@__FILE__), "tables", "test6.tex"), joinpath(dirname(@__FILE__), "tables", "test6_reference.tex"))



# HTML Tables
RegressionTables.regtable(rr1,rr2,rr3,rr5; renderSettings = RegressionTables.htmlOutput(joinpath(dirname(@__FILE__), "tables", "test1.html")), regression_statistics = [:nobs, :r2, :adjr2, :r2_within, :f, :p, :f_kp, :p_kp, :dof])
@test checkfilesarethesame(joinpath(dirname(@__FILE__), "tables", "test1.html"), joinpath(dirname(@__FILE__), "tables", "test1_reference.html"))

RegressionTables.regtable(lm1, lm2, gm1; renderSettings = RegressionTables.htmlOutput(joinpath(dirname(@__FILE__), "tables", "test2.html")), regression_statistics = [:nobs, :r2])
@test checkfilesarethesame(joinpath(dirname(@__FILE__), "tables", "test2.html"), joinpath(dirname(@__FILE__), "tables", "test2_reference.html"))


# clean up
rm(joinpath(dirname(@__FILE__), "tables", "ftest1.txt"))
rm(joinpath(dirname(@__FILE__), "tables", "ftest2.txt"))
rm(joinpath(dirname(@__FILE__), "tables", "ftest3.txt"))
rm(joinpath(dirname(@__FILE__), "tables", "ftest4.txt"))
rm(joinpath(dirname(@__FILE__), "tables", "ftest5.txt"))
rm(joinpath(dirname(@__FILE__), "tables", "ftest6.txt"))
rm(joinpath(dirname(@__FILE__), "tables", "ftest7.txt"))
rm(joinpath(dirname(@__FILE__), "tables", "ftest8.txt"))
rm(joinpath(dirname(@__FILE__), "tables", "ftest9.txt"))

rm(joinpath(dirname(@__FILE__), "tables", "test1.txt"))
rm(joinpath(dirname(@__FILE__), "tables", "test2.tex"))
rm(joinpath(dirname(@__FILE__), "tables", "test3.txt"))
rm(joinpath(dirname(@__FILE__), "tables", "test4.tex"))
#rm(joinpath(dirname(@__FILE__), "tables", "test5.txt"))
rm(joinpath(dirname(@__FILE__), "tables", "test6.tex"))
rm(joinpath(dirname(@__FILE__), "tables", "test7.txt"))
rm(joinpath(dirname(@__FILE__), "tables", "test8.txt"))
rm(joinpath(dirname(@__FILE__), "tables", "test9.txt"))
rm(joinpath(dirname(@__FILE__), "tables", "test10.txt"))
rm(joinpath(dirname(@__FILE__), "tables", "test1.html"))
rm(joinpath(dirname(@__FILE__), "tables", "test2.html"))

# to update the reference files, re-create them from the above, then rename
# mv(joinpath(dirname(@__FILE__), "tables", "ftest1.txt"),joinpath(dirname(@__FILE__), "tables", "ftest1_reference.txt"))
# mv(joinpath(dirname(@__FILE__), "tables", "ftest2.txt"),joinpath(dirname(@__FILE__), "tables", "ftest2_reference.txt"))
# mv(joinpath(dirname(@__FILE__), "tables", "ftest3.txt"),joinpath(dirname(@__FILE__), "tables", "ftest3_reference.txt"))
# mv(joinpath(dirname(@__FILE__), "tables", "ftest4.txt"),joinpath(dirname(@__FILE__), "tables", "ftest4_reference.txt"))
# mv(joinpath(dirname(@__FILE__), "tables", "ftest5.txt"),joinpath(dirname(@__FILE__), "tables", "ftest5_reference.txt"))
# mv(joinpath(dirname(@__FILE__), "tables", "ftest6.txt"),joinpath(dirname(@__FILE__), "tables", "ftest6_reference.txt"))
# mv(joinpath(dirname(@__FILE__), "tables", "ftest7.txt"),joinpath(dirname(@__FILE__), "tables", "ftest7_reference.txt"))
# mv(joinpath(dirname(@__FILE__), "tables", "ftest8.txt"),joinpath(dirname(@__FILE__), "tables", "ftest8_reference.txt"))
# mv(joinpath(dirname(@__FILE__), "tables", "ftest9.txt"),joinpath(dirname(@__FILE__), "tables", "ftest9_reference.txt"))

# mv(joinpath(dirname(@__FILE__), "tables", "test1.txt"),joinpath(dirname(@__FILE__), "tables", "test1_reference.txt"))
# mv(joinpath(dirname(@__FILE__), "tables", "test2.tex"),joinpath(dirname(@__FILE__), "tables", "test2_reference.tex"))
# mv(joinpath(dirname(@__FILE__), "tables", "test3.txt"),joinpath(dirname(@__FILE__), "tables", "test3_reference.txt"))
# mv(joinpath(dirname(@__FILE__), "tables", "test4.tex"),joinpath(dirname(@__FILE__), "tables", "test4_reference.tex"))
# mv(joinpath(dirname(@__FILE__), "tables", "test6.tex"),joinpath(dirname(@__FILE__), "tables", "test6_reference.tex"))
# mv(joinpath(dirname(@__FILE__), "tables", "test7.txt"),joinpath(dirname(@__FILE__), "tables", "test7_reference.txt"))
# mv(joinpath(dirname(@__FILE__), "tables", "test8.txt"),joinpath(dirname(@__FILE__), "tables", "test8_reference.txt"))
# mv(joinpath(dirname(@__FILE__), "tables", "test9.txt"),joinpath(dirname(@__FILE__), "tables", "test9_reference.txt"))
# mv(joinpath(dirname(@__FILE__), "tables", "test10.txt"),joinpath(dirname(@__FILE__), "tables", "test10_reference.txt"))
# mv(joinpath(dirname(@__FILE__), "tables", "test1.html"),joinpath(dirname(@__FILE__), "tables", "test1_reference.html"))
# mv(joinpath(dirname(@__FILE__), "tables", "test2.html"),joinpath(dirname(@__FILE__), "tables", "test2_reference.html"))