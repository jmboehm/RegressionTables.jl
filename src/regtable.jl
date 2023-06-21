
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
function regtable(rrs...;
    regressors::Vector{String} = Vector{String}(),
    fixedeffects::Vector{String} = Vector{String}(),
    labels::Dict{String,String} = Dict{String,String}(),
    align::Symbol = :r,
    #estim_decoration::Function = make_estim_decorator([0.001, 0.01, 0.05]),
    below_statistic = STDError,
    regression_statistics = [Nobs, R2],
    custom_statistics::Union{Missing,NamedTuple} = missing,
    number_regressions::Bool = true,
    number_regressions_decoration::Function = i::Int64 -> "($i)",
    groups = [],
    print_fe_section = true,
    print_estimator_section = true,
    standardize_coef = false,
    out_buffer = IOBuffer(),
    transform_labels::Union{Dict,Function,Symbol} = identity,
    renderSettings = AsciiTable,
    print_result = true,
    extralines = [],
)

    transform_labels = transform_labels isa Function ? transform_labels : _escape(transform_labels)
    groups = add_blank(groups, length(rrs)+1)
    renderSettings(
        regtablesingle.(
            rrs;
            regression_statistics,
            labels,
            fixedeffects,
            regressors,
            transform_labels
        )...;
        below_statistic,
        number_regressions,
        number_regressions_decoration,
        groups,
        extralines
    )
end
#=
    _transform_labels = transform_labels isa Function ? transform_labels : _escape(transform_labels)
    
    if length(groups) > 0
        groupBlock = reshape(string.(groups), :, numberOfResults) .|> _transform_labels
        regressandBlock = [fill("", size(groupBlock, 1)) groupBlock;
                           regressandBlock]
    end

    # Fixed effects block
    print_fe_block = print_fe_section && any(has_fe.(rr))
    if print_fe_block

        # construct list of fixed effects for display
        feList = Vector{AbstractTerm}()
        for r in rr if has_fe(r)

            for term in eachterm(r.formula.rhs)
                if has_fe(term) && !(any(name.(feList) .== name(term)))
                    push!(feList, term)
                end
            end

        end end
        # in case the user supplies a list of FE's, cut down the list
        if !isempty(fixedeffects)
            # compare the user-supplied list to `feList`, and keep only those that match
            for i = length(feList):-1:1
                if !any(name(feList[i]) .== fixedeffects)
                    deleteat!(feList, [i])
                end
            end
        end


        # construct a list of fixed effects (Term's) for each RegressionResult
        febyrr = Vector{Vector{AbstractTerm}}()
        for r in rr
            fe = Vector{AbstractTerm}()
            if has_fe(r)
                for term in eachterm(r.formula.rhs)
                    if has_fe(term)
                        push!(fe, term)
                    end
                end
            end
            push!(febyrr, fe)
        end

        # construct FE block
        feBlock = Array{String}(undef,0,numberOfResults+1)
        for fe in feList
            feLine = fill("", 1, numberOfResults+1)
            for resultIndex = 1:numberOfResults
                index = findall(name(fe) .== name.(febyrr[resultIndex]))
                if !isempty(index)
                    feLine[1,resultIndex+1] = haskey(labels, "__LABEL_FE_YES__") ? labels["__LABEL_FE_YES__"] : renderSettings.label_fe_yes
                else
                    feLine[1,resultIndex+1] = haskey(labels, "__LABEL_FE_NO__") ? labels["__LABEL_FE_NO__"] : renderSettings.label_fe_no
                end
            end
            # check if the regressor was not found
            if feLine == fill("", 1, numberOfResults+1)
               @warn("Fixed effect $fe not found in any regression results.")
            else
                # add label on the left:
                feLine[1,1] = haskey(labels,name(fe)) ? labels[name(fe)] : _transform_labels(name(fe))
                # add to estimateBlock
                feBlock = [feBlock; feLine]
            end
        end
    end

    if print_estimator_section
        estimatorBlock = fill("", 1, numberOfResults+1)
        estimatorBlock[1,1] = haskey(labels, "__LABEL_ESTIMATOR__") ? labels["__LABEL_ESTIMATOR__"] : renderSettings.label_estimator
        for i = 1:numberOfResults
            if has_iv(rr[i])
                estimatorBlock[1,i+1] =  haskey(labels, "__LABEL_ESTIMATOR_IV__") ? labels["__LABEL_ESTIMATOR_IV__"] : renderSettings.label_estimator_iv
            if islinear(rr[i])
                estimatorBlock[1,i+1] =  haskey(labels, "__LABEL_ESTIMATOR_OLS__") ? labels["__LABEL_ESTIMATOR_OLS__"] : renderSettings.label_estimator_ols
            else
                estimatorBlock[1,i+1] =  haskey(labels, "__LABEL_ESTIMATOR_NL__") ? labels["__LABEL_ESTIMATOR_NL__"] : renderSettings.label_estimator_nl
            end
        end
    end

    if length(regression_statistics)>0 || !ismissing(custom_statistics)
        # we have a statistics block (N, R^2, etc)
        print_statistics_block = true

        # one line for each custom statistic
        if !ismissing(custom_statistics)
            custom_statisticBlock = fill("", length(custom_statistics), numberOfResults+1)
            for i = 1:length(custom_statistics)
                stringKey = String(keys(custom_statistics)[i])
                custom_statisticBlock[i,1] = haskey(labels, "__LABEL_CUSTOM_STATISTIC_$(stringKey)__") ? labels["__LABEL_CUSTOM_STATISTIC_$(stringKey)__"] : stringKey
                for resultIndex = 1:numberOfResults
                    custom_statisticBlock[i,resultIndex+1] = typeof(custom_statistics[i][resultIndex]) == String ? custom_statistics[i][resultIndex] : sprintf1(statisticformat,custom_statistics[i][resultIndex])
                end
            end
        end

        # one line for each statistic
        statisticBlock = fill("", length(regression_statistics), numberOfResults+1)
        for i = 1:length(regression_statistics)
            if regression_statistics[i] == :r2_a
                @warn "Use :adjr2 instead of :r2_a"
                regression_statistics[i] = :adjr2
            end
            if regression_statistics[i] == :nobs
                statisticBlock[i,1] = haskey(labels, "__LABEL_STATISTIC_N__") ? labels["__LABEL_STATISTIC_N__"] : renderSettings.label_statistic_n
                for resultIndex = 1:numberOfResults
                    statisticBlock[i,resultIndex+1] = sprintf1("%'i",nobs(rr[resultIndex]))
                end
            elseif regression_statistics[i] == :r2
                statisticBlock[i,1] = haskey(labels, "__LABEL_STATISTIC_R2__") ? labels["__LABEL_STATISTIC_R2__"] : renderSettings.label_statistic_r2
                for resultIndex = 1:numberOfResults
                    statisticBlock[i,resultIndex+1] = isnan(ther2(rr[resultIndex])) ? "" : sprintf1(statisticformat, ther2(rr[resultIndex]))
                end
            elseif regression_statistics[i] == :adjr2
                statisticBlock[i,1] = haskey(labels, "__LABEL_STATISTIC_adjr2__") ? labels["__LABEL_STATISTIC_adjr2__"] : renderSettings.label_statistic_adjr2
                for resultIndex = 1:numberOfResults
                    statisticBlock[i,resultIndex+1] = isdefined(rr[resultIndex], :adjr2) && !isnothing(rr[resultIndex].adjr2) ? sprintf1(statisticformat, rr[resultIndex].adjr2) : ""
                end
            elseif regression_statistics[i] == :r2_within
                statisticBlock[i,1] = haskey(labels, "__LABEL_STATISTIC_R2_WITHIN__") ? labels["__LABEL_STATISTIC_R2_WITHIN__"] : renderSettings.label_statistic_r2_within
                for resultIndex = 1:numberOfResults
                    statisticBlock[i,resultIndex+1] = isdefined(rr[resultIndex], :r2_within) && !isnothing(rr[resultIndex].r2_within) ? sprintf1(statisticformat, rr[resultIndex].r2_within) : ""
                end
            elseif regression_statistics[i] == :f
                statisticBlock[i,1] = haskey(labels, "__LABEL_STATISTIC_F__") ? labels["__LABEL_STATISTIC_F__"] : renderSettings.label_statistic_f
                for resultIndex = 1:numberOfResults
                    statisticBlock[i,resultIndex+1] = isdefined(rr[resultIndex], :F) ? sprintf1(statisticformat, rr[resultIndex].F) : ""
                end
            elseif regression_statistics[i] == :p
                statisticBlock[i,1] = haskey(labels, "__LABEL_STATISTIC_P__") ? labels["__LABEL_STATISTIC_P__"] : renderSettings.label_statistic_p
                for resultIndex = 1:numberOfResults
                    statisticBlock[i,resultIndex+1] = isdefined(rr[resultIndex], :p) ? sprintf1(statisticformat, rr[resultIndex].p) : ""
                end
            elseif regression_statistics[i] == :f_kp
                statisticBlock[i,1] = haskey(labels, "__LABEL_STATISTIC_F_KP__") ? labels["__LABEL_STATISTIC_F_KP__"] : renderSettings.label_statistic_f_kp
                for resultIndex = 1:numberOfResults
                    statisticBlock[i,resultIndex+1] = isdefined(rr[resultIndex], :F_kp) && !isnothing(rr[resultIndex].F_kp) ? sprintf1(statisticformat, rr[resultIndex].F_kp) : ""
                end
            elseif regression_statistics[i] == :p_kp
                statisticBlock[i,1] = haskey(labels, "__LABEL_STATISTIC_P_KP__") ? labels["__LABEL_STATISTIC_P_KP__"] : renderSettings.label_statistic_p_kp
                for resultIndex = 1:numberOfResults
                    statisticBlock[i,resultIndex+1] = isdefined(rr[resultIndex], :p_kp) && !isnothing(rr[resultIndex].p_kp) ? sprintf1(statisticformat, rr[resultIndex].p_kp) : ""
                end
            elseif regression_statistics[i] == :dof
                statisticBlock[i,1] = haskey(labels, "__LABEL_STATISTIC_DOF__") ? labels["__LABEL_STATISTIC_DOF__"] : renderSettings.label_statistic_dof
                for resultIndex = 1:numberOfResults
                    statisticBlock[i,resultIndex+1] = isdefined(rr[resultIndex], :dof_residual) ? sprintf1("%i",rr[resultIndex].dof_residual) : ""
                end
            end

        end
        statisticBlock = !ismissing(custom_statistics) ? vcat(custom_statisticBlock, statisticBlock) : statisticBlock
    else
        print_statistics_block = false
    end

    # construct alignment string:
    if align ∉ [:l,:c,:r]
        error("`align` keyword needs to be one of [:r,:c,:l]")
    end
    align_results = "l" * (string(align) ^ numberOfResults)

    bodyBlocks = [estimateBlock]

    if print_fe_block
        push!(bodyBlocks, feBlock)
    end

    if print_estimator_section
        push!(bodyBlocks, estimatorBlock)
    end

    if print_statistics_block
        push!(bodyBlocks, statisticBlock)
    end


    # if we're numbering the regression columns, add a block before the other stuff

    if number_regressions
        insert!(bodyBlocks,1,regressionNumberBlock)
    end

    # create RegressionTable
    tab = RegressionTable(numberOfResults+1, "", regressandBlock, bodyBlocks , "")

    # create output stream
    if renderSettings.outfile == ""
        outstream = out_buffer
    else
        try
            outstream = open(renderSettings.outfile, "w")
        catch ex
            error("Error opening file $(renderSettings.outfile): $(ex)")
        end
    end

    render(outstream, tab , align_results, renderSettings )

    # if we're writing to a file, close it
    if renderSettings.outfile != ""
        close(outstream)
    else # else print the table
        # if desired
        if print_result
            println(Compat.String(take!(copy(outstream))))
        else
            # return the buffer
            take!(copy(outstream))
        end
    end
end

=#