# Regression Statistics

## Full Regression Statistics

```@docs
RegressionTables.AbstractRegressionStatistic
```

### Defined Types

```@autodocs
Modules = [RegressionTables]
Filter = t -> typeof(t) === DataType && t <: RegressionTables.AbstractRegressionStatistic && t != RegressionTables.AbstractRegressionStatistic
```

## Below or Under Statistic

```@docs
RegressionTables.AbstractUnderStatistic
```

```@autodocs
Modules = [RegressionTables]
Filter = t -> typeof(t) === DataType && t <: RegressionTables.AbstractUnderStatistic && t != RegressionTables.AbstractUnderStatistic
```

## Other Statistics

```@docs
RegressionTables.CoefValue
RegressionTables.RegressionType
RegressionTables.HasControls
RegressionTables.RegressionNumbers
RegressionTables.FixedEffectValue
RegressionTables.RandomEffectValue
RegressionTables.ClusterValue
```