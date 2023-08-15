
"""
    default_round_digits(rndr::AbstractRenderType, x::AbstractRegressionStatistic)

Default for regression statistics ([`R2`](@ref), [`AIC`](@ref)), defaults to the general setting of 3 digits

## Examples

```jldoctest; setup = :(using RegressionTables)
julia> x = R2(1.234567);

julia> RegressionTables.default_round_digits(::AbstractRenderType, x::RegressionTables.AbstractRegressionStatistic) = 4;

julia> AsciiTable(x)
"1.2346"

julia> LatexTable(x)
"1.2346"

julia> RegressionTables.default_round_digits(::AbstractRenderType, x::RegressionTables.AbstractRegressionStatistic) = 3; # reset to default
```
"""
default_round_digits(rndr::AbstractRenderType, x::AbstractRegressionStatistic) = default_round_digits(rndr, value(x))
"""
    default_round_digits(rndr::AbstractRenderType, x::AbstractUnderStatistic)

Default for under statistics ([`TStat`](@ref), [`StdError`](@ref)), defaults to the general setting of 3 digits

## Examples

```jldoctest; setup = :(using RegressionTables)
julia> x = StdError(1.234567);

julia> RegressionTables.default_round_digits(::RegressionTables.AbstractAscii, x::RegressionTables.AbstractUnderStatistic) = 4;

julia> AsciiTable(x)
"(1.2346)"

julia> LatexTable(x) # unchanged since the round_digits was only changed for Ascii
"(1.235)"

julia> RegressionTables.default_round_digits(::RegressionTables.AbstractAscii, x::RegressionTables.AbstractUnderStatistic) = 3; # reset to default
```
"""
default_round_digits(rndr::AbstractRenderType, x::AbstractUnderStatistic) = default_round_digits(rndr, value(x))
"""
    default_round_digits(rndr::AbstractRenderType, x::.CoefValue)

Default for [`CoefValue`](@ref), defaults to the general setting of 3 digits

## Examples

```jldoctest; setup = :(using RegressionTables)
julia> x = RegressionTables.CoefValue(1.234567, 1); # 1 is for the p value

julia> RegressionTables.default_round_digits(::AbstractRenderType, x::RegressionTables.CoefValue) = 2;

julia> HtmlTable(x)
"1.23"

julia> RegressionTables.default_round_digits(::AbstractRenderType, x::RegressionTables.CoefValue) = 3; # reset to default
```
"""
default_round_digits(rndr::AbstractRenderType, x::CoefValue) = default_round_digits(rndr, value(x))
"""
    default_round_digits(rndr::AbstractRenderType, x)

The default for for all other values not otherwise specified, defaults to 3 digits

## Examples
    
```jldoctest; setup = :(using RegressionTables)
julia> x = 1.234567;

julia> y = TStat(1.234567);

julia> RegressionTables.default_round_digits(::AbstractRenderType, x) = 4;

julia> LatexTable(x)
"1.2346"

julia> LatexTable(y) # Also changes since the default_round_digits for other types default to this value
"(1.2346)"

julia> RegressionTables.default_round_digits(t::AbstractRenderType, x) = 3; # reset to default
```
"""
default_round_digits(rndr::AbstractRenderType, x) = 3

"""
    default_section_order(rndr::AbstractRenderType)

Default section order for the table, defaults to
`[:groups, :depvar, :number_regressions, :break, :coef, :break, :fe, :break, :regtype, :break, :controls, :break, :stats, :extralines]`

`:break` is a special keyword that adds a line break between sections (e.g. between `\\midrule` in Latex)
"""
default_section_order(rndr::AbstractRenderType) = [:groups, :depvar, :number_regressions, :break, :coef, :break, :fe, :break, :regtype, :break, :controls, :break, :stats, :extralines]

"""
    default_align(rndr::AbstractRenderType)

Defaults to `:r` for all render types, possible options are :r, :l, :c
This affects each part of the table after the header and the leftmost column
always has the `:l` alignment
"""
default_align(rndr::AbstractRenderType) = :r

"""
    default_header_align(rndr::AbstractRenderType)

Defaults to `:c` for all render types, possible options are :r, :l, :c
This affects the header (all sections up before :coef, see [`default_section_order`](@ref))
of each part of the table
"""
default_header_align(rndr::AbstractRenderType) = :c

"""
    default_depvar(rndr::AbstractRenderType)

Defaults to `true` for all render types, if `false` the dependent variable ("Y") is not printed
"""
default_depvar(rndr::AbstractRenderType) = true

"""
    default_number_regressions(rndr::AbstractRenderType, rrs)

Defaults to `true` if there is more than one regression, if `false` the regression number is not printed
"""
default_number_regressions(rndr::AbstractRenderType, rrs) = length(rrs) > 1

"""
    default_print_fe(rndr::AbstractRenderType, rrs)

Defaults to `true`, but the section will not be printed if there are not fixed effects.
If `false` the fixed effects are not printed
"""
default_print_fe(rndr::AbstractRenderType, rrs) = true

"""
    default_groups(rndr::AbstractRenderType, rrs)

Defaults to `nothing`, groups are printed above the dependent variable
Setting a default should also use `rrs` (the regression results) since
that determines the number of columns in the table.
"""
default_groups(rndr::AbstractRenderType, rrs) = nothing

"""
    default_extralines(rndr::AbstractRenderType, rrs)

Defaults to `nothing`, extra lines are printed at the end of the table.
Setting a default should also use `rrs` (the regression results) since
that determines the number of columns in the table.
"""
default_extralines(rndr::AbstractRenderType, rrs) = nothing

"""
    default_keep(rndr::AbstractRenderType, rrs)

Defaults to `Vector{String}()`, which means all variables are printed.
Also see [Keep Drop and Order Arguments](@ref) for more information.
"""
default_keep(rndr::AbstractRenderType, rrs) = Vector{String}()

"""
    default_drop(rndr::AbstractRenderType, rrs)

Defaults to `Vector{String}()`, which means no variables are dropped.
Also see [Keep Drop and Order Arguments](@ref) for more information.
"""
default_drop(rndr::AbstractRenderType, rrs) = Vector{String}()

"""
    default_order(rndr::AbstractRenderType, rrs)

Defaults to `Vector{String}()`, which means the order is not changed.
Also see [Keep Drop and Order Arguments](@ref) for more information.

In settings where the primary variables of interest are static throughout
the tests, it can help to set `default_order` to a regex that includes
that variable. For example, if the primary variables are interactions, then
```julia
RegressionTables.default_order(::AbstractRenderType, rrs) = [r" & "]
```
will prioritize the interactions in the table.
"""
default_order(rndr::AbstractRenderType, rrs) = Vector{String}()

"""
    default_fixedeffects(rndr::AbstractRenderType, rrs)

Defaults to `Vector{String}()`, which means any fixed effects available are printed.
"""
default_fixedeffects(rndr::AbstractRenderType, rrs) = Vector{String}()

"""
    default_labels(rndr::AbstractRenderType)

Defaults to `Dict{String, String}()`, which means no coefficients are changed.
If you have a master dictionary of variables to change, it can help to set
`default_labels` to that dictionary. It is also possible to set
`default_labels` for each table type, allowing for labels to escape special characters in Latex.

## Examples

```julia
RegressionTables.default_labels(rndr::AbstractRenderType) = Dict("first" => "New First", "second" => "X > Y")
RegressionTables.default_labels(rndr::RegressionTables.AbstractLatex) = Dict("first" => "New First", "second" => "X \$>\$ Y")
```
"""
default_labels(rndr::AbstractRenderType) = Dict{String, String}()

"""
    default_below_statistic(rndr::AbstractRenderType)

Defaults to `StdError`, which means the standard error is printed below the coefficient.
See [`AbstractUnderStatistic`](@ref) for more information.
"""
default_below_statistic(rndr::AbstractRenderType) = StdError

"""
    default_stat_below(rndr::AbstractRenderType)

Defaults to `true`, which means the standard error (or t-stat) is printed below the coefficient.
If `false`, the standard error is printed to the right of the coefficient (in the same column)
"""
default_stat_below(rndr::AbstractRenderType) = true

"""
    default_rndr(rrs)

Defaults to `AsciiTable()`, any concrete [`AbstractRenderType`](@ref) is allowed
"""
default_rndr(rrs) = AsciiTable()
default_rndr(renderSettings::Nothing, rrs) = default_rndr(rrs)
default_rndr(renderSettings::AbstractRenderType, rrs) = renderSettings
default_rndr(renderSettings::Tuple{<:AbstractRenderType, String}, rrs) = renderSettings[1]

"""
    default_file(rndr::AbstractRenderType, renderSettings::Tuple{<:AbstractRenderType, String}, rrs)

Defaults to `nothing`, which means no file is saved.
"""
default_file(rndr::AbstractRenderType, rrs) = nothing
default_file(rndr::AbstractRenderType, renderSettings, rrs) = default_file(rndr, rrs)
default_file(rndr::AbstractRenderType, renderSettings::Tuple{<:AbstractRenderType, String}, rrs) = renderSettings[2]

"""
    default_print_fe_suffix(rndr::AbstractRenderType)

Whether or not a suffix will be applied to the fixed effects, defaults to `true`.
"""
default_print_fe_suffix(rndr::AbstractRenderType) = true

"""
    default_print_control_indicator(rndr::AbstractRenderType)

Defaults to `true`, which means if the regression has any variables ommitted
(due to `keep` or `drop`), then a line is placed with `Controls` and `Yes`.
"""
default_print_control_indicator(rndr::AbstractRenderType) = true

"""
    default_standardize_coef(rndr::AbstractRenderType, rrs)

Defaults to `false`. Standardizing the coefficient divides the coefficient by its standard deviation
and multiplies it by the standard deviation of the dependent variable. It is only possible
for models that store the matrix, such as those in [GLM.jl](https://github.com/JuliaStats/GLM.jl) and [MixedModels.jl](https://github.com/JuliaStats/MixedModels.jl).
If it is not possible, the coefficients will not change.
"""
default_standardize_coef(rndr::AbstractRenderType, rrs) = false

"""
    default_transform_labels(rndr::AbstractRenderType) = Dict{String, String}()
    default_transform_labels(rndr::AbstractLatex) = :latex

`transform_labels` apply a `replace` function to the coefficients, dependent variables and fixed effects.
The default for `AbstractLatex` is used to escape special characters in Latex.
"""
default_transform_labels(rndr::AbstractRenderType) = Dict{String, String}()
default_transform_labels(rndr::AbstractLatex) = :latex

"""
    default_print_estimator(rndr::AbstractRenderType, rrs)

Defaults to `true` if more than one type of estimator is used. For example,
if all regressions are "OLS", then this section will default to `false`, while
if one regression is "OLS" and another is "IV", then this section will default to `true`.
"""
default_print_estimator(rndr::AbstractRenderType, rrs) = length(unique(RegressionType.(rrs))) > 1

"""
    default_regression_statistics(rndr::AbstractRenderType, rrs)

Defaults to a union of the default_regression_statistics for each regression.
For example, an "OLS" regression (with no fixed effects) will default to including
`[Nobs, R2]`, and a Probit regression will include `[Nobs, PseudoR2]`,
so the default will be `[Nobs, R2, PseudoR2]`.
"""
default_regression_statistics(rndr::AbstractRenderType, rrs::Tuple) = unique(union(default_regression_statistics.(rndr, rrs)...))

asciiOutput(file::String) = (AsciiTable(), file)
latexOutput(file::String) = (LatexTable(), file)
htmlOutput(file::String) = (HtmlTable(), file)

#region
"""
Produces a publication-quality regression table, similar to Stata's `esttab` and R's `stargazer`.

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
* `digits` is an `Int` that describes the precision to be shown in the estimate. Defaults to `nothing`, which means the default (3) is used (default can be changed by setting `RegressionTables.default_round_digits(rndr::AbstractRenderType, x) = 3`).
* `statisticformat` is a `String` that describes the format of the number below the estimate (se/t).
* `digits_stats` is an `Int` that describes the precision to be shown in the statistics. Defaults to `nothing`, which means the default (3) is used (default can be changed by setting `RegressionTables.default_round_digits(rndr::AbstractRenderType, x) = 3`).
* `below_statistic` is a type that describes a statistic that should be shown below each point estimate. Recognized values are `nothing`, `StdError`, `TStat`, and `ConfInt`. `nothing` suppresses the line. Defaults to `StdError`.
* `regression_statistics` is a `Vector` of types that describe statistics to be shown at the bottom of the table. Built in types are Recognized symbols are `Nobs`, `R2`, `PseudoR2`, `R2CoxSnell`, `R2Nagelkerke`, `R2Deviance`, `AdjR2`, `AdjPseudoR2`, `AdjR2Deviance`, `DOF`, `LogLikelihood`, `AIC`, `AICC`, `BIC`, `FStat`, `FStatPValue`, `FStatIV`, `FStatIVPValue`, R2Within. Defaults vary based on regression inputs (simple linear model is [Nobs, R2]).
* `extralines` is a `Vector` or a `Vector{<:AbsractVector}` that will be added to the end of the table. A single vector will be its own row, a vector of vectors will each be a row. Defaults to `nothing`.
* `number_regressions` is a `Bool` that governs whether regressions should be numbered. Defaults to `true`.
* `groups` is a `Vector`, `Vector{<:AbstractVector}` or `Matrix` of labels used to group regressions. This can be useful if results are shown for different data sets or sample restrictions.
* `print_fe_section` is a `Bool` that governs whether a section on fixed effects should be shown. Defaults to `true`.
* `print_estimator_section`  is a `Bool` that governs whether to print a section on which estimator (OLS/IV/Binomial/Poisson...) is used. Defaults to `true` if more than one value is displayed.
* `standardize_coef` is a `Bool` that governs whether the table should show standardized coefficients. Note that this only works with `TableRegressionModel`s, and that only coefficient estimates and the `below_statistic` are being standardized (i.e. the R^2 etc still pertain to the non-standardized regression).
* `rndr::AbstractRenderType` is a `AbstractRenderType` type that governs how the table should be rendered. Standard supported types are ASCII (via `AsciiTable()`) and LaTeX (via `LatexTable()`). Defaults to `AsciiTable()`.
* `file` is a `String` that governs whether the table should be saved to a file. Defaults to `nothing`.
* `transform_labels` is a `Dict` or one of the `Symbol`s `:ampersand`, `:underscore`, `:underscore2space`, `:latex`

### Details
A typical use is to pass a number of `FixedEffectModel`s to the function, along with a `RenderSettings` object.
```julia
regtable(regressionResult1, regressionResult2; renderSettings = asciiOutput())
```

Pass a string to the `file` argument to create or overwrite a file. For example, using LaTeX output,
```julia
regtable(regressionResult1, regressionResult2; rndr = LatexTable(), file="myoutfile.tex")
```
See the full argument list for details.
"""
function regtable(
    rrs::RegressionModel...;
    renderSettings = nothing,
    rndr::T = default_rndr(renderSettings, rrs),
    keep::Vector = default_keep(rndr, rrs), # allows :last and :end as symbol
    drop::Vector = default_drop(rndr, rrs), # allows :last and :end as symbol
    order::Vector = default_order(rndr, rrs), # allows :last and :end as symbol
    fixedeffects::Vector = default_fixedeffects(rndr, rrs),
    labels::Dict{String,String} = default_labels(rndr),
    align::Symbol = default_align(rndr),
    header_align::Symbol = default_header_align(rndr),
    below_statistic = default_below_statistic(rndr),# can also be nothing
    stat_below::Bool = default_stat_below(rndr),# true means StdError or TStat appears below, false means it appears to the right
    regression_statistics = default_regression_statistics(rndr, rrs), # collection of all statistics to be printed
    groups = default_groups(rndr, rrs), # displayed above the regression variables
    print_depvar::Bool = default_depvar(rndr),
    number_regressions::Bool = default_number_regressions(rndr, rrs), # decoration for the column number, does not display by default if only 1 regression
    print_estimator_section = default_print_estimator(rndr, rrs),
    print_fe_section = default_print_fe(rndr, rrs), # defaults to true but only matters if fixed effects are present
    file = default_file(rndr, renderSettings, rrs),
    transform_labels::Union{Dict,Symbol} = default_transform_labels(rndr),
    extralines = default_extralines(rndr, rrs),
    section_order = default_section_order(rndr),
    print_fe_suffix = default_print_fe_suffix(rndr),
    print_control_indicator = default_print_control_indicator(rndr),
    standardize_coef=default_standardize_coef(rndr, rrs),# can be vector with same length as rrs
    digits=nothing,
    digits_stats=nothing,
    estimformat=nothing,
    statisticformat=nothing,
    below_decoration::Union{Nothing, Function}=nothing,
    number_regressions_decoration::Union{Nothing, Function}=nothing,
    estim_decoration::Union{Nothing, Function}=nothing,
    regressors=nothing,
) where {T<:AbstractRenderType}
    @assert align ∈ (:l, :r, :c) "align must be one of :l, :r, :c"
    @assert header_align ∈ (:l, :r, :c) "header_align must be one of :l, :r, :c"
    if isa(transform_labels, Symbol)
        transform_labels = _escape(transform_labels)
    end
    if regressors !== nothing
        @warn("regressors is deprecated. Use keep instead.")
        @warn("regressors selects based on the input coefnames, while keep selects based on the labeled names, so results can be different")
        if length(keep) == 0
            keep = replace_name.(regressors, Ref(labels), Ref(transform_labels)) 
        end
    end
    if renderSettings !== nothing
        x = if file === nothing
            "renderSettings is deprecated. Specify render type with rndr=$rndr"
        else
            "renderSettings is deprecated. Specify render type with rndr=$rndr and file with file=$file"
        end
        @warn(x)
    end
    if isa(below_statistic, Symbol)
        if below_statistic == :se
            below_statistic = StdError
        elseif below_statistic == :tstat
            below_statistic = TStat
        elseif below_statistic == :none
            below_statistic = nothing
        else
            error("unrecognized below_statistic")
        end
    end
    regression_statistics = replace(
        regression_statistics,
        :nobs => Nobs,
        :r2 => R2,
        :adjr2 => AdjR2,
        :r2_within => R2Within,
        :f => FStat,
        :p => FStatPValue,
        :f_kp => FStatIV,
        :p_kp => FStatIVPValue,
        :dof => DOF,
    )
    sections = []
    for (i, s) in enumerate(section_order)
        if s == :depvar
            if print_depvar
                push!(sections, :depvar)
            end
        elseif s == :groups
            if groups !== nothing
                push!(sections, groups)
            end
        elseif s == :number_regressions
            if number_regressions
                push!(sections, :number_regressions)
            end
        elseif s == :regtype
            if print_estimator_section
                push!(sections, :regtype)
            end
        elseif s == :fe
            if print_fe_section
                push!(sections, :fe)
            end
        elseif s == :extralines 
            if extralines !== nothing
                push!(sections, extralines)
            end
        elseif s == :break
            if i == 1
                push!(sections, :break)
            elseif last(sections) != :break
                push!(sections, :break)
            end
        elseif s == :controls
            if print_control_indicator
                push!(sections, :controls)
            end
        else
            push!(sections, s)
        end
    end
    if last(sections) == :break && last(section_order) != :break
        pop!(sections)
    end

    tables = SimpleRegressionResult.(
        rrs,
        standardize_coef;
        regression_statistics,
        labels,
        fixedeffects,
        transform_labels,
    )

    out = Vector{DataRow{T}}()
    breaks = Int[]
    wdths=fill(0, length(tables)+1)

    nms = union(coefnames.(tables)...) |> unique
    if length(keep) > 0
        nms = build_nm_list(nms, keep)
    end
    if length(drop) > 0
        drop_names!(nms, drop)
    end
    if length(order) > 0
        nms = reorder_nms_list(nms, order)
    end
    coefvalues = Matrix{Any}(missing, length(nms), length(tables))
    coefbelow = Matrix{Any}(missing, length(nms), length(tables))
    for (i, table) in enumerate(tables)
        for (j, nm) in enumerate(nms)
            if nm in coefnames(table)
                k = findfirst(coefnames(table) .== nm)
                coefvalues[j, i] = CoefValue(coef(table)[k], table.coefpvalues[k])
                if below_statistic !== nothing
                    coefbelow[j, i] = below_statistic(stderror(table)[k], coef(table)[k], dof_residual(table))
                end
            end
        end
    end
    #=
    coefvalues and coefbelow need special treatment since they incorporate both the actual
    coefvalue and the pvalue, so formatting them with with digits, estimformat or
    estim_decoration is not straightforward. The following logic is implemented:
    =#
    if digits !== nothing || estimformat !== nothing || estim_decoration !== nothing
        if estim_decoration === nothing
            if digits !== nothing
                coefvalues = T.(coefvalues; digits)
            elseif estimformat !== nothing
                coefvalues = T.(coefvalues; str_format=estimformat)
            end
        else
            @warn("estim_decoration is deprecated. Set the breaks desired globally by running")
            @warn("RegressionTables.default_breaks(rndr::AbstractRenderType) = [0.001, 0.01, 0.05]")
            @warn("or set the default symbol globally by running")
            @warn("RegressionTables.default_symbol(rndr::AbstractRenderType) = '*'")
            if digits !== nothing
                temp_coef = T.(value.(coefvalues); digits)
            elseif estimformat !== nothing
                temp_coef = T.(value.(coefvalues); str_format=estimformat)
            else
                temp_coef = T.(value.(coefvalues); commas=false)
            end
            coefvalues = estim_decoration.(temp_coef, coalesce.(value_pvalue.(coefvalues), 1.0))# coalesce to 1.0 since if missing then it should be insignificant
        end
    end
    
    if digits !== nothing || statisticformat !== nothing || below_decoration !== nothing
        if below_decoration === nothing
            if digits_stats !== nothing
                coefbelow = T.(coefbelow; digits=digits_stats)
            elseif statisticformat !== nothing
                coefbelow = T.(coefbelow; str_format=statisticformat)
            end
        else
            @warn("below_decoration is deprecated. Set the below decoration globablly by running")
            @warn("(::Type{T})(x::RegressionTables.AbstractUnderStatistic; digits=RegressionTables.default_round_digits(T(), x), args...) where {T <: RegressionTables.AbstractRenderType} = \"(\" * T(RegressionTables.value(x); digits, args...) * \")\"")
            if digits_stats !== nothing
                temp_coef = T.(value.(coefbelow); digits=digits_stats)
            elseif statisticformat !== nothing
                temp_coef = T.(value.(coefbelow); str_format=statisticformat)
            else
                temp_coef = T.(value.(coefbelow); commas=false)
            end
            coefbelow = [x == "" ? x : below_decoration(x) for x in temp_coef]
        end
    end

    align='l' * join(fill(align, length(rrs)), "")
    header_align='l' * join(fill(header_align, length(rrs)), "")
    in_header = true
    for (i, s) in enumerate(sections)

        if isa(s, Pair)
            v = first(s)
            push_DataRow!(out, DataRow(vcat([last(s)], fill("", length(tables)))), align, wdths, false, rndr)
        else
            v = s
        end
        if !isa(v, Symbol)
            al = in_header ? header_align : align
            push_DataRow!(out, v, al, wdths, in_header, rndr; combine_equals=in_header)
            continue
        end
        if v == :break
            push!(breaks, length(out))
        elseif v == :depvar
            underlines = i + 1 < length(sections) && sections[i+1] != :break
            push_DataRow!(out, collect(responsename.(tables)), header_align, wdths, underlines, rndr; combine_equals=true)
        elseif v == :number_regressions
            if number_regressions_decoration !== nothing
                @warn("number_regressions_decoration is deprecated, specify decoration globally by running")
                @warn("(::Type{T})(x::RegressionTables.RegressionNumbers; args...) where {T <: AbstractRenderType} = \"(\" * T(RegressionTables.value(x); args...) * \")\"")
                push_DataRow!(out, number_regressions_decoration.(1:length(tables)), align, wdths, false, rndr; combine_equals=false)
            else
                push_DataRow!(out, RegressionNumbers.(1:length(tables)), align, wdths, false, rndr; combine_equals=false)
            end
        elseif v == :coef
            in_header = false
            if below_statistic === nothing
                temp = hcat(nms, coefvalues)
                push_DataRow!(out, temp, align, wdths, false, rndr)
            else
                if stat_below
                    temp = hcat(nms, coefvalues)
                    for i in 1:size(temp, 1)
                        push_DataRow!(out, temp[i, :], align, wdths, false, rndr)
                        push_DataRow!(out, coefbelow[i, :], align, wdths, false, rndr)
                    end
                else
                    x = [(x, y) for (x, y) in zip(coefvalues, coefbelow)]
                    temp = hcat(nms, x)
                    push_DataRow!(out, temp, align, wdths, false, rndr)
                end
            end
        elseif v == :fe
            fe = combine_fe(tables, fixedeffects; print_fe_suffix)
            if !isnothing(fe)
                push_DataRow!(out, fe, align, wdths, false, rndr)
            end
        elseif v == :regtype
            regressiontype = vcat([RegressionType], [t.regressiontype for t in tables])
            push_DataRow!(out, regressiontype, align, wdths, false, rndr)
        elseif v == :stats
            stats = combine_statistics(tables)
            if digits_stats !== nothing
                stats = T.(stats; digits=digits_stats)
            elseif statisticformat !== nothing
                stats = T.(stats; str_format=statisticformat)
            end
            push_DataRow!(out, stats, align, wdths, false, rndr)
        elseif v == :controls
            v = missing_vars.(tables, Ref(string.(nms)))
            if !any(v)
                continue
            end
            dat = vcat(
                [HasControls],
                HasControls.(v) |> collect
            )
            push_DataRow!(out, dat, align, wdths, false, rndr)
        end
    end
    if length(breaks) == 0
        breaks = [length(out)]
    end
    f = RegressionTable(
        out,
        align,
        breaks,
        #colwidths added automatically
    )
    if file !== nothing
        write(file, f)
    end
    f
end

"""
    combine_fe(tables, fixedeffects; print_fe_suffix=true)

Takes a set of [`SimpleRegressionResult`](@ref) and combines the fixed effects
into a single matrix. The first matrix column is a list of unique fixed
effects and the remaining columns are a boolean matrix indicating which
fixed effects are present in each regression.

## Arguments
- `tables` is a `Vector` of [`SimpleRegressionResult`](@ref) to combine
- `fixedeffects` is a `Vector` of fixed effects to include in the table. 
   Defaults to `Vector{String}()`, which means all fixed effects are included.
   Can also be regex, integers or ranges to select which fixed effects
- `print_fe_suffix` is a `Bool` that governs whether the fixed effects should
   be printed with a suffix. Defaults to `true`, which means the fixed effects
   will be printed as `\$X Fixed Effects`. If `false`, the fixed effects will
   just be the fixed effect (`\$X`).
"""
function combine_fe(tables, fixedeffects; print_fe_suffix=true)
    fe = []
    for table in tables
        if !isnothing(table.fixedeffects)
            fe = union(fe, table.fixedeffects)
        end
    end
    if length(fe) == 0
        return nothing
    end
    if length(fixedeffects) > 0
        fe = build_nm_list(fe, fixedeffects)
    end
    mat = zeros(Bool, length(fe), length(tables))
    for (i, table) in enumerate(tables)
        if table.fixedeffects !== nothing
            for (j, f) in enumerate(fe)
                mat[j, i] = f in table.fixedeffects
            end
        end
    end
    if !print_fe_suffix
        fe = value.(fe)
    end
    hcat(fe, mat)
end

"""
    combine_statistics(tables)

Takes a set of [`SimpleRegressionResult`](@ref) and combines the statistics
into a single matrix. The first matrix column is a list of unique statistics
(either in `String` format or the type of [`AbstractRegressionStatistic`](@ref)). The rest of the columns are the values of the statistics, or `missing` if the statistic is not present in that regression.
"""
function combine_statistics(tables)
    types_strings = []
    for t in tables
        for s in t.statistics
            if isa(s, AbstractRegressionStatistic)
                push!(types_strings, typeof(s))
            elseif isa(s, Pair)
                push!(types_strings, last(s))
            end
        end
    end
    types_strings = unique(types_strings)
    mat = Matrix{Any}(missing, length(types_strings), length(tables))
    for (i, t) in enumerate(tables)
        for (j, s) in enumerate(t.statistics)
            if isa(s, AbstractRegressionStatistic)
                mat[j, i] = s
            elseif isa(s, Pair)
                mat[j, i] = first(s)
            end
        end
    end
    hcat(types_strings, mat)
end

push_DataRow!(data::Vector{<:DataRow}, ::Nothing, args...; vargs...) = data
function push_DataRow!(data::Vector{<:DataRow}, vals::Matrix, args...; vargs...)
    for i in 1:size(vals, 1)
        push_DataRow!(data, vals[i, :], args...; vargs...)
    end
end
function push_DataRow!(data::Vector{<:DataRow}, vals::Vector{<:AbstractVector}, align, colwidths, print_underlines::Bool, rndr::AbstractRenderType; combine_equals=print_underlines)
    for v in vals
        push_DataRow!(data, v, align, colwidths, print_underlines, rndr; combine_equals)
    end
end
push_DataRow!(data::Vector{DataRow{T}}, val::DataRow, args...; vargs...) where {T<:AbstractRenderType} = push!(data, T(val))
function push_DataRow!(data::Vector{<:DataRow}, vals::Vector, align, colwidths, print_underlines::Bool, rndr::AbstractRenderType; combine_equals=print_underlines)
    if all(isa.(vals, DataRow) .|| isa.(vals, AbstractVector))
        for v in vals
            push_DataRow!(data, v, align, colwidths, print_underlines, rndr; combine_equals)
        end
        return data
    elseif any(isa.(vals, DataRow) .|| isa.(vals, AbstractVector))
        throw("Cannot combine Vector type elements with individual elements, put each row into its own Vector")
    end
    l = length(colwidths)
    if length(vals) == 0
        return data
    end
    if length(vals) < l && !any(isa.(vals, Pair))
        vals = vcat(fill("", l - length(vals)), vals)
    elseif length(vals) < l
        align2 = ""
        colwidths2 = Int[]
        j = 0
        for (i, v) in enumerate(vals)
            j = isa(v, Pair) ? first(last(v)) : j + 1
            push!(colwidths2, colwidths[j])
            align2 *= align[j]
        end
        align = align2
        colwidths = colwidths2
    end
    push!(
        data,
        DataRow(
            vals,
            align,
            colwidths,
            vcat([false], fill(print_underlines, length(vals) - 1)), # don't print underline under the leftmost column
            rndr;
            combine_equals=combine_equals
        )
    )
end

"""
    value_pos(nms, x::String)

Returns the position of the string `x` in the vector of strings or [`AbstractCoefName`](@ref) `nms`.

## Example

```jldoctest
julia> import RegressionTables: CoefName, InterceptCoefName, InteractedCoefName, CategoricalCoefName, value_pos

julia> nms = ["coef1", CoefName("coef2"), InterceptCoefName(), InteractedCoefName(["coef3", "coef4"]), InteractedCoefName([CoefName("coef1"), CoefName("coef3")]), CategoricalCoefName("coef5", "10"), CategoricalCoefName("coef5", "20")];

julia> value_pos(nms, "coef1")
1:1

julia> value_pos(nms, "coef2")
2:2

julia> value_pos(nms, "coef3")
Int64[]

julia> value_pos(nms, "coef3 & coef4")
4:4

julia> value_pos(nms, "(Intercept)")
3:3

julia> value_pos(nms, "coef1 & coef3")
5:5

julia> value_pos(nms, "coef5: 10")
6:6
```
"""
value_pos(nms, x::String) = value_pos(nms, findfirst(string.(nms) .== x))

"""
    value_pos(nms, x::Int)

Checks that `x` is a valid index for the vector of strings or [`AbstractCoefName`](@ref) `nms` and returns a range of `x:x`
"""
function value_pos(nms, x::Int)
    @assert x in eachindex(nms) "x must be a valid index for the coefficient names, which are $(eachindex(nms))"
    x:x
end

"""
    value_pos(nms, x::UnitRange)

Checks that `x` is a valid index for the vector of strings or 
[`AbstractCoefName`](@ref) `nms` and returns `x`
"""
function value_pos(nms, x::UnitRange)
    @assert all(i in eachindex(nms) for i in x) "x must be a valid index for the coefficient names, which are $(eachindex(nms))"
    x
end

"""
    value_pos(nms, x::BitVector)

Returns a vector of indices where `x` is `true`, called by
the regex version of `value_pos`.
"""
value_pos(nms, x::BitVector) = findall(x)

"""
    value_pos(nms, x::Regex)

Looks within each element of the vector `nms` (which is either a string
or an [`AbstractCoefName`](@ref)) and returns a vector of indices where
the regex `x` is found.

## Example

```jldoctest
julia> import RegressionTables: CoefName, InterceptCoefName, InteractedCoefName, CategoricalCoefName, value_pos

julia> nms = ["coef1", CoefName("coef2"), InterceptCoefName(), InteractedCoefName(["coef3", "coef4"]), InteractedCoefName([CoefName("coef1"), CoefName("coef3")]), CategoricalCoefName("coef5", "10"), CategoricalCoefName("coef5", "20")];

julia> value_pos(nms, r"coef1") == [1, 5]
true

julia> value_pos(nms, r"coef[1-3]") == [1, 2, 4, 5]
true

julia> value_pos(nms, r"coef[1-3] & coef4") == [4]
true

julia> value_pos(nms, r" & ") == [4, 5]
true

julia> value_pos(nms, r"coef5") == [6, 7]
true

julia> value_pos(nms, r"coef5: 10") == [6]
true
```
"""
value_pos(nms, x::Regex) = value_pos(nms, occursin.(x, string.(nms)))

"""
    value_pos(nms, x::Nothing)

Returns an empty vector, called by the regex and string version of `value_pos`.
"""
value_pos(nms, x::Nothing) = Int[]

"""
    value_pos(nms, x::Symbol)

Expects a symbol of the form `:last` or `:end` and returns the last
value of `nms`, both are included for consistency with the `Tuple`

## Example

```jldoctest
julia> import RegressionTables: CoefName, InterceptCoefName, InteractedCoefName, CategoricalCoefName, value_pos

julia> nms = ["coef1", CoefName("coef2"), InterceptCoefName(), InteractedCoefName(["coef3", "coef4"]), InteractedCoefName([CoefName("coef1"), CoefName("coef3")]), CategoricalCoefName("coef5", "10"), CategoricalCoefName("coef5", "20")];

julia> value_pos(nms, :last)
7:7

julia> value_pos(nms, :end)
7:7
```
"""
function value_pos(nms, x::Symbol)
    if x == :last
        value_pos(nms, length(nms))
    elseif x == :end
        value_pos(nms, length(nms))
    else
        throw(ArgumentError("Symbol $x not recognized"))
    end
end

"""
    value_pos(nms, x::Tuple{Symbol, Int})

Expects a tuple of the form `(:last, n)` or `(:end, n)`. `(:last, n)` returns
the last `n` values (`1:5` with `(:last, 2)` is `4:5`), while `(:end, n)` returns the last index minus `n` (`1:5` with `(:end, 2)` is `3`).

## Example

```jldoctest
julia> import RegressionTables: CoefName, InterceptCoefName, InteractedCoefName, CategoricalCoefName, value_pos

julia> nms = ["coef1", CoefName("coef2"), InterceptCoefName(), InteractedCoefName(["coef3", "coef4"]), InteractedCoefName([CoefName("coef1"), CoefName("coef3")]), CategoricalCoefName("coef5", "10"), CategoricalCoefName("coef5", "20")];

julia> value_pos(nms, (:last, 2))
6:7

julia> value_pos(nms, (:end, 2))
5:5
```
"""
function value_pos(nms, x::Tuple{Symbol, Int})
    if x[1] == :last
        value_pos(nms, length(nms) - x[2] + 1 : length(nms))
    elseif x[1] == :end
        value_pos(nms, length(nms) - x[2])
    else
        throw(ArgumentError("Symbol $x not recognized"))
    end
end

"""
    reorder_nms_list(nms, order)

Reorders the vector of strings or [`AbstractCoefName`](@ref) `nms` according
to the `order` provided. All elements of `nms` are kept.
"""
function reorder_nms_list(nms, order)
    out = Int[]
    for o in order
        x = value_pos(nms, o)
        for i in x
            if i ∉ out
                push!(out, i)
            end
        end
    end
    for i in 1:length(nms)
        if i ∉ out
            push!(out, i)
        end
    end
    nms[out]
end

"""
    build_nm_list(nms, keep)

Takes the list of strings or [`AbstractCoefName`](@ref) `nms` and returns
a subset of `nms` that contains only the elements in `keep`. Will also
reorder the elements that are kept based on the order of `keep`.
"""
function build_nm_list(nms, keep)
    out = Int[]
    for k in keep
        x = value_pos(nms, k)
        for i in x
            if i ∉ out
                push!(out, i)
            end
        end
    end
    nms[out]
end

"""
    drop_names!(nms, to_drop)

Drops the elements of `nms` that are in `to_drop`. Does not reorder
any other elements.
"""
function drop_names!(nms, to_drop)
    out = Int[]
    for o in to_drop
        x = value_pos(nms, o)
        for i in x
            if i ∉ out
                push!(out, i)
            end
        end
    end
    deleteat!(nms, out)
end

"""
    missing_vars(table::SimpleRegressionResult, coefs::Vector)

Checks whether any of the coefficients in `table` are not in `coefs`,
returns `true` if so, `false` otherwise.
"""
function missing_vars(table::SimpleRegressionResult, coefs::Vector)
    table_coefs = string.(coefnames(table))
    coefs = string.(coefs)
    for x in table_coefs
        if x ∉ coefs
            return true
        end
    end
    false
end

"""
    add_blank(groups::Matrix, n)
    add_blank(groups::Vector{Vector}, n)

Recursively checks whether the number of columns in `groups`
(or the length of the vector `groups`) is less than `n`, if so,
add a blank column (or element) to the left of the matrix (first element
of the vector).

This is used to make sure a provided piece of data is at least `n`
columns, fitting into the table.
"""
function add_blank(groups::Matrix, n)
    if size(groups, 2) < n
        groups = hcat(fill("", size(groups, 1)), groups)
        add_blank(groups, n)
    else
        groups
    end
end
function add_blank(groups::Vector{Vector}, n)
    out = Vector{Vector}()
    for g in groups
        if length(g) < n
            g = vcat(fill("", n - length(g)), g)
        end
        push!(out, g)
    end
    groups
end