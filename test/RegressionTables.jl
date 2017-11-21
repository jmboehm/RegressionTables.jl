using RegressionTables

using FixedEffectModels
using RDatasets
using Formatting

include("../src/RegressionTables.jl")

df = dataset("datasets", "iris")
#asciiSettings = RegressionTables.RenderSettings("-", " ", "\n")

df[:SpeciesDummy] = pool(df[:Species])
rr1 = reg(df, @model(SepalLength ~ SepalWidth   , fe = SpeciesDummy))
rr2 = reg(df, @model(SepalLength ~ SepalWidth + PetalLength   , fe = SpeciesDummy))
rr3 = reg(df, @model(SepalLength ~ SepalWidth + PetalLength + PetalWidth  , fe = SpeciesDummy))

tab = RegressionTables.regtable(rr1,rr2,rr3; lhslabel = "Test")


tab1, tab2 = RegressionTables.regtable(rr1,rr2,rr3; renderSettings = RegressionTables.asciiOutput())


# label = "Dependent variable: SepalLength (Adjusted for blah)"
# tab1, tab2 = RegressionTables.regtable(rr1,rr2,rr3; renderSettings = RegressionTables.asciiOutput())

# try latex output
tab1, tab2 = RegressionTables.regtable(rr1,rr2,rr3; renderSettings = RegressionTables.latexOutput())

f = open("test.txt", "w")
println(f, "Test")
close(f)






#statisticformat="%0.10f"
tab1, tab2 = RegressionTables.regtable(rr1,rr2,rr3; regressors = ["PetalLength";"SepalWidth";"PetalWidth"])


RegressionTables.render(STDOUT, tab, "lrr", asciiSettings)

asciiSettings = RegressionTables.RenderSettings("-", " ", "\n")
A = ["Variable1" "2.34" "2.56"; " " "(1.1)" "(0.9)"; "Variable2" "1.57" "4.27"; " " "(1.1)" "(1.9)"];
RegressionTables.render(STDOUT, A, [9;5;5], "lrr", asciiSettings)

RegressionTables.render(STDOUT, A, [9;5;5], "lrr", asciiSettings)

A1 = ["Variable1" "2.34***" "2.56"; " " "(1.1)" "(0.9)"; "Variable2" "1.57" "4.27"; " " "(1.1)" "(1.9)"];
A2 = ["Firm-Year FE" "Yes" "Yes"; "Firm-Product FE" "" "Yes"];
A = Vector{Array{String,2}}(2)
A[1]=A1;
A[2]=A2;

tab = RegressionTables.AbstractTable(3, "-", A, "-")

asciiSettings = RegressionTables.RenderSettings("-", "   ", "\n")
RegressionTables.render(STDOUT, tab, "lrr", asciiSettings)
