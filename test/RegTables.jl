using RegTables

using FixedEffectModels
using RDatasets

include("../src/RegTables.jl")

df = dataset("datasets", "iris")

df[:SpeciesDummy] = pool(df[:Species])
rr1 = reg(df, @model(SepalLength ~ SepalWidth   , fe = SpeciesDummy))
rr2 = reg(df, @model(SepalLength ~ SepalWidth + PetalLength   , fe = SpeciesDummy))
RegTables.regtable(rr1,rr2)

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
