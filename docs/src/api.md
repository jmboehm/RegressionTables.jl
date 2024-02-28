
# API of Underlying Functions

```@contents
Pages=["api.md"]
Depth = 3
```

## DataRow

```@docs
RegressionTables.DataRow
```

## RegressionTable

```@docs
RegressionTables.RegressionTable
```

## Render Types

```@docs
RegressionTables.AbstractRenderType
```

### Ascii

```@docs
RegressionTables.AbstractAscii
RegressionTables.AsciiTable
```

### Latex

```@docs
RegressionTables.AbstractLatex
RegressionTables.LatexTable
RegressionTables.LatexTableStar
```

### HTML

```@docs
RegressionTables.AbstractHtml
RegressionTables.HtmlTable
```

## Coefficient Naming

```@docs
RegressionTables.AbstractCoefName
RegressionTables.get_coefname
```

```@autodocs
Modules = [RegressionTables]
Filter = t -> typeof(t) === DataType && t <: RegressionTables.AbstractCoefName && t != RegressionTables.AbstractCoefName
```

## Utility Functions

```@docs
RegressionTables.calc_widths
RegressionTables.update_widths!
RegressionTables.value_pos
RegressionTables.combine_other_statistics
RegressionTables.combine_statistics
RegressionTables.build_nm_list
RegressionTables.reorder_nms_list
RegressionTables.drop_names!
RegressionTables.add_blank
RegressionTables.missing_vars
RegressionTables.add_element!
RegressionTables.find_vertical_gaps
```

## How Types are Displayed

This section describes how different types are displayed. Throughout this package, `repr(T(), x)` where `T` is a concrete type of [`AbstractRenderType`](@ref) is used to convert something to a string. This allows two things.
1. Since it is easy to create new `AbstractRenderType`s, it is possible to create customized displays for almost anyway situation
2. Since most things in this package are types, each can be customized

```@docs
Base.repr
```

## New RegressionModel Types

This package is designed to be generally compatible with the [RegressionModel abstraction](https://juliastats.org/StatsBase.jl/latest/statmodels/). It has special conditions defined around four commonly used packages ([FixedEffectModels.jl](https://github.com/matthieugomez/FixedEffectModels.jl), [GLM.jl](https://github.com/JuliaStats/GLM.jl), [GLFixedEffectModels.jl](https://github.com/jmboehm/GLFixedEffectModels.jl) and [MixedModels.jl](https://github.com/JuliaStats/MixedModels.jl)). It is possible to add new models to this list, either by creating an extension for this package or by creating the necessary items in an independent package.

For any new `RegressionModel`, there may be a need to define the following functions for the package to work correctly. Many of these will work without any issues if following the StatsModels API, and many of the others are useful for customizing how the regression result is displayed. It is also possible to redefine how [`RegressionTables.AbstractRegressionStatistic`](@ref) are displayed.

```@docs
RegressionTables._formula
RegressionTables._responsename
RegressionTables._coefnames
RegressionTables._coef
RegressionTables._stderror
RegressionTables._dof_residual
RegressionTables._pvalue
RegressionTables.other_stats
RegressionTables.default_regression_statistics(::RegressionModel)
RegressionTables.can_standardize
RegressionTables.standardize_coef_values
RegressionTables.RegressionType
```