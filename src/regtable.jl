
default_round_digits(rndr::AbstractRenderType, x::AbstractRegressionStatistic) = default_round_digits(rndr, value(x))
default_round_digits(rndr::AbstractRenderType, x::AbstractUnderStatistic) = default_round_digits(rndr, value(x))
default_round_digits(rndr::AbstractRenderType, x::CoefValue) = default_round_digits(rndr, value(x))
default_round_digits(rndr::AbstractRenderType, x) = 3

default_fe_yes() = "Yes"
default_fe_no() = ""
default_section_order() = [:groups, :depvar, :number_regressions, :break, :coef, :break, :regtype, :break, :fe, :break, :controls, :break, :stats, :extralines]
default_regression_decoration(rrs) = length(rrs) > 1 ? i -> "($i)" : nothing
default_align() = :r
default_header_align() = :c
default_depvar() = true
default_number_regressions(rrs) = length(rrs) > 1
default_print_fe() = true
default_groups(rrs) = nothing
default_extralines(rrs) = nothing
default_keep(rrs) = Vector{String}()
default_drop(rrs) = Vector{String}()
default_order(rrs) = Vector{String}()
default_fixedeffects(rrs) = Vector{String}()
default_labels() = Dict{String, String}()
default_below_statistic() = STDError
default_stat_below() = true
default_render(rrs) = AsciiTable()
default_file(rrs) = nothing
default_fe_suffix() = "Fixed Effects"
default_print_control_indicator() = true


#region
"""
Produces a publication-quality regression table, similar to Stata's `esttab` and R's `stargazer`.

### Arguments
* `rr::FixedEffectModel...` are the `FixedEffectModel`s from `FixedEffectModels.jl` that should be printed. Only required argument.
* `regressors` is a `Vector` of regressor names (`String`s) that should be shown, in that order. Defaults to an empty vector, in which case all regressors will be shown.
* `fixedeffects` is a `Vector` of FE names (`String`s) that should be shown, in that order. Defaults to an empty vector, in which case all FE's will be shown. Note that the string needs to match the display label exactly, otherwise it will not be shown.
* `align` is a `Symbol` from the set `[:l,:c,:r]` indicating the alignment of results columns (default `:r` right-aligned). Currently works only with ASCII and LaTeX output.
* `labels` is a `Dict` that contains displayed labels for variables (`String`s) and other text in the table. If no label for a variable is found, it default to variable names. See documentation for special values.
* `estimformat` is a `String` that describes the format of the estimate. Defaults to "%0.3f".
* `estim_decoration` is a `Function` that takes the formatted string and the p-value, and applies decorations (such as the beloved stars). Defaults to (* p<0.05, ** p<0.01, *** p<0.001).
* `statisticformat` is a `String` that describes the format of the number below the estimate (se/t). Defaults to "%0.3f".
* `below_statistic` is a `Symbol` that describes a statistic that should be shown below each point estimate. Recognized values are `:blank`, `:se`, `:tstat`, and `:none`. `:none` suppresses the line. Defaults to `:se`.
* `below_decoration` is a `Function` that takes the formatted statistic string, and applies a decorations. Defaults to round parentheses.
* `regression_statistics` is a `Vector` of `Symbol`s that describe statistics to be shown at the bottom of the table. Recognized symbols are `:nobs`, `:r2`, `:adjr2`, `:r2_within`, `:f`, `:p`, `:f_kp`, `:p_kp`, and `:dof`. Defaults to `[:nobs, :r2]`.
* `custom_statistics` is a `NamedTuple` that takes user specified statistics to be shown just above `regression_statistics`. By default each statistic will be labelled by its key. Defaults to `missing`.
* `number_regressions` is a `Bool` that governs whether regressions should be numbered. Defaults to `true`.
* `number_regressions_decoration` is a `Function` that governs the decorations to the regression numbers. Defaults to `s -> "(\$s)"`.
* `groups` is a `Vector` of labels used to group regressions. This can be useful if results are shown for different data sets or sample restrictions.
* `print_fe_section` is a `Bool` that governs whether a section on fixed effects should be shown. Defaults to `true`.
* `print_estimator_section`  is a `Bool` that governs whether to print a section on which estimator (OLS/IV/NL) is used. Defaults to `true`.
* `standardize_coef` is a `Bool` that governs whether the table should show standardized coefficients. Note that this only works with `TableRegressionModel`s, and that only coefficient estimates and the `below_statistic` are being standardized (i.e. the R^2 etc still pertain to the non-standardized regression).
* `out_buffer` is an `IOBuffer` that the output gets sent to (unless an output file is specified, in which case the output is only sent to the file).
* `renderSettings::RenderSettings` is a `RenderSettings` composite type that governs how the table should be rendered. Standard supported types are ASCII (via `asciiOutput(outfile::String)`) and LaTeX (via `latexOutput(outfile::String)`). If no argument to these two functions are given, the output is sent to STDOUT. Defaults to ASCII with STDOUT.
* `transform_labels` is a `Function`, a `Dict` or one of the `Symbol`s `:ampersand`, `:underscore`, `:underscore2space`, `:latex`. See `README.md` for examples.

### Details
A typical use is to pass a number of `FixedEffectModel`s to the function, along with a `RenderSettings` object.
```
regtable(regressionResult1, regressionResult2; renderSettings = asciiOutput())
```
Pass a string to the functions that create a `RenderSettings` to divert output to a file. For example, using LaTeX output,
```
regtable(regressionResult1, regressionResult2; renderSettings = latexOutput("myoutfile.tex"))
```
See the full argument list for details.

### Examples
```julia
using RegressionTables, DataFrames, RDatasets, FixedEffectModels
df = dataset("datasets", "iris")
df[!,:SpeciesDummy] = categorical(df[!,:Species])
df[!,:isSmall] = categorical(df[!,:SepalWidth] .< 2.9)
rr1 = reg(df, @formula(SepalLength ~ SepalWidth))
rr2 = reg(df, @formula(SepalLength ~ SepalWidth + PetalLength + fe(SpeciesDummy)))
rr3 = reg(df, @formula(SepalLength ~ SepalWidth + PetalLength + PetalWidth + fe(SpeciesDummy) + fe(isSmall)))
rr4 = reg(df, @formula(SepalWidth ~ SepalLength + PetalLength + PetalWidth + fe(SpeciesDummy)))
rr5 = reg(df, @formula(SepalWidth ~ SepalLength + (PetalLength ~ PetalWidth) + fe(SpeciesDummy)))
# default
regtable(rr1,rr2,rr3,rr4; renderSettings = asciiOutput())
# display of statistics below estimates
regtable(rr1,rr2,rr3,rr4; renderSettings = asciiOutput(), below_statistic = :blank)
regtable(rr1,rr2,rr3,rr4; renderSettings = asciiOutput(), below_decoration = s -> "[\$(s)]")
# ordering of regressors, leaving out regressors
regtable(rr1,rr2,rr3,rr4; renderSettings = asciiOutput(), regressors = ["SepalLength";"PetalWidth";"SepalWidth"])
# format of the estimates
regtable(rr1,rr2,rr3,rr4; renderSettings = asciiOutput(), estimformat = "%02.5f")
# replace some variable names by other strings
regtable(rr1,rr2,rr3; renderSettings = asciiOutput(), labels = Dict(:SepalLength => "My dependent variable: SepalLength", :PetalLength => "Length of Petal", :PetalWidth => "Width of Petal", Symbol("(Intercept)") => "Const." , :isSmall => "isSmall Dummies", :SpeciesDummy => "Species Dummies"))
# group regressions
regtable(rr1,rr2,rr4,rr3; renderSettings = asciiOutput(), groups = ["grp1", "grp1", "grp2", "grp2"])
# do not print the FE block
regtable(rr1,rr2,rr3,rr4; renderSettings = asciiOutput(), print_fe_section = false)
# re-order fixed effects
regtable(rr1,rr2,rr3,rr4; renderSettings = asciiOutput(), fixedeffects = ["isSmall", "SpeciesDummy"])
# change the yes/no labels in the fixed effect section, and statistics labels
regtable(rr1,rr2,rr3,rr4; renderSettings = asciiOutput(), labels = Dict("__LABEL_FE_YES__" => "Mhm.", "__LABEL_FE_NO__" => "Nope.", "__LABEL_STATISTIC_N__" => "Number of observations", "__LABEL_STATISTIC_R2__" => "R Squared"))
# full set of available statistics
regtable(rr1,rr2,rr3,rr5; renderSettings = asciiOutput(), regression_statistics = [:nobs, :r2, :adjr2, :r2_within, :f, :p, :f_kp, :p_kp, :dof])
# LaTeX output
regtable(rr1,rr2,rr3,rr4; renderSettings = latexOutput())
# LaTeX output to file
regtable(rr1,rr2,rr3,rr4; renderSettings = latexOutput("myoutfile.tex"))
# Custom statistics
comments = ["Baseline", "Preferred"]
means = [Statistics.mean(df.SepalLength[rr1.esample]), Statistics.mean(df.SepalLength[rr2.esample])]
mystats = NamedTuple{(:comments, :means)}((comments, means))
regtable(rr1,rr2; renderSettings = asciiOutput(),  custom_statistics = mystats, labels = Dict("__LABEL_CUSTOM_STATISTIC_comments__" => "Specification", "__LABEL_CUSTOM_STATISTIC_means__" => "My custom mean"))

```
"""
#endregion
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
function regtable(
    rrs::RegressionModel...;
    renderSettings::AbstractRenderType = default_render(rrs),
    keep::Vector = default_keep(rrs), # allows :last and :end as symbol
    drop::Vector = default_drop(rrs), # allows :last and :end as symbol
    order::Vector = default_order(rrs),
    fixedeffects::Vector{String} = default_fixedeffects(rrs),
    labels::Dict{String,String} = default_labels(),
    align::Symbol = default_align(),
    header_align::Symbol = default_header_align(),
    #estim_decoration::Function = make_estim_decorator([0.001, 0.01, 0.05]),
    below_statistic = default_below_statistic(),# can also be nothing
    stat_below::Bool = default_stat_below(),# true means StdError or TStat appears below, false means it appears to the right
    regression_statistics = unique(union(default_regression_statistics.(rrs)...)), # collection of all statistics to be printed
    groups = default_groups(rrs), # displayed above the regression variables
    print_depvar::Bool = default_depvar(),
    number_regressions_decoration = default_regression_decoration(rrs), # decoration for the column number, does not display by default if only 1 regression
    print_estimator_section = length(unique(regressiontype.(rrs))) > 1,
    print_fe_section = default_print_fe(), # defaults to true but only matters if fixed effects are present
    file = default_file(rrs),
    transform_labels::Union{Dict,Symbol} = Dict{String, String}(),
    extralines = default_extralines(rrs),
    section_order = default_section_order(),
    fe_yes = default_fe_yes(),
    fe_no = default_fe_no(),
    fe_suffix = default_fe_suffix(),
    print_control_indicator = default_print_control_indicator(),
)
    @assert align ∈ (:l, :r, :c) "align must be one of :l, :r, :c"
    @assert header_align ∈ (:l, :r, :c) "header_align must be one of :l, :r, :c"
    out_order = []
    for (i, s) in enumerate(section_order)
        if s == :depvar
            if print_depvar
                push!(out_order, :depvar)
            end
        elseif s == :groups
            if groups !== nothing
                push!(out_order, groups)
            end
        elseif s == :number_regressions
            if number_regressions_decoration !== nothing
                push!(out_order, :number_regressions)
            end
        elseif s == :regtype
            if print_estimator_section
                push!(out_order, :regtype)
            end
        elseif s == :fe
            if print_fe_section
                push!(out_order, :fe)
            end
        elseif s == :extralines 
            if extralines !== nothing
                push!(out_order, extralines)
            end
        elseif s == :break
            if i == 1
                push!(out_order, :break)
            elseif last(out_order) != :break
                push!(out_order, :break)
            end
        elseif s == :controls
            if print_control_indicator
                push!(out_order, :controls)
            end
        else
            push!(out_order, s)
        end
    end
    if last(out_order) == :break && last(section_order) != :break
        pop!(out_order)
    end
    RegressionTable(
        SimpleRegressionResult.(
            rrs;
            regression_statistics,
            labels,
            fixedeffects,
            transform_labels,
            fe_suffix
        )...;
        renderSettings,
        below_statistic,
        number_regressions_decoration,
        sections=out_order,
        stat_below,
        align='l' * join(fill(align, length(rrs)), ""),
        header_align='l' * join(fill(header_align, length(rrs)), ""),
        fe_yes,
        fe_no,
        file,
        keep,
        drop,
        order,
    )
end

function combine_fe(tables, yes_val, no_val)
    fe = String[]
    for table in tables
        if !isnothing(table.fixedeffects)
            fe = union(fe, table.fixedeffects)
        end
    end
    if length(fe) == 0
        return nothing
    end
    mat = zeros(Bool, length(fe), length(tables))
    for (i, table) in enumerate(tables)
        if table.fixedeffects !== nothing
            for (j, f) in enumerate(fe)
                mat[j, i] = f in table.fixedeffects
            end
        end
    end
    out = [i ? yes_val : no_val for i in mat]
    hcat(fe, out)
end

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
function push_DataRow!(data::Vector{<:DataRow}, vals::Vector{<:Vector}, align, colwidths, print_underlines::Bool, rndr::AbstractRenderType; combine_equals=print_underlines)
    for v in vals
        push_DataRow!(data, v, align, colwidths, print_underlines, rndr; combine_equals)
    end
end
push_DataRow!(data::Vector{DataRow{T}}, val::DataRow, args...; vargs...) where {T<:AbstractRenderType} = push!(data, T(val))
function push_DataRow!(data::Vector{<:DataRow}, vals::Vector, align, colwidths, print_underlines::Bool, rndr::AbstractRenderType; combine_equals=print_underlines)
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
        println(align)
        println(colwidths)
    end
    push!(
        data,
        DataRow(
            vals,
            align,
            colwidths,
            print_underlines,
            rndr;
            combine_equals=combine_equals
        )
    )
end

value_pos(nms, x::String) = value_pos(nms, findfirst(string.(nms) .== x))
value_pos(nms, x::Int) = x:x
value_pos(nms, x::UnitRange) = x
value_pos(nms, x::BitVector) = [i for (i, b) in enumerate(x) if b]
value_pos(nms, x::Regex) = value_pos(nms, occursin.(x, string.(nms)))
value_pos(nms, x::Nothing) = Int[]
function value_pos(nms, x::Symbol)
    if x == :last
        value_pos(nms, length(nms))
    elseif x == :end
        value_pos(nms, length(nms))
    else
        throw(ArgumentError("Symbol $x not recognized"))
    end
end
function value_pos(nms, x::Tuple{Symbol, Int})
    if x[1] == :last
        value_pos(nms, length(nms) - x[2] + 1 : length(nms))
    elseif x[1] == :end
        value_pos(nms, length(nms) - x[2] + 1)
    else
        throw(ArgumentError("Symbol $x not recognized"))
    end
end

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

build_nm_list(nms, x) = nms[value_pos(nms, x)]

function missing_vars(table::SimpleRegressionResult, coefs::Vector{String})
    table_coefs = string.(coefnames(table))
    for x in table_coefs
        if x ∉ coefs
            return true
        end
    end
    false
end

function RegressionTable(
    tables::SimpleRegressionResult...;
    renderSettings::T = AsciiTable(),
    below_statistic = STDError,
    stat_below=true,
    number_regressions_decoration = i::Int64 -> "($i)",
    sections = [
        # can include groups and extralines
        # if a symbol, can also be a pair which adds an extra line as a label
        :header,
        :number_regressions,
        :break,
        :coef,
        :break,
        :regtype,
        :break,
        :fe,
        :break,
        :stats,
    ],
    align='l' * join(fill('c', length(tables)), ""),
    header_align='l' * join(fill('c', length(tables)), ""),
    fe_yes = "Yes",
    fe_no = "No",
    file=nothing,
    keep = String[],
    drop = String[],
    order = String[],
) where T <: AbstractRenderType

    out = Vector{DataRow{T}}()
    breaks = Int[]
    wdths=fill(0, length(tables)+1)

    nms = union(coefnames.(tables)...) |> unique
    if length(order) > 0
        nms = reorder_nms_list(nms, order)
    end
    if length(keep) > 0
        nms = unique(vcat(build_nm_list.(Ref(nms), keep)...))
    end
    if length(drop) > 0 # not currently working
        if eltype(drop) <: Int
            drop = nms[drop]
        end
        nms = setdiff(nms, drop)
    end
    coefvalues = Matrix{Any}(missing, length(nms), length(tables))
    coefbelow = Matrix{Any}(missing, length(nms), length(tables))
    for (i, table) in enumerate(tables)
        for (j, nm) in enumerate(nms)
            if nm in coefnames(table)
                k = findfirst(coefnames(table) .== nm)
                coefvalues[j, i] = CoefValue(coef(table)[k], table.coefpvalues[k])
                if below_statistic !== nothing
                    coefbelow[j, i] = below_statistic(stderror(table)[k], coef(table)[k])
                end
            end
        end
    end
    in_header = true
    for (i, s) in enumerate(sections)

        if isa(s, Pair)
            v = first(s)
            push_DataRow!(out, DataRow(vcat([last(s)], fill("", length(tables)))), align, wdths, false, T())
        else
            v = s
        end
        if !isa(v, Symbol)
            al = in_header ? header_align : align
            push_DataRow!(out, v, al, wdths, in_header, T(); combine_equals=in_header)
            continue
        end
        if v == :break
            push!(breaks, length(out))
        elseif v == :depvar
            underlines = i + 1 < length(sections) && sections[i+1] != :break
            push_DataRow!(out, collect(responsename.(tables)), header_align, wdths, underlines, T(); combine_equals=true)
        elseif v == :number_regressions
            push_DataRow!(out, number_regressions_decoration.(1:length(tables)), align, wdths, false, T(); combine_equals=false)
        elseif v == :coef
            in_header = false
            if below_statistic === nothing
                push_DataRow!(out, coefvalues, align, wdths, false, T())
            else
                if stat_below
                    temp = hcat(nms, coefvalues)
                    for i in 1:size(temp, 1)
                        push_DataRow!(out, temp[i, :], align, wdths, false, T())
                        push_DataRow!(out, coefbelow[i, :], align, wdths, false, T())
                    end
                else
                    x = [(x, y) for (x, y) in zip(coefvalues, coefbelow)]
                    temp = hcat(nms, x)
                    push_DataRow!(out, temp, align, wdths, false, T())
                end
            end
        elseif v == :fe
            fe = combine_fe(tables, fe_yes, fe_no)
            if !isnothing(fe)
                push_DataRow!(out, fe, align, wdths, false, T())
            end
        elseif v == :regtype
            regressiontype = vcat([RegressionType], [RegressionType(t.regressiontype) for t in tables])
            push_DataRow!(out, regressiontype, align, wdths, false, T())
        elseif v == :stats
            stats = combine_statistics(tables)
            push_DataRow!(out, stats, align, wdths, false, T())
        elseif v == :controls
            v = missing_vars.(tables, Ref(string.(nms)))
            if !any(v)
                continue
            end
            dat = vcat(
                [HasControls],
                HasControls.(v) |> collect
            )
            push_DataRow!(out, dat, align, wdths, false, T())
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