
[![dev][docs-dev-img]][docs-dev-url]
[![stable][docs-stable-img]][docs-stable-url]
[![Build Status](https://travis-ci.org/jmboehm/RegressionTables.jl.svg?branch=master)](https://travis-ci.org/jmboehm/RegressionTables.jl) [![codecov.io](http://codecov.io/github/jmboehm/RegressionTables.jl/coverage.svg?branch=master)](http://codecov.io/github/jmboehm/RegressionTables.jl?branch=master) [![DOI](https://zenodo.org/badge/110714417.svg)](https://zenodo.org/badge/latestdoi/110714417)

[docs-dev-img]: https://img.shields.io/badge/docs-dev-blue.svg?style=flat-square
[docs-dev-url]: https://jmboehm.github.io/RegressionTables.jl/dev/
[docs-stable-img]: https://img.shields.io/badge/docs-stable-blue.svg?style=flat-square
[docs-stable-url]: https://jmboehm.github.io/RegressionTables.jl/stable/

# RegressionTables.jl

This package provides publication-quality regression tables for use with [FixedEffectModels.jl](https://github.com/matthieugomez/FixedEffectModels.jl), [GLM.jl](https://github.com/JuliaStats/GLM.jl), [GLFixedEffectModels.jl](https://github.com/jmboehm/GLFixedEffectModels.jl) and [MixedModels.jl](https://github.com/JuliaStats/MixedModels.jl), as well as any package that implements the [RegressionModel abstraction](https://juliastats.org/StatsBase.jl/latest/statmodels/).

In its objective it is similar to  (and heavily inspired by) the Stata command [`esttab`](http://repec.sowi.unibe.ch/stata/estout/esttab.html) and the R package [`stargazer`](https://cran.r-project.org/web/packages/stargazer/).
## Table of Contents

- [RegressionTables.jl](#regressiontablesjl)
  - [Table of Contents](#table-of-contents)
  - [Installation](#installation)
  - [A brief demonstration](#a-brief-demonstration)
  - [Function Reference](#function-reference)
    - [Arguments](#arguments)
    - [Details](#details)
  - [Main Changes for v0.6](#main-changes-for-v06)
    - [New Features](#new-features)
    - [Changes to Defaults](#changes-to-defaults)
    - [Changes to Labeling](#changes-to-labeling)
    - [`custom_statistics` replaced by `extralines`](#custom_statistics-replaced-by-extralines)
    - [`print_result` and `out_buffer` arguments are gone](#print_result-and-out_buffer-arguments-are-gone)
    - [Other Deprecation Warnings that should not change results](#other-deprecation-warnings-that-should-not-change-results)

## Installation

To install the package, type in the Julia command prompt

```julia
] add RegressionTables
```

## A brief demonstration

```julia
using RegressionTables, DataFrames, FixedEffectModels, RDatasets, GLM

df = dataset("datasets", "iris")

rr1 = reg(df, @formula(SepalLength ~ SepalWidth + fe(Species)))
rr2 = reg(df, @formula(SepalLength ~ SepalWidth + PetalLength + fe(Species)))
rr3 = reg(df, @formula(SepalLength ~ SepalWidth * PetalLength + PetalWidth + fe(Species)))
rr4 = reg(df, @formula(SepalWidth ~ SepalLength + PetalLength + PetalWidth + fe(Species)))
rr5 = glm(@formula(SepalWidth < 2.9 ~ PetalLength + PetalWidth + Species), df, Binomial())

regtable(
    rr1,rr2,rr3,rr4,rr5;
    render = AsciiTable(),
    labels = Dict(
        "versicolor" => "Versicolor",
        "virginica" => "Virginica",
        "PetalLength" => "Petal Length",
    ),
    regression_statistics = [
        Nobs => "Obs.",
        R2,
        R2Within,
        PseudoR2 => "Pseudo-R2",
    ],
    extralines = [
        ["Main Coefficient", "SepalWidth", "SepalWidth", "Petal Length", "Petal Length", "Intercept"],
        DataRow(["Coef Diff", 0.372 => 2:3, 1.235 => 3:4, ""], align="lccr")
    ],
    order = [r"Int", r" & ", r": "]
)
```
yields
```
----------------------------------------------------------------------------------------------------
                                          SepalLength                 SepalWidth    SepalWidth < 2.9
                            --------------------------------------   ------------   ----------------
                                   (1)          (2)            (3)            (4)                (5)
----------------------------------------------------------------------------------------------------
(Intercept)                                                                                   -1.917
                                                                                             (1.242)
SepalWidth & Petal Length                                   -0.070
                                                           (0.041)
Species: Versicolor                                                                        10.441***
                                                                                             (1.957)
Species: Virginica                                                                         13.230***
                                                                                             (2.636)
SepalWidth                    0.804***     0.432***       0.719***
                               (0.106)      (0.081)        (0.155)
Petal Length                               0.776***       1.047***        -0.188*             -0.773
                                            (0.064)        (0.143)        (0.083)            (0.554)
PetalWidth                                                  -0.259       0.626***           -3.782**
                                                           (0.154)        (0.123)            (1.256)
SepalLength                                                              0.378***
                                                                          (0.066)
----------------------------------------------------------------------------------------------------
Species Fixed Effects              Yes          Yes            Yes            Yes
----------------------------------------------------------------------------------------------------
Estimator                          OLS          OLS            OLS            OLS           Binomial
----------------------------------------------------------------------------------------------------
Obs.                               150          150            150            150                150
R2                               0.726        0.863          0.870          0.635
Within-R2                        0.281        0.642          0.659          0.391
Pseudo-R2                        0.527        0.811          0.831          0.862              0.347
Main Coefficient            SepalWidth   SepalWidth   Petal Length   Petal Length          Intercept
Coef Diff                            0.372                      1.235
----------------------------------------------------------------------------------------------------
```
LaTeX output can be generated by using
```julia
regtable(rr1,rr2,rr3,rr4; render = LatexTable())
```
which yields
```
\begin{tabular}{lrrrr}
\toprule
                                & \multicolumn{3}{c}{SepalLength} & \multicolumn{1}{c}{SepalWidth} \\ 
\cmidrule(lr){2-4} \cmidrule(lr){5-5} 
                                &      (1) &      (2) &       (3) &                            (4) \\ 
\midrule
SepalWidth                      & 0.804*** & 0.432*** &  0.719*** &                                \\ 
                                &  (0.106) &  (0.081) &   (0.155) &                                \\ 
PetalLength                     &          & 0.776*** &  1.047*** &                        -0.188* \\ 
                                &          &  (0.064) &   (0.143) &                        (0.083) \\ 
PetalWidth                      &          &          &    -0.259 &                       0.626*** \\ 
                                &          &          &   (0.154) &                        (0.123) \\ 
SepalWidth $\times$ PetalLength &          &          &    -0.070 &                                \\ 
                                &          &          &   (0.041) &                                \\ 
SepalLength                     &          &          &           &                       0.378*** \\ 
                                &          &          &           &                        (0.066) \\ 
\midrule
SpeciesDummy Fixed Effects      &      Yes &      Yes &       Yes &                            Yes \\ 
\midrule
$N$                             &      150 &      150 &       150 &                            150 \\ 
$R^2$                           &    0.726 &    0.863 &     0.870 &                          0.635 \\ 
Within-$R^2$                    &    0.281 &    0.642 &     0.659 &                          0.391 \\ 
\bottomrule
\end{tabular}
```
Similarly, HTML tables can be created with `HtmlTable()`.

Send the output to a text file by passing the destination file as a keyword argument:
```julia
regtable(rr1,rr2,rr3,rr4; render = LatexTable(), file="myoutputfile.tex")
```
then use `\input` in LaTeX to include that file in your code. Be sure to use the `booktabs` package:
```latex
\documentclass{article}
\usepackage{booktabs}

\begin{document}

\begin{table}
\label{tab:mytable}
\input{myoutputfile}
\end{table}

\end{document}
```

`regtable()` can also print `TableRegressionModel`'s from [GLM.jl](https://github.com/JuliaStats/GLM.jl) (and output from other packages that produce `TableRegressionModel`'s):
```julia
using GLM

dobson = DataFrame(Counts = [18.,17,15,20,10,20,25,13,12],
    Outcome = categorical(repeat(["A", "B", "C"], outer = 3)),
    Treatment = categorical(repeat(["a","b", "c"], inner = 3)))
rr1 = fit(LinearModel, @formula(SepalLength ~ SepalWidth), df)
lm1 = fit(LinearModel, @formula(SepalLength ~ SepalWidth), df)
gm1 = fit(GeneralizedLinearModel, @formula(Counts ~ 1 + Outcome + Treatment), dobson,
                  Poisson())

regtable(rr1,lm1,gm1)
```
yields
```
---------------------------------------------
                   SepalLength        Counts 
               -------------------   --------
                    (1)        (2)        (3)
---------------------------------------------
(Intercept)    6.526***   6.526***   3.045***
                (0.479)    (0.479)    (0.171)
SepalWidth       -0.223     -0.223           
                (0.155)    (0.155)           
Outcome: B                             -0.454
                                      (0.202)
Outcome: C                             -0.293
                                      (0.193)
Treatment: b                            0.000
                                      (0.200)
Treatment: c                           -0.000
                                      (0.200)
---------------------------------------------
Estimator           OLS        OLS    Poisson
---------------------------------------------
N                   150        150          9
R2                0.014      0.014           
Pseudo R2         0.006      0.006      0.104
---------------------------------------------
```
Printing of `StatsBase.RegressionModel`s (e.g., MixedModels.jl and GLFixedEffectModels.jl) generally works but are less well tested; please file as issue if you encounter problems printing them.

## Function Reference

### Arguments
* `rr::FixedEffectModel...` are the `FixedEffectModel`s from `FixedEffectModels.jl` that should be printed. Only required argument.
* `keep` is a `Vector` of regressor names (`String`s), integers, ranges or regex that should be shown, in that order. Defaults to an empty vector, in which case all regressors will be shown.
* `drop` is a `Vector` of regressor names (`String`s), integers, ranges or regex that should not be shown. Defaults to an empty vector, in which case no regressors will be dropped.
* `order` is a `Vector` of regressor names (`String`s), integers, ranges or regex that should be shown in that order. Defaults to an empty vector, in which case the order of regressors will be unchanged. Other regressors are still shown (assuming `drop` is empty)
* `fixedeffects` is a `Vector` of FE names (`String`s), integers, ranges or regex that should be shown, in that order. Defaults to an empty vector, in which case all FE's will be shown.
* `align` is a `Symbol` from the set `[:l,:c,:r]` indicating the alignment of results columns (default `:r` right-aligned). Currently works only with ASCII and LaTeX output.
* `header_align` is a `Symbol` from the set `[:l,:c,:r]` indicating the alignment of the header row (default `:c` centered). Currently works only with ASCII and LaTeX output.
* `labels` is a `Dict` that contains displayed labels for variables (`String`s) and other text in the table. If no label for a variable is found, it default to variable names. See documentation for special values.
* `estimformat` is a `String` that describes the format of the estimate.
* `digits` is an `Int` that describes the precision to be shown in the estimate. Defaults to `nothing`, which means the default (3) is used (default can be changed by setting `RegressionTables.default_digits(render::AbstractRenderType, x) = 3`).
* `statisticformat` is a `String` that describes the format of the number below the estimate (se/t).
* `digits_stats` is an `Int` that describes the precision to be shown in the statistics. Defaults to `nothing`, which means the default (3) is used (default can be changed by setting `RegressionTables.default_digits(render::AbstractRenderType, x) = 3`).
* `below_statistic` is a type that describes a statistic that should be shown below each point estimate. Recognized values are `nothing`, `StdError`, `TStat`, and `ConfInt`. `nothing` suppresses the line. Defaults to `StdError`.
* `regression_statistics` is a `Vector` of types that describe statistics to be shown at the bottom of the table. Built in types are Recognized symbols are `Nobs`, `R2`, `PseudoR2`, `R2CoxSnell`, `R2Nagelkerke`, `R2Deviance`, `AdjR2`, `AdjPseudoR2`, `AdjR2Deviance`, `DOF`, `LogLikelihood`, `AIC`, `AICC`, `BIC`, `FStat`, `FStatPValue`, `FStatIV`, `FStatIVPValue`, R2Within. Defaults vary based on regression inputs (simple linear model is [Nobs, R2]).
* `extralines` is a `Vector` or a `Vector{<:AbsractVector}` that will be added to the end of the table. A single vector will be its own row, a vector of vectors will each be a row. Defaults to `nothing`.
* `number_regressions` is a `Bool` that governs whether regressions should be numbered. Defaults to `true`.
* `groups` is a `Vector`, `Vector{<:AbstractVector}` or `Matrix` of labels used to group regressions. This can be useful if results are shown for different data sets or sample restrictions.
* `print_fe_section` is a `Bool` that governs whether a section on fixed effects should be shown. Defaults to `true`.
* `print_estimator_section`  is a `Bool` that governs whether to print a section on which estimator (OLS/IV/Binomial/Poisson...) is used. Defaults to `true` if more than one value is displayed.
* `standardize_coef` is a `Bool` that governs whether the table should show standardized coefficients. Note that this only works with `TableRegressionModel`s, and that only coefficient estimates and the `below_statistic` are being standardized (i.e. the R^2 etc still pertain to the non-standardized regression).
* `render::AbstractRenderType` is a `AbstractRenderType` type that governs how the table should be rendered. Standard supported types are ASCII (via `AsciiTable()`) and LaTeX (via `LatexTable()`). Defaults to `AsciiTable()`.
* `file` is a `String` that governs whether the table should be saved to a file. Defaults to `nothing`.
* `transform_labels` is a `Dict` or one of the `Symbol`s `:ampersand`, `:underscore`, `:underscore2space`, `:latex`

### Details
A typical use is to pass a number of `FixedEffectModel`s to the function, along with how it should be rendered (with `render` argument):
```julia
regtable(regressionResult1, regressionResult2; render = AsciiTable())
```

Pass a string to the `file` argument to create or overwrite a file. For example, using LaTeX output,
```julia
regtable(regressionResult1, regressionResult2; render = LatexTable(), file="myoutfile.tex")
```

## Main Changes for v0.6

Version 0.6 was a major rewrite of the backend with the goal of increasing the flexibility and decreasing the dependencies on other packages (regression packages are now extensions). While most code written with v0.5 should continue to run, there might be a few differences and some deprecation warnings. Below is a brief overview of the changes:

### New Features

- There is an `extralines` argument that can accept vectors with pairs, where the pair defines a multicolumn value (`["Label", "two columns" => 2:3, 1.5 => 4:5]`), it can also accept a `DataRow` object that allows for more control.
- New `keep` `drop` and `order` arguments allow exact names, regex to search within names, integers to select specific values, and ranges (`1:4`) to select groups, and they can be mixed (`[1:2, :end, r"Width"]`)
- `labels` now applies to individual parts of an interaction or categorical coefficient name (hopefully reducing the number of labels required)
- The interaction symbol now depends on the table type, so in Latex, the interactions will have ` \$\\times\$ `
  - Using a Latex table will also automatically escape parts of coefficient names (if no other labels are provided)
- A confidence interval is now an option for a below statistic (`below_statistic=ConfInt`)
- Several defaults are different to try and provide more relevant information (see changes do defaults section)
- Fixed effect values now have a suffix (defaults to `" Fixed Effects"`) so that labeling can be simpler. Disable by setting `print_fe_suffix=false`
- It is now possible to print the coefficient value and "under statistic" on the same line (`stat_below=false`)
- It is possible to define custom regression statistics that are calculated based on the regressions provided
- It is possible to change the order of the major blocks in a regression table
- Using RegressionTables for descriptive statistics is now easier. Describe a DataFrame (`df_described=describe(df)`) and provide that to a RegressionTable (`tab = RegressionTable(names(df_described), Matrix(df_described))`), there are also options to render the table as a `LatexTable` or `HtmlTable`. Write this to a file using `write(file_name, tab)`
- It is possible to overwrite almost any setting. For example, to make T-Statistics the default in all tables, run `RegressionTables.default_below_statistic(render::AbstractRenderType)=TStat`
- Option to show clustering (`print_clusters=true`).
  - Can also be the size of the clusters by running `Base.repr(render::AbstractRenderType, x::RegressionTables.ClusterValue; args...) = repr(render, value(x); args...)`
- Several new regression statistics are now available, the full list is: `[Nobs, R2, PseudoR2, R2CoxSnell, R2Nagelkerke, R2Deviance, AdjR2, AdjPseudoR2, AdjR2Deviance, DOF, LogLikelihood, AIC, AICC, BIC, FStat, FStatPValue, FStatIV, FStatIVPValue, R2Within]`
- Use `LatexTableStar` to create a table that expands the entire text width

### Changes to Defaults

There are some changes to the defaults from version 0.5 and two additional settings

- Interactions in coefficients now vary based on the type of table. In Latex, this now defaults to ` $\\times$ ` and in HTML ` &times; `. These can be changed by running:
  - `RegressionTables.interaction_combine(render::AbstractRenderType) = " & "`
  - `RegressionTables.interaction_combine(render::AbstractLatex) = " & "`
  - `RegressionTables.interaction_combine(render::AbstractHtml) = " & "`
- `print_estimator` default was `true`, now it is `true` if more than one type of regression is provided (i.e., "IV" and "OLS" will display the estimator, all "OLS" will not). Set to the old default by running:
  - `RegressionTables.default_print_estimator(x::AbstractRenderType, rrs) = true`
- `number_regressions` default was `true`, now it is `true` if more than one regression is provided. Set to the old default by running:
  - `RegressionTables.default_number_regressions(x::AbstractRenderType, rrs) = true`
- `regression_statistics` default was `[Nobs, R2]`, these will vary based on provided regressions. For example, a fixed effect regression will default to `[Nobs, R2, R2Within]` and a Probit regression will default to `[Nobs, PseudoR2]` (and if multiple types, these will be combined). Set to the old default by running:
  - `RegressionTables.default_regression_statistics(x::AbstractRenderType, rrs::Tuple) = [Nobs, R2]`
- Labels for the type of the regression are more varied for non-linear cases, instead of "NL", it will display "Poisson", "Probit", etc. These can be changed by running:
  - `RegressionTables.label_distribution(x::AbstractRenderType, d::Probit) = "NL"`
- `print_fe_suffix` is a new setting where `" Fixed Effect"` is added after the fixed effect. Turn this off for all tables by running:
  - `RegressionTables.default_print_fe_suffix(x::AbstractRenderType) = false`
- `print_control_indicator` is a new setting where a line is added if any coefficients are omitted. Turn this off for all tables by running:
  - `RegressionTables.default_print_control_indicator(x::AbstractRenderType) = false`

### Changes to Labeling

Labels for most display elements around the table are no longer handled by the `labels` dictionary but by functions. The goal is to allow a "set and forget" mentality, where changing the label once permanently changes it for all tables. For example, instead of:
```julia
labels=Dict(
  "__LABEL_ESTIMATOR__" => "Estimator",
  "__LABEL_FE_YES__" => "Yes",
  "__LABEL_FE_NO__" => "",
  "__LABEL_ESTIMATOR_OLS" => "OLS",
  "__LABEL_ESTIMATOR_IV" => "IV",
  "__LABEL_ESTIMATOR_NL" => "NL"
)
```
Run
```julia
RegressionTables.label(render::AbstractRenderType, ::Type{RegressionType}) = "Estimator"
RegressionTables.fe_value(render::AbstractRenderType, v) = v ? "Yes" : ""
RegressionTables.label_ols(render::AbstractRenderType) = "OLS"
RegressionTables.label_iv(render::AbstractRenderType) = "IV"
RegressionTables.label_distribution(render::AbstractRenderType, d::Probit) = "Probit"# non-linear values now
# display distribution instead of "NL"
```
See the documentation for more examples. For regression statistics, it is possible to pass a pair (e.g., `[Nobs => "Obs.", R2 => "R Squared"]`) to relabel those.

Labels for coefficient names are the same, but interaction and categorical terms might see some differences. Now, each part of an interaction or categorical term can be labeled independently (so `labels=Dict("coef1" => "Coef 1", "coef2" => "Coef 2")` would relabel `coef1 & coef2` to `Coef 1 & Coef 2`). This might cause changes to tables if the labels dictionary contains an interaction label but not both pieces independently, the display would depend on which order the dictionary is applied (so `labels=Dict("coef1" => "Coef 1", "coef1 & coef2" => "Coef 1 & Coef 2")` might turn the interaction into either `Coef 1 & Coef 2` or `Coef 1 & coef2`).

### `custom_statistics` replaced by `extralines`

The `custom_statistics` argument took a `NamedTuple` with vectors, this is now simplified in the `extralines` argument to a `Vector`, where the first argument is what is displayed in the left most column. `extralines` now accepts a `Pair` of `val => cols` (e.g., `0.153 => 2:3`), where the second value creates a multicolumn display. See the examples in the documentation under "Extralines".

For statistics that can use the values in the regression model (e.g., the mean of Y), it is possible to create those under an `AbstractRegressionStatistic`. See the documentation for an example.

### `print_result` and `out_buffer` arguments are gone

`print_result` is no longer necessary since an object is returned by the `regtable` function (which is editable) and displays well in notebooks like Pluto or Jupyter. Similarly for `out_buffer`, use `tab=regtable(...); print(io, tab)`.

### Other Deprecation Warnings that should not change results

- `renderSettings` is deprecated, use `render` and `file`
- `regressors` is deprecated, use `keep` `drop` and `order`
