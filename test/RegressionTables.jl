using RegressionTables, FixedEffectModels, RDatasets, Base.Test

df = dataset("datasets", "iris")
df[:SpeciesDummy] = pool(df[:Species])
df[:isSmall] = pool(df[:SepalWidth] .< 2.9)

rr1 = reg(df, @model(SepalLength ~ SepalWidth))
rr2 = reg(df, @model(SepalLength ~ SepalWidth + PetalLength   , fe = SpeciesDummy))
rr3 = reg(df, @model(SepalLength ~ SepalWidth + PetalLength + PetalWidth  , fe = SpeciesDummy  + isSmall))
rr4 = reg(df, @model(SepalWidth ~ SepalLength + PetalLength + PetalWidth  , fe = SpeciesDummy))
rr5 = reg(df, @model(SepalWidth ~ SepalLength + (PetalLength ~ PetalWidth)  , fe = SpeciesDummy))

function checkfilesarethesame(file1::String, file2::String)

    f1 = open(file1)
    f2 = open(file2)

    s1 = readstring(f1)
    s2 = readstring(f2)

    close(f1)
    close(f2)

    if s1 == s2
        return true
    else
        return false
    end
end


# ASCII TABLES

# default
# RegressionTables.regtable(rr1,rr2,rr3,rr4; renderSettings = RegressionTables.asciiOutput())
#
# # display of statistics below estimates
# RegressionTables.regtable(rr1,rr2,rr3,rr4; renderSettings = RegressionTables.asciiOutput(), below_statistic = :blank)
# RegressionTables.regtable(rr1,rr2,rr3,rr4; renderSettings = RegressionTables.asciiOutput(), below_decoration = s -> "[$(s)]")
#
# # ordering of regressors, leaving out regressors
# RegressionTables.regtable(rr1,rr2,rr3,rr4; renderSettings = RegressionTables.asciiOutput(), regressors = ["SepalLength";"PetalWidth";"SepalWidth"])
#
# # format of the estimates
# RegressionTables.regtable(rr1,rr2,rr3,rr4; renderSettings = RegressionTables.asciiOutput(), estimformat = "%02.5f")
#
# # replace some variable names by other strings
# RegressionTables.regtable(rr1,rr2,rr3; renderSettings = RegressionTables.asciiOutput(), labels = Dict("SepalLength" => "My dependent variable: SepalLength", "PetalLength" => "Length of Petal", "PetalWidth" => "Width of Petal", "(Intercept)" => "Const." , "isSmall" => "isSmall Dummies", "SpeciesDummy" => "Species Dummies"))
#
# # do not print the FE block
# RegressionTables.regtable(rr1,rr2,rr3,rr4; renderSettings = RegressionTables.asciiOutput(), print_fe_section = false)
#
# # re-order fixed effects
# RegressionTables.regtable(rr1,rr2,rr3,rr4; renderSettings = RegressionTables.asciiOutput(), fixedeffects = ["isSmall", "SpeciesDummy"])
#
# # change the yes/no labels in the fixed effect section, and statistics labels
# RegressionTables.regtable(rr1,rr2,rr3,rr4; renderSettings = RegressionTables.asciiOutput(), labels = Dict("__LABEL_FE_YES__" => "Mhm.", "__LABEL_FE_NO__" => "Nope.", "__LABEL_STATISTIC_N__" => "Number of observations", "__LABEL_STATISTIC_R2__" => "R Squared"))
#
# # full set of available statistics
# RegressionTables.regtable(rr1,rr2,rr3,rr5; renderSettings = RegressionTables.asciiOutput(), regression_statistics = [:nobs, :r2, :r2_a, :r2_within, :f, :p, :f_kp, :p_kp, :dof])

RegressionTables.regtable(rr1,rr2,rr3,rr5; renderSettings = RegressionTables.asciiOutput(joinpath(dirname(@__FILE__), "tables", "test1.txt")), regression_statistics = [:nobs, :r2, :r2_a, :r2_within, :f, :p, :f_kp, :p_kp, :dof])
@test checkfilesarethesame(joinpath(dirname(@__FILE__), "tables", "test1.txt"), joinpath(dirname(@__FILE__), "tables", "test1_reference.txt"))

# LATEX TABLES

# # default
# RegressionTables.regtable(rr1,rr2,rr3,rr4; renderSettings = RegressionTables.latexOutput())
#
# # display of statistics below estimates
# RegressionTables.regtable(rr1,rr2,rr3,rr4; renderSettings = RegressionTables.latexOutput(), below_statistic = :blank)
# RegressionTables.regtable(rr1,rr2,rr3,rr4; renderSettings = RegressionTables.latexOutput(), below_decoration = s -> "[$(s)]")
#
# # ordering of regressors, leaving out regressors
# RegressionTables.regtable(rr1,rr2,rr3,rr4; renderSettings = RegressionTables.latexOutput(), regressors = ["SepalLength";"PetalWidth";"SepalWidth"])
#
# # format of the estimates
# RegressionTables.regtable(rr1,rr2,rr3,rr4; renderSettings = RegressionTables.latexOutput(), estimformat = "%02.5f")
#
# # replace some variable names by other strings
# RegressionTables.regtable(rr1,rr2,rr3; renderSettings = RegressionTables.latexOutput(), labels = Dict("SepalLength" => "My dependent variable: SepalLength", "PetalLength" => "Length of Petal", "PetalWidth" => "Width of Petal", "(Intercept)" => "Const." , "isSmall" => "isSmall Dummies", "SpeciesDummy" => "Species Dummies"))
#
# # do not print the FE block
# RegressionTables.regtable(rr1,rr2,rr3,rr4; renderSettings = RegressionTables.latexOutput(), print_fe_section = false)
#
# # re-order fixed effects
# RegressionTables.regtable(rr1,rr2,rr3,rr4; renderSettings = RegressionTables.latexOutput(), fixedeffects = ["isSmall", "SpeciesDummy"])
#
# # change the yes/no labels in the fixed effect section, and statistics labels
# RegressionTables.regtable(rr1,rr2,rr3,rr4; renderSettings = RegressionTables.latexOutput(), labels = Dict("__LABEL_FE_YES__" => "Mhm.", "__LABEL_FE_NO__" => "Nope.", "__LABEL_STATISTIC_N__" => "Number of observations", "__LABEL_STATISTIC_R2__" => "R Squared"))
#
# # full set of available statistics
# RegressionTables.regtable(rr1,rr2,rr3,rr5; renderSettings = RegressionTables.latexOutput(), regression_statistics = [:nobs, :r2, :r2_a, :r2_within, :f, :p, :f_kp, :p_kp, :dof])
#

RegressionTables.regtable(rr1,rr2,rr3,rr5; renderSettings = RegressionTables.latexOutput(joinpath(dirname(@__FILE__), "tables", "test2.tex")), regression_statistics = [:nobs, :r2, :r2_a, :r2_within, :f, :p, :f_kp, :p_kp, :dof])
@test checkfilesarethesame(joinpath(dirname(@__FILE__), "tables", "test2.tex"), joinpath(dirname(@__FILE__), "tables", "test2_reference.tex"))

# clean up
rm(joinpath(dirname(@__FILE__), "tables", "test1.txt"))
rm(joinpath(dirname(@__FILE__), "tables", "test2.tex"))
