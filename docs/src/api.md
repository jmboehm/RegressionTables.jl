
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
RegressionTables.combine_fe
RegressionTables.combine_statistics
RegressionTables.build_nm_list
RegressionTables.reorder_nms_list
RegressionTables.drop_names!
RegressionTables.add_blank
RegressionTables.missing_vars
RegressionTables.fe_terms
RegressionTables.add_element!
```

## How Types are Displayed

This section describes how different types are displayed. Throughout this package, `render(T(), x)` where `T` is a concrete type of [`AbstractRenderType`](@ref) is used to convert something to a string. This allows two things.
1. Since it is easy to create new `AbstractRenderType`s, it is possible to create customized displays for almost anyway situation
2. Since most things in this package are types, each can be customized

```@docs
RegressionTables.render
```

## Simple Regression Result

```@docs
RegressionTables.SimpleRegressionResult
```