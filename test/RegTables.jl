using RegTables

using FixedEffectModels
using RDatasets
using Formatting

include("../src/RegTables.jl")

df = dataset("datasets", "iris")
asciiSettings = RegTables.RenderSettings("-", " ", "\n")

df[:SpeciesDummy] = pool(df[:Species])
rr1 = reg(df, @model(SepalLength ~ SepalWidth   , fe = SpeciesDummy))
rr2 = reg(df, @model(SepalLength ~ SepalWidth + PetalLength   , fe = SpeciesDummy))
rr3 = reg(df, @model(SepalLength ~ SepalWidth + PetalLength + PetalWidth  , fe = SpeciesDummy))

tab = RegTables.regtable(rr1,rr2,rr3; lhslabel = "Test")


tab1, tab2 = RegTables.regtable(rr1,rr2,rr3; regressors = ["PetalLength";"SepalWidth"])

#statisticformat="%0.10f"
tab1, tab2 = RegTables.regtable(rr1,rr2,rr3; regressors = ["PetalLength";"SepalWidth";"PetalWidth"])


RegTables.render(STDOUT, tab, "lrr", asciiSettings)

asciiSettings = RegTables.RenderSettings("-", " ", "\n")
A = ["Variable1" "2.34" "2.56"; " " "(1.1)" "(0.9)"; "Variable2" "1.57" "4.27"; " " "(1.1)" "(1.9)"];
RegTables.render(STDOUT, A, [9;5;5], "lrr", asciiSettings)

RegTables.render(STDOUT, A, [9;5;5], "lrr", asciiSettings)

A1 = ["Variable1" "2.34***" "2.56"; " " "(1.1)" "(0.9)"; "Variable2" "1.57" "4.27"; " " "(1.1)" "(1.9)"];
A2 = ["Firm-Year FE" "Yes" "Yes"; "Firm-Product FE" "" "Yes"];
A = Vector{Array{String,2}}(2)
A[1]=A1;
A[2]=A2;

tab = RegTables.AbstractTable(3, "-", A, "-")

asciiSettings = RegTables.RenderSettings("-", "   ", "\n")
RegTables.render(STDOUT, tab, "lrr", asciiSettings)
