
# Customization of Defaults

```@index
Pages=["customization.md"]
```

## Principles

Within most publications, the tables look similar. This package tries to provide easy access to almost any setting so you can "set and forget" while producing tables that you need. For example, suppose you are using Latex and want to use the `tabular*` environment instead of the default `tabular`. Thanks to the Julia type system, this is possible, simply run
```julia
RegressionTables.tablestart(::RegressionTables.AbstractLatex, align) = "\\begin{tabular*}{\\linewidth}{$(align[1])@{\\extracolsep{\\fill}}$(align[2:end])}"
RegressionTables.tableend(::RegressionTables.AbstractLatex) = "\\end{tabular*}"
```
These two lines change all [`AbstractLatex`](@ref) tables.

The Julia type system also allows customization for more individualized tables. For example, you might include some descriptive tables in a paper, but it might make sense to use different rounding for descriptive data (such as making sure floats that are stored as integers are displayed as integers or rounding for large numbers). This needs to happen without changing the rounding in most tables. To do so, you can create a new type and set the display option for that type:
```julia
struct LatexDescriptiveTable <: RegressionTables.AbstractLatex end
function Base.repr(::LatexDescriptiveTable, x::Float64; args...)
    if isinteger(x)
        format(Int(x); commas=true)
    else
        precision = x > 1000 ? 1 : 3
        format(x; commas=true, precision)
    end
end
```

Now, when creating a descriptive table (see [`RegressionTable`](@ref) for an example), pass `render=LatexDescriptiveTable()` to use your formatting function.

The rest of this page goes through the defaults, showing what they are and what you might change each to.

## Rounding Digits

```@docs
RegressionTables.default_digits
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
RegressionTables.default_render
RegressionTables.default_file
RegressionTables.default_print_fe_suffix
RegressionTables.default_print_control_indicator
RegressionTables.default_standardize_coef
RegressionTables.default_print_estimator
RegressionTables.default_regression_statistics
RegressionTables.default_print_randomeffects
RegressionTables.default_print_clusters
RegressionTables.default_use_relabeled_values
```

## Other Defaults

While the user can adjust almost any part of this package (see [How Types are Displayed](@ref)), here are the remaining major defaults that are settable.

```@docs
RegressionTables.default_breaks
RegressionTables.default_symbol
RegressionTables.interaction_combine
RegressionTables.categorical_equal
RegressionTables.random_effect_separator
RegressionTables.estim_decorator
RegressionTables.below_decoration
RegressionTables.number_regressions_decoration
RegressionTables.fe_suffix
RegressionTables.wrapper
RegressionTables.fe_value
RegressionTables.cluster_suffix
```

## Labels

Labels are customizable by running the function that defines them. This makes it possible to change the labels once and then not worry about them on subsequent tables. To change a label, run:
```julia
RegressionTables.label(render::AbstractRenderType, ::Type{Nobs}) = "Obs."
```
Labels use the Julia type system, so it is possible to create different labels depending on the table type. This is done by default for cases such as [`Nobs`](@ref) and [`R2`](@ref), where the defaults for Latex and HTML are different. In such cases, it is necessary to set the label for all types that are used:
```julia
RegressionTables.label(render::AbstractLatex, ::Type{Nobs}) = "Obs."
RegressionTables.label(render::AbstractHtml, ::Type{Nobs}) = "Obs."
```

Some labels (notably the [`R2`](@ref) group), call another label function. For example:
```julia
label(render::AbstractRenderType, ::Type{AdjR2}) = "Adjusted " * label(render, R2)
```
Ths means that the label for [`AdjR2`](@ref) relies on the label for [`R2`](@ref). This also means that changing the label for [`R2`](@ref) will change the labels for all other `R2` types.
```@docs
RegressionTables.label
RegressionTables.label_p
RegressionTables.label_ols
RegressionTables.label_iv
RegressionTables.label_distribution
```