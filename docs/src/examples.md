# Examples

```@contents
Pages=["examples.md"]
```

Setup for the following examples:
```@example example_run
using RegressionTables, DataFrames, RDatasets, FixedEffectModels, CategoricalArrays;
df = dataset("datasets", "iris");
df[!,:SpeciesDummy] = categorical(df[!,:Species]);
df[!,:isSmall] = categorical(df[!,:SepalWidth] .< 2.9);
rr1 = reg(df, @formula(SepalLength ~ SepalWidth));
rr2 = reg(df, @formula(SepalLength ~ SepalWidth + PetalLength + fe(SpeciesDummy)));
rr3 = reg(df, @formula(SepalLength ~ SepalWidth + PetalLength + PetalWidth + fe(SpeciesDummy) + fe(isSmall)));
rr4 = reg(df, @formula(SepalWidth ~ SepalLength + PetalLength + PetalWidth + fe(SpeciesDummy)));
rr5 = reg(df, @formula(SepalWidth ~ SepalLength + (PetalLength ~ PetalWidth) + fe(SpeciesDummy)));
```

## Default
```@repl example_run
regtable(rr1,rr2,rr3,rr4)
```

## Below Statistics
```@repl example_run
regtable(rr1,rr2,rr3,rr4; below_statistic = nothing)
regtable(rr1,rr2,rr3,rr4; below_statistic = TStat)
regtable(rr1,rr2,rr3,rr4; below_statistic = ConfInt)
```

## Standard Errors on same line as coefficient

```@repl example_run
regtable(rr1,rr2,rr3,rr4; stat_below=false)
```

## Keep, drop and order

See [Keep Drop and Order Arguments](@ref)

## Formatting Estimates, Statistics and decimal points

Also see [Customization of Defaults](@ref)

```@repl example_run
regtable(rr1,rr2,rr3,rr4; estimformat = "%02.5f")
regtable(rr1,rr2,rr3,rr4; digits = 4)
regtable(rr1,rr2,rr3,rr4; statisticformat = "%02.5f")
regtable(rr1,rr2,rr3,rr4; digits_stats = 4)
```

## Labeling Coefficients

`labels` is applied first, `transform_labels` applies to within each coefficient
```@repl example_run
regtable(rr1,rr2,rr3; labels = Dict("SepalLength" => "My dependent variable: SepalLength", "PetalLength" => "Length of Petal", "PetalWidth" => "Width of Petal", "(Intercept)" => "Const." , "isSmall" => "isSmall Dummies", "SpeciesDummy" => "Species Dummies"))
regtable(rr1, rr2, rr3; transform_labels = Dict("Width" => " Width", "Length" => " Length"))
```

## Grouping Regressions

```@repl example_run
regtable(rr1,rr2,rr4,rr3; groups = ["grp1", "grp1", "grp2", "grp2"])
regtable(rr1,rr2,rr4,rr3; groups = ["My Group:", "grp1", "grp1", "grp2", "grp2"])
regtable(rr1,rr2,rr4,rr3; groups = ["My Group:", "grp1" => 2:3, "grp2" => 4:5])
```

## Do not print X block

```@repl example_run
regtable(rr1,rr2,rr3,rr4; print_fe_section = false)
regtable(rr1,rr2,rr3,rr4; print_depvar = false)
regtable(rr1,rr2,rr3,rr4; print_estimator_section = false)
regtable(rr1,rr2,rr3,rr4; number_regressions = false)
```

## Re-order Fixed Effects

Similar arguments to [Keep Drop and Order Arguments](@ref) (equivalnet to `keep` before the `fe_suffix` is applied)
```@repl example_run
regtable(rr1,rr2,rr3,rr4; fixedeffects = [r"isSmall", "SpeciesDummy"])
```

## Change Labels for Regression Statistics

Also see [Customization of Defaults](@ref)

```@repl example_run
regtable(rr1,rr2,rr3,rr4; regression_statistics=[Nobs => "Number of Observations", R2, AdjR2 => "Adj. R2"])
```

## All Available Statistics

```@repl example_run
regtable(rr1,rr2,rr3,rr5; regression_statistics = [Nobs, R2, PseudoR2, R2CoxSnell, R2Nagelkerke, R2Deviance, AdjR2, AdjPseudoR2, AdjR2Deviance, DOF, LogLikelihood, AIC, AICC, BIC, FStat, FStatPValue, FStatIV, FStatIVPValue, R2Within])
```

## LaTeX Output

```@repl example_run
regtable(rr1,rr2,rr3,rr4; rndr = LatexTable())
```


## Extralines

Extralines are added to the end of a regression table
```@repl example_run
regtable(rr1,rr2,rr3,rr4; extralines=["Specification:", "Option 1", "Option 2", "Option 3", "Option 4"])
```

You can specify that a single value should fill two columns, note that these will inherit the alignment from their section (so with the default `align=:r`, the below example would have items below the second and fourth regression):
```@repl example_run
regtable(rr1,rr2,rr3,rr4; extralines=[
    ["Specification:", "Option 1", "Option 2", "Option 3", "Option 4"],
    ["Difference in coefficients", 1.503 => 2:3, 3.515 => 4:5]
], align=:c)
```

You can use the [DataRow](@ref) function to allow for more control, such as underlines and alignment
```@repl example_run
regtable(rr1,rr2,rr3,rr4; extralines=[
    DataRow(["Difference in coefficients", 1.503 => 2:3, 3.515 => 4:5]; align = "lcc", print_underlines=[false, true, true]),
    ["Specification:", "Option 1", "Option 2", "Option 3", "Option 4"],
    
])
```

Works similarly with HTML or Latex:
```@repl example_run
regtable(rr1,rr2,rr3,rr4; rndr=LatexTable(), extralines=[
    ["Specification:", "Option 1", "Option 2", "Option 3", "Option 4"],
    DataRow(["Difference in coefficients", 1.503 => 2:3, 3.515 => 4:5]; align = "lcc", print_underlines=[false, true, true])
]) # use DataRow to customize alignment
```