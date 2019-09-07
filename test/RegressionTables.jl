using RegressionTables
using FixedEffectModels, GLM, RDatasets, Test

df = dataset("datasets", "iris")
df[!, :SpeciesDummy] = categorical(df[!,:Species])
df[!, :isSmall] = categorical(df[!, :SepalWidth] .< 2.9)
df[!, :isWide] = categorical(df[!, :SepalWidth] .> 2.5)

# FixedEffectModels.jl
rr1 = reg(df, @model(SepalLength ~ SepalWidth))
rr2 = reg(df, @model(SepalLength ~ SepalWidth + PetalLength   , fe = SpeciesDummy))
rr3 = reg(df, @model(SepalLength ~ SepalWidth + PetalLength + PetalWidth  , fe = SpeciesDummy  + isSmall))
rr4 = reg(df, @model(SepalWidth ~ SepalLength + PetalLength + PetalWidth  , fe = SpeciesDummy))
rr5 = reg(df, @model(SepalWidth ~ SepalLength + (PetalLength ~ PetalWidth)  , fe = SpeciesDummy))
rr6 = reg(df, @model(SepalLength ~ SepalWidth, fe = SpeciesDummy * isWide + isSmall))

# GLM.jl
dobson = DataFrame(Counts = [18.,17,15,20,10,20,25,13,12],
    Outcome = categorical(repeat(["A", "B", "C"], outer = 3)),
    Treatment = categorical(repeat(["a","b", "c"], inner = 3)))

lm1 = fit(LinearModel, @formula(SepalLength ~ SepalWidth), df)
lm2 = fit(LinearModel, @formula(SepalLength ~ SepalWidth + PetalWidth), df)
lm3 = fit(LinearModel, @formula(SepalLength ~ SepalWidth * PetalWidth), df) # testing interactions
gm1 = fit(GeneralizedLinearModel, @formula(Counts ~ 1 + Outcome), dobson,
              Poisson())

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
# RegressionTables.regtable(lm1, lm2, gm1; renderSettings = RegressionTables.asciiOutput(), regression_statistics = [:nobs, :r2, :adjr2, :r2_within, :f, :p, :f_kp, :p_kp, :dof])

regtable(rr1,rr2,rr3,rr5; renderSettings = asciiOutput(joinpath(dirname(@__FILE__), "tables", "test1.txt")), regression_statistics = [:nobs, :r2, :adjr2, :r2_within, :f, :p, :f_kp, :p_kp, :dof])
@test checkfilesarethesame(joinpath(dirname(@__FILE__), "tables", "test1.txt"), joinpath(dirname(@__FILE__), "tables", "test1_reference.txt"))

regtable(rr1,rr2,rr3,rr5,rr6; renderSettings = asciiOutput(joinpath(dirname(@__FILE__), "tables", "test7.txt")), regression_statistics = [:nobs, :r2, :adjr2, :r2_within, :f, :p, :f_kp, :p_kp, :dof])
@test checkfilesarethesame(joinpath(dirname(@__FILE__), "tables", "test7.txt"), joinpath(dirname(@__FILE__), "tables", "test7_reference.txt"))

regtable(lm1, lm2, gm1; renderSettings = asciiOutput(joinpath(dirname(@__FILE__), "tables", "test3.txt")), regression_statistics = [:nobs, :r2])
@test checkfilesarethesame(joinpath(dirname(@__FILE__), "tables", "test3.txt"), joinpath(dirname(@__FILE__), "tables", "test3_reference.txt"))

regtable(lm1, lm2, gm1; renderSettings = asciiOutput(joinpath(dirname(@__FILE__), "tables", "test5.txt")), regression_statistics = [:nobs, :r2], standardize_coef = true)
@test checkfilesarethesame(joinpath(dirname(@__FILE__), "tables", "test5.txt"), joinpath(dirname(@__FILE__), "tables", "test5_reference.txt"))

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

regtable(rr1,rr2,rr3,rr5; renderSettings = latexOutput(joinpath(dirname(@__FILE__), "tables", "test2.tex")), regression_statistics = [:nobs, :r2, :adjr2, :r2_within, :f, :p, :f_kp, :p_kp, :dof])
@test checkfilesarethesame(joinpath(dirname(@__FILE__), "tables", "test2.tex"), joinpath(dirname(@__FILE__), "tables", "test2_reference.tex"))

regtable(lm1, lm2, gm1; renderSettings = latexOutput(joinpath(dirname(@__FILE__), "tables", "test4.tex")), regression_statistics = [:nobs, :r2])
@test checkfilesarethesame(joinpath(dirname(@__FILE__), "tables", "test4.tex"), joinpath(dirname(@__FILE__), "tables", "test4_reference.tex"))

regtable(lm1, lm2, lm3, gm1; renderSettings = latexOutput(joinpath(dirname(@__FILE__), "tables", "test6.tex")), regression_statistics = [:nobs, :r2], transform_labels = escape_ampersand)
@test checkfilesarethesame(joinpath(dirname(@__FILE__), "tables", "test6.tex"), joinpath(dirname(@__FILE__), "tables", "test6_reference.tex"))

# HTML Tables
regtable(rr1,rr2,rr3,rr5; renderSettings = htmlOutput(joinpath(dirname(@__FILE__), "tables", "test1.html")), regression_statistics = [:nobs, :r2, :adjr2, :r2_within, :f, :p, :f_kp, :p_kp, :dof])
@test checkfilesarethesame(joinpath(dirname(@__FILE__), "tables", "test1.html"), joinpath(dirname(@__FILE__), "tables", "test1_reference.html"))

regtable(lm1, lm2, gm1; renderSettings = htmlOutput(joinpath(dirname(@__FILE__), "tables", "test2.html")), regression_statistics = [:nobs, :r2])
@test checkfilesarethesame(joinpath(dirname(@__FILE__), "tables", "test2.html"), joinpath(dirname(@__FILE__), "tables", "test2_reference.html"))


# clean up
rm(joinpath(dirname(@__FILE__), "tables", "test1.txt"))
rm(joinpath(dirname(@__FILE__), "tables", "test2.tex"))
rm(joinpath(dirname(@__FILE__), "tables", "test3.txt"))
rm(joinpath(dirname(@__FILE__), "tables", "test4.tex"))
rm(joinpath(dirname(@__FILE__), "tables", "test5.txt"))
rm(joinpath(dirname(@__FILE__), "tables", "test1.html"))
rm(joinpath(dirname(@__FILE__), "tables", "test2.html"))


