
# Customization of Defaults

```@index
Pages=["customization.md"]
```

Within most publications, the tables look similar. This package tries to provide easy access to almost any setting so you can "set and forget" while producing tables that you need. For example, suppose you are using Latex and want to use the `tabular*` environment instead of the default `tabular`. Thanks to the Julia type system, this is possible, simply run
```julia
RegressionTables.tablestart(::RegressionTables.AbstractLatex, align) = "\\begin{tabular*}{\\linewidth}{$(align[1])@{\\extracolsep{\\fill}}$(align[2:end])}"
RegressionTables.tableend(::RegressionTables.AbstractLatex) = "\\end{tabular*}"
```
These two lines change all [`AbstractLatex`](@ref) tables.

The Julia type system also allows customization for more individualized tables. For example, you might include some descriptive tables in a paper, but it might make sense to use different rounding for descriptive data (such as making sure floats that are stored as integers are displayed as integers or rounding for large numbers). This needs to happen without changing the rounding in most tables. To do so, you can create a new type and set the display option for that type:
```julia
struct LatexDescriptiveTable <: RegressionTables.AbstractLatex end
function LatexDescriptiveTable(x::Float64; args...)
    if isinteger(x)
        format(Int(x); commas=true)
    else
        precision = x > 1000 ? 1 : 3
        format(x; commas=true, precision)
    end
end
```

Now, when creating a descriptive table (see [`RegressionTable`](@ref) for an example), pass `rndr=LatexDescriptiveTable()` to use your formatting function.

The rest of this page goes through the defaults, showing what they are and what you might change each to.

```@contents
Pages = ["customization.md"]
```

## Rounding Digits

```@docs
RegressionTables.default_round_digits
```

## Default Keyword Arguments

```@docs
RegressionTables.default_section_order
RegressionTables.default_align
RegressionTables.default_header_align
RegressionTables.default_depvar
RegressionTables.default_number_regressions
RegressionTables.default_print_fe
RegressionTables.default_groups
RegressionTables.default_extralines
RegressionTables.default_keep
RegressionTables.default_drop
RegressionTables.default_order
RegressionTables.default_fixedeffects
RegressionTables.default_labels
RegressionTables.default_transform_labels
RegressionTables.default_below_statistic
RegressionTables.default_stat_below
RegressionTables.default_rndr
RegressionTables.default_file
RegressionTables.default_print_fe_suffix
RegressionTables.default_print_control_indicator
RegressionTables.default_standardize_coef
RegressionTables.default_print_estimator
RegressionTables.default_regression_statistics
```

## Other Defaults

Other display functions are settable (see [How Types are Displayed](@ref)), here are the remaining major defaults that are settable.

```@docs
RegressionTables.default_breaks
RegressionTables.default_symbol
RegressionTables.interaction_combine
RegressionTables.categorical_equal
RegressionTables.default_ols_label
RegressionTables.default_iv_label
```