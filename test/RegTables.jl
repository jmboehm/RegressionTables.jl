using RegTables

using FixedEffectModels
using RDatasets

include("src/RegTables.jl")

df = dataset("datasets", "iris")



df[:SpeciesDummy] = pool(df[:Species])
rr1 = reg(df, @model(SepalLength ~ SepalWidth   , fe = SpeciesDummy))
rr2 = reg(df, @model(SepalLength ~ SepalWidth + PetalLength   , fe = SpeciesDummy))
RegTables.regtable(rr1,rr2)
