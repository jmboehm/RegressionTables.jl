
"""
Produces a publication-quality regression table, similar to Stata's `esttab` and R's `stargazer`.

### Arguments
* `rr::AbstractRegressionResult...` are the `AbstractRegressionResult`s from `FixedEffectModels.jl` that should be printed. Only required argument.
* `regressors` is a `Vector` of regressor names (`String`s) that should be shown, in that order. Defaults to an empty vector, in which case all regressors will be shown.
* `fixedeffects` is a `Vector` of FE names (`String`s) that should be shown, in that order. Defaults to an empty vector, in which case all FE's will be shown.
* `labels` is a `Dict` that contains displayed labels for variables (strings) and other text in the table. If no label for a variable is found, it default to variable names. See documentation for special values.
* `estimformat` is a `String` that describes the format of the estimate. Defaults to "%0.3f".
* `estim_decoration` is a `Function` that takes the formatted string and the p-value, and applies decorations (such as the beloved stars). Defaults to (* p<0.05, ** p<0.01, *** p<0.001).
* `statisticformat` is a `String` that describes the format of the number below the estimate (se/t). Defaults to "%0.4f".
* `below_statistic` is a `Symbol` that describes a statistic that should be shown below each point estimate. Recognized values are `:blank`, `:se`, and `:tstat`. Defaults to `:se`.
* `below_decoration` is a `Function` that takes the formatted statistic string, and applies a decorations. Defaults to round parentheses.
* `regression_statistics` is a `Vector` of `Symbol`s that describe statistics to be shown at the bottom of the table. Recognized symbols are `:nobs`, `:r2`, `:adjr2`, `:r2_within`, `:f`, `:p`, `:f_kp`, `:p_kp`, and `:dof`. Defaults to `[:nobs, :r2]`.
* `number_regressions` is a `Bool` that governs whether regressions should be numbered. Defaults to `true`.
* `number_regressions_decoration` is a `Function` that governs the decorations to the regression numbers. Defaults to `s -> "(\$s)"`.
* `print_fe_section` is a `Bool` that governs whether a section on fixed effects should be shown. Defaults to `true`.
* `print_estimator_section`  is a `Bool` that governs whether to print a section on which estimator (OLS/IV/NL) is used. Defaults to `true`.
* `standardize_coef` is a `Bool` that governs whether the table should show standardized coefficients. Note that this only works with `DataFrameRegressionModel`s, and that only coefficient estimates and the `below_statistic` are being standardized (i.e. the R^2 etc still pertain to the non-standardized regression).
* `out_buffer` is an `IOBuffer` that the output gets sent to (unless an output file is specified, in which case the output is only sent to the file).
* `renderSettings::RenderSettings` is a `RenderSettings` composite type that governs how the table should be rendered. Standard supported types are ASCII (via `asciiOutput(outfile::String)`) and LaTeX (via `latexOutput(outfile::String)`). If no argument to these two functions are given, the output is sent to STDOUT. Defaults to ASCII with STDOUT.

### Details
A typical use is to pass a number of `AbstractRegressionResult`s to the function, along with a `RenderSettings` object.
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
df[:SpeciesDummy] = pool(df[:Species])
df[:isSmall] = pool(df[:SepalWidth] .< 2.9)
rr1 = reg(df, @model(SepalLength ~ SepalWidth))
rr2 = reg(df, @model(SepalLength ~ SepalWidth + PetalLength   , fe = SpeciesDummy))
rr3 = reg(df, @model(SepalLength ~ SepalWidth + PetalLength + PetalWidth  , fe = SpeciesDummy  + isSmall))
rr4 = reg(df, @model(SepalWidth ~ SepalLength + PetalLength + PetalWidth  , fe = SpeciesDummy))
rr5 = reg(df, @model(SepalWidth ~ SepalLength + (PetalLength ~ PetalWidth)  , fe = SpeciesDummy))
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
regtable(rr1,rr2,rr3; renderSettings = asciiOutput(), labels = Dict("SepalLength" => "My dependent variable: SepalLength", "PetalLength" => "Length of Petal", "PetalWidth" => "Width of Petal", "(Intercept)" => "Const." , "isSmall" => "isSmall Dummies", "SpeciesDummy" => "Species Dummies"))
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
```
"""
function regtable(rr::Union{AbstractRegressionResult,DataFrameRegressionModel}...;
    regressors::Vector{String} = Vector{String}(),
    fixedeffects::Vector{String} = Vector{String}(),
    labels::Dict{String,String} = Dict{String,String}(),
    estimformat::String = "%0.3f",
    estim_decoration::Function = default_ascii_estim_decoration,
    statisticformat::String = "%0.3f",
    below_statistic::Symbol = :se,
    below_decoration::Function = s::String -> "($s)",
    regression_statistics::Vector{Symbol} = [:nobs, :r2],
    number_regressions::Bool = true,
    number_regressions_decoration::Function = i::Int64 -> "($i)",
    print_fe_section = true,
    print_estimator_section = true,
    standardize_coef = false,
    out_buffer = IOBuffer(),
    renderSettings::RenderSettings = asciiOutput()
    )

    # define some functions that makes use of StatsModels' RegressionModels
    coefnames(r::DataFrameRegressionModel) = StatsModels.coefnames(r.mf)
    coefnames(r::AbstractRegressionResult) = r.coefnames
    # if standardize_coef == true 
    #     function coef(r::DataFrameRegressionModel)
    #         cc = StatsModels.coef(r)
    #         return [ cc[i]*std(r.model.pp.X[:,i])/std(r.model.rr.y) for i in 1:length(cc) ]
    #     end
    #     function vcov(r::DataFrameRegressionModel)
    #         vc = StatsModels.vcov(r)
    #         mul = [ std(r.model.pp.X[:,i])*std(r.model.pp.X[:,j])/(std(r.model.rr.y)*std(r.model.rr.y)) for i in 1:size(cc,1), j in 1:size(cc,1)  ]
    #         return mul .* vc
    #     end
    # else # do not standardize
    #     function coef(r::DataFrameRegressionModel) 
    #         return StatsModels.coef(r)
    #     end
    #     function vcov(r::DataFrameRegressionModel)
    #         return StatsModels.vcov(r)
    #     end
    # end
    coef(r::AbstractRegressionResult) = r.coef
    vcov(r::AbstractRegressionResult) = r.vcov
    coef(r::DataFrameRegressionModel) = StatsModels.coef(r)
    vcov(r::DataFrameRegressionModel) = StatsModels.vcov(r)
    df_residual(r::AbstractRegressionResult) = dof_residual(r)
    df_residual(r::DataFrameRegressionModel) = dof_residual(r)
    yname(r::AbstractRegressionResult) = r.yname
    yname(r::DataFrameRegressionModel) = r.mf.terms.eterms[1]
    ther2(r::AbstractRegressionResult) = r.r2
    ther2(r::DataFrameRegressionModel) = isa(r.model, LinearModel) ? r2(r) : NaN

    # print a warning message if standardize_coef == true but one
    # of the regression results is not a DataFrameRegressionModel
    if standardize_coef && any(.!isa.(rr,StatsModels.DataFrameRegressionModel))
        warn("Standardized coefficients are only shown for DataFrameRegressionModel regression results.")
    end

    numberOfResults = size(rr,1)

    # Create an RegressionTable from the regression results

    # ordering of regressors:
    if length(regressors) == 0
        # construct default ordering: from ordering in regressions (like in Stata)
        regressorList = Vector{String}()
        for r in rr # AbstractRegressionResult
            names = coefnames(r)
            for regressorIndex = 1:length(names)
                if !(any(regressorList .== names[regressorIndex]))
                    # add to list
                    push!(regressorList, names[regressorIndex])
                end
            end
        end
    else
        # take the list of regressors from the argument
        regressorList = regressors
    end

    # for each regressor, check each regression result, calculate statistic, and construct block
    estimateBlock = Array{String}(undef,0,numberOfResults+1)
    for regressor in regressorList
        estimateLine = fill("", 2, numberOfResults+1)
        for resultIndex = 1:numberOfResults
            thiscnames = coefnames(rr[resultIndex])
            thiscoef = coef(rr[resultIndex])
            thisvcov = vcov(rr[resultIndex])
            if standardize_coef && isa(rr[resultIndex],StatsModels.DataFrameRegressionModel)
                thiscoef = [ thiscoef[i]*std(rr[resultIndex].model.pp.X[:,i])/std(rr[resultIndex].model.rr.y) for i in 1:length(thiscoef) ]
                mul = [ std(rr[resultIndex].model.pp.X[:,i])*std(rr[resultIndex].model.pp.X[:,j])/(std(rr[resultIndex].model.rr.y)*std(rr[resultIndex].model.rr.y)) for i in 1:length(thiscoef), j in 1:length(thiscoef)  ]
                thisvcov  = mul .* thisvcov
            end
            thisdf_residual = df_residual(rr[resultIndex])
            index = findall(regressor .== thiscnames)
            if !isempty(index)
                pval = ccdf(FDist(1, thisdf_residual ), abs2(thiscoef[index[1]]/sqrt(thisvcov[index[1],index[1]])))
                estimateLine[1,resultIndex+1] = estim_decoration(sprintf1(estimformat,thiscoef[index[1]]),pval)
                if below_statistic == :tstat
                    s = sprintf1(statisticformat, thiscoef[index[1]]/sqrt(thisvcov[index[1],index[1]]))
                    estimateLine[2,resultIndex+1] = below_decoration(s)
                elseif below_statistic == :se
                    s = sprintf1(statisticformat, sqrt(thisvcov[index[1],index[1]]))
                    estimateLine[2,resultIndex+1] = below_decoration(s)
                elseif below_statistic == :blank
                    estimateLine[2,resultIndex+1] = "" # for the sake of completeness
                end
            end
        end
        # check if the regressor was not found
        if estimateLine == fill("", 2, numberOfResults+1)
            warn("Regressor $regressor not found among regression results.")
        else
            # add label on the left:
            estimateLine[1,1] = haskey(labels,regressor) ? labels[regressor] : regressor
            # add to estimateBlock
            estimateBlock = [estimateBlock; estimateLine]
        end
    end

    # Regressand block
    #   needs to be separately rendered
    regressandBlock = fill("", 1, numberOfResults+1)
    for rIndex = 1:numberOfResults
        # keep in mind that yname is a Symbol
        regressandBlock[1,rIndex+1] = haskey(labels,string(yname(rr[rIndex]))) ? labels[string(yname(rr[rIndex]))] : string(yname(rr[rIndex]))
    end

    # Regression numbering block (if we do it)
    if number_regressions
        regressionNumberBlock = fill("", 1, numberOfResults + 1)
        for rIndex = 1:numberOfResults
            regressionNumberBlock[1,rIndex+1] = number_regressions_decoration(rIndex)
        end
    end

    # Fixed effects block
    print_fe_block = print_fe_section && any(isFERegressionResult.(rr))
    if print_fe_block

        # if no list of FE's to include is given, construct it by order in the regressions
        if length(fixedeffects) == 0

            # construct list of fixed effects for display
            feList = Vector{String}()
            for r in rr if isFERegressionResult(r)

                if isa(r.feformula, Symbol)
                    if !(any(feList .== string(r.feformula)))
                        # add to list
                        push!(feList, string(r.feformula))
                    end
                elseif r.feformula.args[1] == :+
                    x = r.feformula.args
                    for i in 2:length(x) if isa(x[i], Symbol)
                        if !(any(feList .== string(x[i])))
                            # add to list
                            push!(feList, string(x[i]))
                        end
                    end end
                end

            end end
        else
            # take the user-supplied list of fixed effects
            feList = fixedeffects
        end

        # construct a list of fixed effects (strings) for each RegressionResult
        febyrr = Vector{Vector{String}}()
        for r in rr
            fe = Vector{String}()
            if isFERegressionResult(r)
                if isa(r.feformula, Symbol)
                    # add to list
                    push!(fe, string(r.feformula))
                elseif r.feformula.args[1] == :+
                    x = r.feformula.args
                    for i in 2:length(x) if isa(x[i], Symbol)
                        # add to list
                        push!(fe, string(x[i]))
                    end end
                end
            end
            push!(febyrr, fe)
        end

        # construct FE block
        feBlock = Array{String}(undef,0,numberOfResults+1)
        for fe in feList
            feLine = fill("", 1, numberOfResults+1)
            for resultIndex = 1:numberOfResults if isFERegressionResult(rr[resultIndex])
                index = findall(fe .== febyrr[resultIndex])
                if !isempty(index)
                    feLine[1,resultIndex+1] = haskey(labels, "__LABEL_FE_YES__") ? labels["__LABEL_FE_YES__"] : renderSettings.label_fe_yes
                else
                    feLine[1,resultIndex+1] = haskey(labels, "__LABEL_FE_NO__") ? labels["__LABEL_FE_NO__"] : renderSettings.label_fe_no
                end
            end end
            # check if the regressor was not found
            if feLine == fill("", 1, numberOfResults+1)
                warn("Fixed effect $fe not found in any regression results.")
            else
                # add label on the left:
                feLine[1,1] = haskey(labels,fe) ? labels[fe] : fe
                # add to estimateBlock
                feBlock = [feBlock; feLine]
            end
        end
    end

    if print_estimator_section
        estimatorBlock = fill("", 1, numberOfResults+1)
        estimatorBlock[1,1] = haskey(labels, "__LABEL_ESTIMATOR__") ? labels["__LABEL_ESTIMATOR__"] : renderSettings.label_estimator
        for i = 1:numberOfResults
            if isOLSRegressionResult(rr[i])
                estimatorBlock[1,i+1] =  haskey(labels, "__LABEL_ESTIMATOR_OLS__") ? labels["__LABEL_ESTIMATOR_OLS__"] : renderSettings.label_estimator_ols
            elseif isIVRegressionResult(rr[i])
                estimatorBlock[1,i+1] =  haskey(labels, "__LABEL_ESTIMATOR_IV__") ? labels["__LABEL_ESTIMATOR_IV__"] : renderSettings.label_estimator_iv
            else
                estimatorBlock[1,i+1] =  haskey(labels, "__LABEL_ESTIMATOR_NL__") ? labels["__LABEL_ESTIMATOR_NL__"] : renderSettings.label_estimator_nl
            end
        end
    end

    if length(regression_statistics)>0
        # we have a statistics block (N, R^2, etc)
        print_statistics_block = true

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
                    statisticBlock[i,resultIndex+1] = isdefined(rr[resultIndex], :adjr2) ? sprintf1(statisticformat, rr[resultIndex].adjr2) : ""
                end
            elseif regression_statistics[i] == :r2_within
                statisticBlock[i,1] = haskey(labels, "__LABEL_STATISTIC_R2_WITHIN__") ? labels["__LABEL_STATISTIC_R2_WITHIN__"] : renderSettings.label_statistic_r2_within
                for resultIndex = 1:numberOfResults
                    statisticBlock[i,resultIndex+1] = isdefined(rr[resultIndex], :r2_within) ? sprintf1(statisticformat, rr[resultIndex].r2_within) : ""
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
                    statisticBlock[i,resultIndex+1] = isdefined(rr[resultIndex], :F_kp) ? sprintf1(statisticformat, rr[resultIndex].F_kp) : ""
                end
            elseif regression_statistics[i] == :p_kp
                statisticBlock[i,1] = haskey(labels, "__LABEL_STATISTIC_P_KP__") ? labels["__LABEL_STATISTIC_P_KP__"] : renderSettings.label_statistic_p_kp
                for resultIndex = 1:numberOfResults
                    statisticBlock[i,resultIndex+1] = isdefined(rr[resultIndex], :p_kp) ? sprintf1(statisticformat, rr[resultIndex].p_kp) : ""
                end
            elseif regression_statistics[i] == :dof
                statisticBlock[i,1] = haskey(labels, "__LABEL_STATISTIC_DOF__") ? labels["__LABEL_STATISTIC_DOF__"] : renderSettings.label_statistic_dof
                for resultIndex = 1:numberOfResults
                    statisticBlock[i,resultIndex+1] = isdefined(rr[resultIndex], :dof_residual) ? sprintf1("%i",rr[resultIndex].dof_residual) : ""
                end
            end

        end
    else
        print_statistics_block = false
    end

    # construct alignment string:
    align = "l" * ("r" ^ numberOfResults)

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

    render(outstream, tab , align, renderSettings )

    # if we're writing to a file, close it
    if renderSettings.outfile != ""
        close(outstream)
    else # else print the table
        println(Compat.String(take!(copy(outstream))))
    end

end
