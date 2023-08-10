
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