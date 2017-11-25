using RegressionTables

using FixedEffectModels
using RDatasets
using Formatting

include("../src/RegressionTables.jl")

df = dataset("datasets", "iris")
df[:SpeciesDummy] = pool(df[:Species])

rr1 = reg(df, @model(SepalLength ~ SepalWidth   , fe = SpeciesDummy))
rr2 = reg(df, @model(SepalLength ~ SepalWidth + PetalLength   , fe = SpeciesDummy))
rr3 = reg(df, @model(SepalLength ~ SepalWidth + PetalLength + PetalWidth  , fe = SpeciesDummy))
rr4 = reg(df, @model(SepalWidth ~ SepalLength + PetalLength + PetalWidth  , fe = SpeciesDummy))

# ASCII TABLES

tab1, tab2 = RegressionTables.regtable(rr1,rr2,rr3,rr4; renderSettings = RegressionTables.asciiOutput())

# display of statistics below estimates
tab1, tab2 = RegressionTables.regtable(rr1,rr2,rr3,rr4; renderSettings = RegressionTables.asciiOutput(), below_statistic = :blank)
tab1, tab2 = RegressionTables.regtable(rr1,rr2,rr3,rr4; renderSettings = RegressionTables.asciiOutput(), below_decoration = s -> "[$(s)]")

# ordering of regressors, leaving out regressors
tab1, tab2 = RegressionTables.regtable(rr1,rr2,rr3,rr4; renderSettings = RegressionTables.asciiOutput(), regressors = ["SepalLength";"PetalWidth";"SepalWidth"])

# format of the estimates
tab1, tab2 = RegressionTables.regtable(rr1,rr2,rr3,rr4; renderSettings = RegressionTables.asciiOutput(), estimformat = "%02.5f")


# LATEX TABLES

tab1, tab2 = RegressionTables.regtable(rr1,rr2,rr3,rr4; renderSettings = RegressionTables.latexOutput())
