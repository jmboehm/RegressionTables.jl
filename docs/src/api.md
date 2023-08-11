
# API of Underlying Functions

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
```

### Latex

```@docs
RegressionTables.AbstractLatex
```

### HTML

```@docs
RegressionTables.AbstractHTML
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
```

## How Types are Displayed

This section describes how different types are displayed. Throughout this package, `T(x)` where `T` is a concrete type of [`AbstractRenderType`](@ref) is used to convert something to a string. This allows two things.
1. Since it is easy to create new `AbstractRenderType`s, it is possible to create customized displays for almost anyway situation
2. Since most things in this package are types, each can be customized

```@docs
Core.Type
```