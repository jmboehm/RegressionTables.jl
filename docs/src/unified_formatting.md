# Unified Statistic Formatting

```@contents
Pages=["unified_formatting.md"]
```

This page documents the unified approach to formatting statistics in regression tables. The `statisticformat` argument provides a flexible way to control how both below statistics (standard errors, t-stats, confidence intervals) and regression statistics (R², N, etc.) are displayed.

## Setup


```@meta
DocTestSetup = quote # hide
    using RegressionTables, DataFrames, RDatasets, FixedEffectModels, GLM;
    df = dataset("datasets", "iris");
    df[!,:isSmall] = df[!,:SepalWidth] .< 2.9;
    rr1 = reg(df, @formula(SepalLength ~ SepalWidth));
    rr2 = reg(df, @formula(SepalLength ~ SepalWidth + PetalLength + fe(Species)));
    rr3 = reg(df, @formula(SepalLength ~ SepalWidth + PetalLength * PetalWidth + fe(Species) + fe(isSmall)));
    rr4 = reg(df, @formula(SepalWidth ~ SepalLength + PetalLength + PetalWidth + fe(Species)));
end # hide
```
```julia
using RegressionTables, DataFrames, RDatasets, FixedEffectModels, GLM;
df = dataset("datasets", "iris");
df[!,:isSmall] = df[!,:SepalWidth] .< 2.9;
rr1 = reg(df, @formula(SepalLength ~ SepalWidth));
rr2 = reg(df, @formula(SepalLength ~ SepalWidth + PetalLength + fe(Species)));
rr3 = reg(df, @formula(SepalLength ~ SepalWidth + PetalLength * PetalWidth + fe(Species) + fe(isSmall)));
rr4 = reg(df, @formula(SepalWidth ~ SepalLength + PetalLength + PetalWidth + fe(Species)));
```

## Basic Usage

### Using `digits_stats`

The simplest way to control precision for all statistics is with `digits_stats`:

```jldoctest
regtable(rr1, rr2; digits_stats=4)

# output

 
-------------------------------------------
                            SepalLength
                        -------------------
                             (1)        (2)
-------------------------------------------
(Intercept)             6.526***
                        (0.4789)
SepalWidth                -0.223   0.432***
                        (0.1551)   (0.0814)
PetalLength                        0.776***
                                   (0.0642)
-------------------------------------------
Species Fixed Effects                   Yes
-------------------------------------------
N                            150        150
R2                        0.0138     0.8633
Within-R2                            0.6415
-------------------------------------------
```

### Using `statisticformat` with a String

Apply a printf-style format string to all statistics:

```jldoctest
regtable(rr1, rr2; statisticformat="%0.2f")

# output

 
-------------------------------------------
                            SepalLength
                        -------------------
                             (1)        (2)
-------------------------------------------
(Intercept)             6.526***
                          (0.48)
SepalWidth                -0.223   0.432***
                          (0.16)     (0.08)
PetalLength                        0.776***
                                     (0.06)
-------------------------------------------
Species Fixed Effects                   Yes
-------------------------------------------
N                            150        150
R2                          0.01       0.86
Within-R2                              0.64
-------------------------------------------
```


## Dictionary-Based Formatting

The most powerful approach is using a `Dict` to specify different formats for different statistic types.

### Format by Statistic Type

Use statistic types (`StdError`, `TStat`, `R2`, etc.) as keys:

```jldoctest
regtable(rr1, rr2;
    below_statistic = [StdError, TStat],
    statisticformat = Dict(
        StdError => 4,        # 4 decimal places
        TStat => "%0.2f",     # 2 decimal places via format string
        R2 => 5               # 5 decimal places for R²
    )
)

# output

 
-------------------------------------------
                            SepalLength
                        -------------------
                             (1)        (2)
-------------------------------------------
(Intercept)             6.526***
                        (0.4789)
                         (13.63)
SepalWidth                -0.223   0.432***
                        (0.1551)   (0.0814)
                         (-1.44)     (5.31)
PetalLength                        0.776***
                                   (0.0642)
                                    (12.07)
-------------------------------------------
Species Fixed Effects                   Yes
-------------------------------------------
N                            150        150
R2                       0.01382    0.86331
Within-R2                             0.642
-------------------------------------------
```


### Using Symbol Keys

For convenience, you can use symbols instead of types:

```jldoctest
regtable(rr1, rr2;
    below_statistic = [StdError, TStat],
    statisticformat = Dict(
        :se => 4,
        :tstat => 2,
        :r2 => 5
    )
)

# output

 
-------------------------------------------
                            SepalLength
                        -------------------
                             (1)        (2)
-------------------------------------------
(Intercept)             6.526***
                        (0.4789)
                         (13.63)
SepalWidth                -0.223   0.432***
                        (0.1551)   (0.0814)
                         (-1.44)     (5.31)
PetalLength                        0.776***
                                   (0.0642)
                                    (12.07)
-------------------------------------------
Species Fixed Effects                   Yes
-------------------------------------------
N                            150        150
R2                       0.01382    0.86331
Within-R2                             0.642
-------------------------------------------
```

Available symbol mappings:
- `:se` → `StdError`
- `:tstat` → `TStat`
- `:confint` → `ConfInt`
- `:pvalue` → `PValue`
- `:nobs` → `Nobs`
- `:r2` → `R2`
- `:adjr2` → `AdjR2`
- `:r2_within` → `R2Within`
- `:f` → `FStat`
- `:p` → `FStatPValue`
- `:f_kp` → `FStatIV`
- `:p_kp` → `FStatIVPValue`
- `:dof` → `DOF`

### Using Functions for Custom Formatting

Pass a function to transform the raw numeric value:

```jldoctest
regtable(rr1, rr2;
    statisticformat = Dict(
        StdError => x -> round(x, digits=2),
        R2 => x -> string(round(x * 100, digits=1)) * "%"
    )
)

# output

 
-------------------------------------------
                            SepalLength
                        -------------------
                             (1)        (2)
-------------------------------------------
(Intercept)             6.526***
                           0.480
SepalWidth                -0.223   0.432***
                           0.160      0.080
PetalLength                        0.776***
                                      0.060
-------------------------------------------
Species Fixed Effects                   Yes
-------------------------------------------
N                            150        150
R2                          1.4%      86.3%
Within-R2                             0.642
-------------------------------------------
```

## Setting Global Defaults

For consistent formatting across many tables, you can override the default functions rather than specifying `statisticformat` on each call. This is particularly useful in publications where all tables should have the same appearance.

### Default Digits

Override `default_digits` to change the default precision for all statistics:

```julia
# Change default digits for all statistics to 4
RegressionTables.default_digits(render::AbstractRenderType, x) = 4

# Change default digits only for regression statistics (R², AIC, etc.)
RegressionTables.default_digits(render::AbstractRenderType, x::RegressionTables.AbstractRegressionStatistic) = 4

# Change default digits only for below statistics (StdError, TStat, etc.)
RegressionTables.default_digits(render::AbstractRenderType, x::RegressionTables.AbstractUnderStatistic) = 4

# Change default digits for a specific render type (e.g., only Latex)
RegressionTables.default_digits(render::RegressionTables.AbstractLatex, x) = 4
```

### Default Decorations

Override `below_decoration` to change how statistics are wrapped:

```julia
# Change default decoration for all below statistics
RegressionTables.below_decoration(render::AbstractRenderType, s) = "[$s]"

# Change decoration for specific statistic types
RegressionTables.below_decoration(render::AbstractRenderType, ::Type{StdError}, s) = "($s)"
RegressionTables.below_decoration(render::AbstractRenderType, ::Type{TStat}, s) = "{$s}"
RegressionTables.below_decoration(render::AbstractRenderType, ::Type{ConfInt}, s) = "[$s]"
```

### Default Below Statistic

Override `default_below_statistic` to change what appears below coefficients by default:

```julia
# Show t-statistics instead of standard errors by default
RegressionTables.default_below_statistic(render::AbstractRenderType) = TStat

# Show multiple statistics by default
RegressionTables.default_below_statistic(render::AbstractRenderType) = [StdError, ConfInt]

# Show nothing by default
RegressionTables.default_below_statistic(render::AbstractRenderType) = nothing
```

### Default Regression Statistics

Override `default_regression_statistics` to change which statistics appear at the bottom of tables:

```julia
# Always show N, R², and Adjusted R²
RegressionTables.default_regression_statistics(render::AbstractRenderType, rr) = [Nobs, R2, AdjR2]
```

### Combining Defaults with Per-Table Overrides

Global defaults work together with per-table arguments. The per-table `statisticformat` argument takes priority over global defaults:

```julia
# Set global default to 4 digits
RegressionTables.default_digits(render::AbstractRenderType, x) = 4

# This table uses 4 digits for everything except R², which uses 2
regtable(rr1, rr2;
    statisticformat = Dict(R2 => 2)
)
```

For more details on customizing defaults, see the [Customization of Defaults](@ref) page.


## Unified Format and Decoration

The `statisticformat` dictionary can include both formatting and decoration in a single tuple. This is especially useful when you want to customize how a statistic looks without using the separate `below_decoration` argument.

### Tuple Syntax: `(format, decoration_function)`

```jldoctest
regtable(rr1, rr2;
    below_statistic = [StdError, ConfInt],
    statisticformat = Dict(
        StdError => (4, s -> "($s)"),           # 4 digits, parentheses
        ConfInt => (3, s -> "[$s]"),            # 3 digits, brackets
        R2 => 4                                  # Just format, no decoration needed
    )
)

# output

 
--------------------------------------------------------
                                   SepalLength
                        --------------------------------
                                    (1)              (2)
--------------------------------------------------------
(Intercept)                    6.526***
                               (0.4789)
                         [5.580, 7.473]
SepalWidth                       -0.223         0.432***
                               (0.1551)         (0.0814)
                        [-0.530, 0.083]   [0.271, 0.593]
PetalLength                                     0.776***
                                                (0.0642)
                                          [0.649, 0.903]
--------------------------------------------------------
Species Fixed Effects                                Yes
--------------------------------------------------------
N                                   150              150
R2                               0.0138           0.8633
Within-R2                                          0.642
--------------------------------------------------------
```


### Mixing Formats in One Dictionary

You can mix integers, strings, functions, and tuples:

```jldoctest
regtable(rr1, rr2, rr3;
    below_statistic = [StdError, TStat],
    statisticformat = Dict(
        StdError => (4, s -> "{$s}"),           # Tuple: format + decoration
        TStat => "%0.2f",                        # String format
        R2 => x -> round(x, digits=4),          # Function
        Nobs => 0                                # Integer (0 decimal places)
    )
)

# output

 
---------------------------------------------------------
                                     SepalLength
                           ------------------------------
                                (1)        (2)        (3)
---------------------------------------------------------
(Intercept)                6.526***
                           {0.4789}
                            (13.63)
SepalWidth                   -0.223   0.432***   0.516***
                           {0.1551}   {0.0814}   {0.1036}
                            (-1.44)     (5.31)     (4.98)
PetalLength                           0.776***   0.723***
                                      {0.0642}   {0.1288}
                                       (12.07)     (5.61)
PetalWidth                                         -0.625
                                                 {0.3544}
                                                  (-1.76)
PetalLength & PetalWidth                            0.066
                                                 {0.0673}
                                                   (0.98)
---------------------------------------------------------
Species Fixed Effects                      Yes        Yes
isSmall Fixed Effects                                 Yes
---------------------------------------------------------
N                               150        150        150
R2                            0.014      0.863      0.868
Within-R2                                0.642      0.598
---------------------------------------------------------
```


## Interaction with Other Arguments

### Priority with `below_decoration`

When both `statisticformat` tuples and `below_decoration` specify decorations, `below_decoration` takes priority:

```jldoctest
regtable(rr1, rr2;
    statisticformat = Dict(
        StdError => (4, s -> "[$s]")            # Would use brackets
    ),
    below_decoration = s -> "($s)"              # But this wins, uses parentheses
)

# output

 
-------------------------------------------
                            SepalLength
                        -------------------
                             (1)        (2)
-------------------------------------------
(Intercept)             6.526***
                        (0.4789)
SepalWidth                -0.223   0.432***
                        (0.1551)   (0.0814)
PetalLength                        0.776***
                                   (0.0642)
-------------------------------------------
Species Fixed Effects                   Yes
-------------------------------------------
N                            150        150
R2                         0.014      0.863
Within-R2                             0.642
-------------------------------------------
```


### Priority with `digits_stats`

Explicit entries in `statisticformat` take priority over `digits_stats`:

```jldoctest
regtable(rr1, rr2;
    digits_stats = 4,                           # Default: 4 decimal places
    statisticformat = Dict(
        R2 => 2                                  # Override: R² uses 2 decimal places
    )
)

# output

 
-------------------------------------------
                            SepalLength
                        -------------------
                             (1)        (2)
-------------------------------------------
(Intercept)             6.526***
                        (0.4789)
SepalWidth                -0.223   0.432***
                        (0.1551)   (0.0814)
PetalLength                        0.776***
                                   (0.0642)
-------------------------------------------
Species Fixed Effects                   Yes
-------------------------------------------
N                            150        150
R2                          0.01       0.86
Within-R2                            0.6415
-------------------------------------------
```

## Confidence Intervals

### Basic ConfInt Formatting

```jldoctest
regtable(rr1, rr2;
    below_statistic = ConfInt,
    statisticformat = Dict(ConfInt => 2)
)

# output

 
----------------------------------------------------
                                 SepalLength
                        ----------------------------
                                  (1)            (2)
----------------------------------------------------
(Intercept)                  6.526***
                         (5.58, 7.47)
SepalWidth                     -0.223       0.432***
                        (-0.53, 0.08)   (0.27, 0.59)
PetalLength                                 0.776***
                                        (0.65, 0.90)
----------------------------------------------------
Species Fixed Effects                            Yes
----------------------------------------------------
N                                 150            150
R2                              0.014          0.863
Within-R2                                      0.642
----------------------------------------------------
```

### ConfInt with Custom Decoration

```jldoctest
regtable(rr1, rr2;
    below_statistic = ConfInt,
    statisticformat = Dict(
        ConfInt => (3, s -> "[$s]")
    )
)

# output

 
--------------------------------------------------------
                                   SepalLength
                        --------------------------------
                                    (1)              (2)
--------------------------------------------------------
(Intercept)                    6.526***
                         [5.580, 7.473]
SepalWidth                       -0.223         0.432***
                        [-0.530, 0.083]   [0.271, 0.593]
PetalLength                                     0.776***
                                          [0.649, 0.903]
--------------------------------------------------------
Species Fixed Effects                                Yes
--------------------------------------------------------
N                                   150              150
R2                                0.014            0.863
Within-R2                                          0.642
--------------------------------------------------------
```


### ConfInt with Two-Argument Function

For confidence intervals, you can provide a function that receives both bounds:

```jldoctest
regtable(rr1, rr2;
    below_statistic = ConfInt,
    statisticformat = Dict(
        ConfInt => (lo, hi) -> "[$(round(lo, digits=2)), $(round(hi, digits=3))]"
    )
)

# output

 
------------------------------------------------------
                                  SepalLength
                        ------------------------------
                                   (1)             (2)
------------------------------------------------------
(Intercept)                   6.526***
                         [5.58, 7.473]
SepalWidth                      -0.223        0.432***
                        [-0.53, 0.083]   [0.27, 0.593]
PetalLength                                   0.776***
                                         [0.65, 0.903]
------------------------------------------------------
Species Fixed Effects                              Yes
------------------------------------------------------
N                                  150             150
R2                               0.014           0.863
Within-R2                                        0.642
------------------------------------------------------
```


## Complete Example

Putting it all together with multiple statistics and custom formatting:

```jldoctest
regtable(rr1, rr2, rr3, rr4;
    below_statistic = [StdError, ConfInt],
    statisticformat = Dict(
        # Below statistics with format + decoration
        StdError => (3, s -> "($s)"),
        ConfInt => (2, s -> "[$s]"),
        # Regression statistics with custom formats
        R2 => x -> string(round(x * 100, digits=1)) * "%",
        Nobs => 0
    ),
    confint_level = 0.9
)

# output

 
-----------------------------------------------------------------------------------------
                                            SepalLength                      SepalWidth
                           ---------------------------------------------   --------------
                                     (1)            (2)              (3)              (4)
-----------------------------------------------------------------------------------------
(Intercept)                     6.526***
                                 (0.479)
                            [5.73, 7.32]
SepalWidth                        -0.223       0.432***         0.516***
                                 (0.155)        (0.081)          (0.104)
                           [-0.48, 0.03]   [0.30, 0.57]     [0.34, 0.69]
PetalLength                                    0.776***         0.723***          -0.188*
                                                (0.064)          (0.129)          (0.083)
                                           [0.67, 0.88]     [0.51, 0.94]   [-0.33, -0.05]
PetalWidth                                                        -0.625         0.626***
                                                                 (0.354)          (0.123)
                                                          [-1.21, -0.04]     [0.42, 0.83]
PetalLength & PetalWidth                                           0.066
                                                                 (0.067)
                                                           [-0.05, 0.18]
SepalLength                                                                      0.378***
                                                                                  (0.066)
                                                                             [0.27, 0.49]
-----------------------------------------------------------------------------------------
Species Fixed Effects                               Yes              Yes              Yes
isSmall Fixed Effects                                                Yes
-----------------------------------------------------------------------------------------
N                                    150            150              150              150
R2                                  1.4%          86.3%            86.8%            63.5%
Within-R2                                         0.642            0.598            0.391
-----------------------------------------------------------------------------------------
```


## Extending with Multiple Dispatch

The formatting system uses multiple dispatch, allowing you to add custom format types. Define a new method for `custom_stat_format`:

```jldoctest
# Example: Add support for a custom formatter type
struct PercentFormat
    digits::Int
end

function RegressionTables.custom_stat_format(render, stat, fmt::PercentFormat)
    v = RegressionTables.value(stat)
    if v === nothing || ismissing(v)
        repr(render, v)
    else
        string(round(v * 100, digits=fmt.digits)) * "%"
    end
end

# Usage:
regtable(rr1, rr2;
    statisticformat = Dict(R2 => PercentFormat(1))
)

# output

 
-------------------------------------------
                            SepalLength
                        -------------------
                             (1)        (2)
-------------------------------------------
(Intercept)             6.526***
                         (0.479)
SepalWidth                -0.223   0.432***
                         (0.155)    (0.081)
PetalLength                        0.776***
                                    (0.064)
-------------------------------------------
Species Fixed Effects                   Yes
-------------------------------------------
N                            150        150
R2                          1.4%      86.3%
Within-R2                             0.642
-------------------------------------------
```
