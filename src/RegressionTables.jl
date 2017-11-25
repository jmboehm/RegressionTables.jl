__precompile__(true)

module RegressionTables

    ##############################################################################
    ##
    #   TODO:
    #
    #   FUNCTIONALITY: (asterisk means priority)
    #   - More statistics (DOF)
    #   * t-test based on DOF instead of DOF->infty
    #
    #   TECHNICAL:
    #   - Rewrite table cell/row formats using an encapsulating function instead
    #      of strings (which would allow HTML <td></td>)
    #   - Formatting option: string (or function) for spacer rows
    #
    ##
    ##############################################################################


    ##############################################################################
    ##
    ## Dependencies
    ##
    ##############################################################################

    #import DataFrames: DataFrame, AbstractDataFrame, ModelMatrix, ModelFrame, Terms, coefnames, Formula, completecases, names!, pool, @formula
    import Distributions: TDist, ccdf, FDist, Chisq, AliasTable, Categorical
    import FixedEffectModels: AbstractRegressionResult, RegressionResult, RegressionResultIV, RegressionResultFE, RegressionResultFEIV
    import Formatting: sprintf1

    export regtable, latexOutput, asciiOutput, RenderSettings

    struct RenderSettings

        # horizontal line. if character, repeat.
        toprule::String
        midrule::String
        bottomrule::String

        headerrule::Function  # Function that takes the headerCellStartEnd array and returns a
                                # sting that describes the text line below the header titles
                                # if it's one single character, it's put into a table format and repeated (e.g. "-" for ascii)

        colsep::String  # separator between columns
        linebreak::String   # link break string

        label_fe_yes::String    # what the FE block prints if the FE is present. override with __LABEL_FE_YES__ in 'label' argument
        label_fe_no::String    # what the FE block prints if the FE is not present. override with __LABEL_FE_NO__ in 'label' argument

        label_statistic_n::String # label for number of observations. override with __LABEL_STATISTIC_N__ in 'label' argument
        label_statistic_r2::String # label for R^2. override with __LABEL_STATISTIC_R2__ in 'label' argument
        label_statistic_r2_a::String # label for adjusted R^2. override with __LABEL_STATISTIC_R2_A__
        label_statistic_r2_within::String # label for within-R^2. override with __LABEL_STATISTIC_R2_WITHIN__
        label_statistic_f::String # label for F-Stat. override with __LABEL_STATISTIC_F__ in 'label' argument
        label_statistic_p::String # label for F-test p value. override with __LABEL_STATISTIC_P__
        label_statistic_f_kp::String # label for first-stage F statistic override with __LABEL_STATISTIC_F_KP__
        label_statistic_p_kp::String # label for first-stage F-stat p value override with __LABEL_STATISTIC_P_KP__

        outfile::String    # file to print output into.
                           # if empty, print to STDOUT.

        encapsulateRegressand::Function     # function that takes a string and
                                            # min and max column index and returns
                                            # a formatted string

        header::Function                    # function that return the header string
        footer::Function                    # function that returns the footer string
                                            # both should take the number of results and align string as arguments



    end


    function latexOutput(outfile::String = "")
        latexRegressandTransform(s::String,colmin::Int64,colmax::Int64) = "\\multicolumn{$(colmax-colmin+1)}{c}{$s}"
        latexTableHeader(numberOfResults::Int64, align::String) = "\\begin{tabular}{$align}"
        latexTableFooter(numberOfResults::Int64, align::String) = "\\end{tabular}"
        function latexHeaderRule(headerCellStartEnd::Vector{Vector{Int64}})
            if length(headerCellStartEnd)<2
                error("Invalid headerCellStartEnd: need to have at least two columns.")
            end
            s = ""
            for i in headerCellStartEnd[2:end]
                s = s * "\\cmidrule(lr){$(i[1])-$(i[2])}" * " "
            end
            return s
        end
        toprule = "\\toprule"
        midrule = "\\midrule"
        bottomrule = "\\bottomrule"
        headerrule = latexHeaderRule
        colsep = " & "
        linebreak = " \\\\ "

        label_fe_yes = "Yes"
        label_fe_no = ""

        label_statistic_n = "\$N\$"
        label_statistic_r2 = "\$R^2\$"
        label_statistic_f = "\$F\$"
        label_statistic_r2_a = "Adjusted \$R^2\$"
        label_statistic_r2_within = "Within-\$R^2\$"
        label_statistic_p = "\$F\$-test \$p\$ value"
        label_statistic_f_kp = "First-stage \$F\$ statistic"
        label_statistic_p_kp = "First-stage \$p\$ value"

        foutfile = outfile
        encapsulateRegressand = latexRegressandTransform
        header = latexTableHeader
        footer = latexTableFooter
        return RenderSettings(toprule, midrule, bottomrule, headerrule, colsep, linebreak, label_fe_yes, label_fe_no, label_statistic_n, label_statistic_r2, label_statistic_r2_a, label_statistic_r2_within, label_statistic_f, label_statistic_p, label_statistic_f_kp, label_statistic_p_kp, foutfile, encapsulateRegressand, header, footer)
    end
    function asciiOutput(outfile::String = "")
        asciiRegressandTransform(s::String,colmin::Int64,colmax::Int64) = "$s"
        asciiTableHeader(numberOfResults::Int64, align::String) = ""
        asciiTableFooter(numberOfResults::Int64, align::String) = ""
        asciiHeaderRule(headerCellStartEnd::Vector{Vector{Int64}}) = "-"
        toprule = "-"
        midrule = "-"
        bottomrule = "-"
        headerrule = asciiHeaderRule
        colsep = "   "
        linebreak = ""

        label_fe_yes = "Yes"
        label_fe_no = ""

        label_statistic_n = "N"
        label_statistic_r2 = "R2"
        label_statistic_r2_a = "Adjusted R2"
        label_statistic_r2_within = "Within-R2"
        label_statistic_f = "F"
        label_statistic_p = "F-test p value"
        label_statistic_f_kp = "First-stage F statistic"
        label_statistic_p_kp = "First-stage p value"

        foutfile = outfile
        encapsulateRegressand = asciiRegressandTransform
        header = asciiTableHeader
        footer = asciiTableFooter
        return RenderSettings(toprule, midrule, bottomrule, headerrule, colsep, linebreak, label_fe_yes, label_fe_no, label_statistic_n, label_statistic_r2, label_statistic_r2_a, label_statistic_r2_within, label_statistic_f, label_statistic_p, label_statistic_f_kp, label_statistic_p_kp, foutfile, encapsulateRegressand, header, footer)
    end

    # * 5%, ** 1%, *** 0.1%
    function default_estim_decoration(s::String, pval::Float64)
        if pval<0.0
            error("p value needs to be nonnegative.")
        if (pval > 0.1)
            return "$s"
        elseif (pval > 0.05)
            return "$s"
        elseif (pval > 0.01)
            return "$s*"
        elseif (pval > 0.001)
            return "$s**"
        else
            return "$s***"
        end
    end

    type AbstractTable
        headerString::String
        header::Array{String, 2}
        bodies::Vector{Array{String, 2}}
        footerString::String

        function AbstractTable(columns::Int64, headerString::String, header::Array{String, 2}, bodies::Vector{Array{String, 2}}, footerString::String)
            this = new()
            if any([size(body,2) for body in bodies] .!= columns)
                error("Incorrect number of columns in table")
            end
            if size(header, 2) != columns
                error("Header has wrong number of columns")
            end
            if (size(bodies,1) == 0 ) || (size(bodies[1],1)==0)
                error("Table must contain at least one body, and at least one row in the first body.")
            end
            this.headerString = headerString
            this.header = header
            this.bodies = bodies
            this.footerString = footerString
            return this
        end

    end

    # some helper functions
    columns(tab::AbstractTable) = size(tab.bodies[1],2)

    # isFERegressionResult
    isFERegressionResult(r::AbstractRegressionResult) = isa(r,RegressionResultFE) || isa(r,RegressionResultFEIV)


    # type RegressionTable
    #     numberofcolumns::Int64
    #     lhsnames::Vector{String} # if one, use for all columns, otherwise separate
    #     regressors::Vector{Regressor}
    #
    #     # this contains
    #     regressorArray::Array{String, 2}
    #     statisticArrays::Vector{Array{String, 2}}
    #
    # end

    # render a block of an AbstractTable
    function render(io::IO, block::Array{String, 2}, colWidths::Vector{Int64}, align::String, settings::RenderSettings = asciiSettings)

        #println(io, "Rendering block, colwidths $colWidths align $align \n")

        c = size(block,2)

        if length(colWidths) != c
            error("colWidths has invalid length.")
        end
        if length(align) != c
            error("align string has invalid length.")
        end

        # print the whole thing
        for row = 1:size(block,1)
            s = ""
            for col = 1:c
                # if the string is too long, truncate it
                # (this sometimes happens with column headers)
                # if length(block[row,col]) > colWidths[col]
                #     printstring = block[row,col][1:colWidths[col]]
                # else
                # end
                printstring = block[row,col]

                if align[col] == 'l'
                    s = s * rpad(printstring,colWidths[col])
                elseif align[col] == 'r'
                    s = s * lpad(printstring,colWidths[col])
                elseif align[col] == 'c'
                    l = iseven(colWidths[col]-length(printstring)) ? Int64((colWidths[col]-length(printstring))/2) : Int64((colWidths[col]-length(printstring)+1)/2)
                    r = iseven(colWidths[col]-length(printstring)) ? Int64((colWidths[col]-length(printstring))/2) : Int64((colWidths[col]-length(printstring)-1)/2)
                    s = s * (" " ^ l) * printstring * (" " ^ r)
                end
                if col < c
                    s = s * settings.colsep
                end
            end
            s = s * settings.linebreak
            println(io, s)
        end

    end


    # render a whole table
    function render(io::IO, tab::AbstractTable, align::String, settings::RenderSettings)

        c = columns(tab)

        if length(align) != c
            error("align string has invalid length.")
        end

        # construct column width, first from the maximum of the bodies' column widths.
        colWidths = zeros(Int64, c)
        for colIndex = 1:c
            if (align[colIndex] == 'l') || (align[colIndex] == 'r') || (align[colIndex] == 'c')
                colWidths[colIndex] = maximum([length(b[r,colIndex]) for b in tab.bodies for r=1:size(b,1) ])
            else
                error("Invalid character in align string. Only 'l', 'r', 'c' are allowed.")
            end
        end

        # construct, but not print, the header
        # header
        headerLabels = Vector{String}(0)
        headerWidths = Vector{Int64}(0)
        headerCellStartEnd = Vector{Vector{Int64}}(0)
        # first column is empty (top left)
        push!(headerLabels, "")
        push!(headerWidths, colWidths[1])
        push!(headerCellStartEnd, [1,1])
        # first regression result
        push!(headerLabels, tab.header[1,2])
        push!(headerWidths, colWidths[2])
        push!(headerCellStartEnd, [2,2])
        if columns(tab)>2
            for rIndex = 3:size(tab.header,2)
                if tab.header[1,rIndex] == tab.header[1,rIndex-1]
                    headerWidths[end] += length(settings.colsep) + colWidths[rIndex]
                    headerCellStartEnd[end][2] += 1
                else
                    push!(headerLabels, tab.header[1,rIndex])
                    push!(headerWidths, colWidths[rIndex])
                    push!(headerCellStartEnd, [rIndex, rIndex])
                end
            end
        end
        # second line
        headerArray = Array{String}(1,length(headerLabels))
        headerArray[1,1] = ""
        for i = 2:size(headerArray,2)
            headerArray[1,i] = settings.encapsulateRegressand(headerLabels[i],headerCellStartEnd[i][1],headerCellStartEnd[i][2] )
        end
        # now it could be that a columns of the header is wider than the colWidth of the bodies.
        # in that case, make the last column of the bodies wider.
        for i = 2:size(headerArray,2)
            totalWidth = sum([colWidths[cind] for cind in headerCellStartEnd[i][1] : headerCellStartEnd[i][2]]) + length(settings.colsep)*(headerCellStartEnd[i][2] - headerCellStartEnd[i][1])
            if length(headerArray[1,i])>totalWidth
                # extend width of cells
                colWidths[headerCellStartEnd[i][2]] +=  (length(headerArray[1,i])-totalWidth)
                headerWidths[i] += (length(headerArray[1,i])-totalWidth)
            end
        end
        # second line
        # distinguish two cases:
        #   if headerrule gives a string of length one, put into table, and repeat the string
        hr = settings.headerrule(headerCellStartEnd)
        if length(hr) == 1
            secondRow = Array{String}(1,length(headerLabels))
            secondRow[1,1] = ""
            for i = 2:size(secondRow,2)
                secondRow[1,i] = (length(settings.midrule) == 1 ? settings.midrule ^ headerWidths[i] : settings.midrule)
            end
            headerArray = [headerArray; secondRow]
            print_headerrule_separately = false
        else
            print_headerrule_separately = true
        end

        # START RENDERING

        # header
        println(io, settings.header(c,align))

        # headerString
        # if tab.headerString == ""
        #     # don't print anything
        # elseif length(tab.headerString) == 1
        #     println(io, tab.headerString ^ (sum(colWidths) + (columns(tab)-1)*length(settings.colsep)))
        # else
        #     println(io, tab.headerString)
        # end

        # print toprule
        if length(settings.toprule)==1
            # one character, extend over the whole line
            println(io, settings.toprule ^ (sum(colWidths) + (columns(tab)-1)*length(settings.colsep))  )
        else
            println(io, settings.toprule)
        end

        # header
        render(io, headerArray, headerWidths, ("c" ^ size(headerArray,2)), settings)
        if print_headerrule_separately
            println(io, hr)
        end

        # bodies
        for b = 1:size(tab.bodies,1)

            render(io, tab.bodies[b], colWidths, align, settings)

            # if we're not at the last block, print the midrule
            if b < size(tab.bodies,1)
                if length(settings.midrule)==1
                    # one character, extend over the whole line
                    println(io, settings.midrule ^ (sum(colWidths) + (columns(tab)-1)*length(settings.colsep))  )
                else
                    println(io, settings.midrule)
                end
            end
        end

        # print bottomrule
        if length(settings.bottomrule)==1
            # one character, extend over the whole line
            println(io, settings.bottomrule ^ (sum(colWidths) + (columns(tab)-1)*length(settings.colsep))  )
        else
            println(io, settings.bottomrule)
        end

        # footerString
        # if tab.footerString == ""
        #     # don't print anything
        # elseif length(tab.footerString) == 1
        #     println(io, tab.footerString ^ (sum(colWidths) + (columns(tab)-1)*length(settings.colsep)))
        # else
        #     println(io, tab.footerString)
        # end


        # footer
        println(io, settings.footer(c,align))

    end

    # Options for expression below estimates
    #   below_statistic: either :blank, :se, or :tstat. Default is :se.
    #   below_decoration: function d(s::String) -> String, by default "0.1" -> "(0.1)"
    #

    # regressors::Vector{String} is the vector of regressor names that should be shown, in that order.
    #   Defaults to an empty vector, in which case all regressors will be shown.

    # fixedeffects::Vector{String} is the vector of FE names that should be shown, in that order.
    #   Defaults to an empty vector, in which case all FE's will be shown.

    # estimformat: string that describes the format of the estimate. Defaults to "%0.3f".
    # statisticformat: string that describes the format of the number below the estimate (se/t). Defaults to "%0.4f".

    # Label option:
    #   labels::Dict is a Dict that contains for each variable (string) a display label. If not found, defaults to variable name

    # number_regressions: bool that determines whether numbers should be shown above each regression column. defaults to true.
    # number_regressions_decoration: function that takes the column number and returns the formatted string. defaults to "($i)".

    # print_fe_section: print a section showing fixed effects (if there are FE regressions). Defaults to true.

    # regression_statistics: Symbol vector that contains statistics to show.
    # Options for statistics:
    #   :nobs Number of Observations
    #   :r2 R^2
    #   :r2_a R^2 adjusted
    #   :r2_within R^2 within
    #   :f F-Statistic
    #   :p p-value for F-stat
    #   :f_kp First stage F-stat (Kleinbergen-Paap)
    #   :p_kp p-value for first stage F-stat
    #   :dof Degrees of Freedom (not yet implemented)

    # settings::RenderSettings

    function regtable(rr::AbstractRegressionResult...;
        regressors::Vector{String} = Vector{String}(),
        fixedeffects::Vector{String} = Vector{String}(),
        labels::Dict{String,String} = Dict{String,String}(),
        estimformat::String = "%0.3f",
        estim_decoration::Function = default_estim_decoration,
        statisticformat::String = "%0.3f",
        below_statistic::Symbol = :se,
        below_decoration::Function = s::String -> "($s)",
        regression_statistics::Vector{Symbol} = [:nobs, :r2],
        number_regressions::Bool = true,
        number_regressions_decoration::Function = i::Int64 -> "($i)",
        print_fe_section = true,
        renderSettings::RenderSettings = asciiOutput()
        )

        numberOfResults = size(rr,1)
        #println("Found $numberOfResults regression results.")

        # Create an AbstractTable from the regression results

        # ordering of regressors:
        if length(regressors) == 0
            # construct default ordering: from ordering in regressions (like in Stata)
            regressorList = Vector{String}()
            for r in rr # AbstractRegressionResult
                for regressorIndex = 1:length(r.coefnames)
                    if !(any(regressorList .== r.coefnames[regressorIndex]))
                        # add to list
                        push!(regressorList, r.coefnames[regressorIndex])
                    end
                end
            end
        else
            # take the list of regressors from the argument
            regressorList = regressors
        end

        # for each regressor, check each regression result, calculate statistic, and construct block
        estimateBlock = Array{String}(0,numberOfResults+1)
        for regressor in regressorList
            estimateLine = fill("", 2, numberOfResults+1)
            for resultIndex = 1:numberOfResults
                index = find(regressor .== rr[resultIndex].coefnames)
                if !isempty(index)
                    estimateLine[1,resultIndex+1] = estim_decoration(sprintf1(estimformat,rr[resultIndex].coef[index[1]]),rr[resultIndex].coef[index[1]],sqrt(rr[resultIndex].vcov[index[1],index[1]]))
                    if below_statistic == :tstat
                        s = sprintf1(statisticformat, rr[resultIndex].coef[index[1]]/sqrt(rr[resultIndex].vcov[index[1],index[1]]))
                        estimateLine[2,resultIndex+1] = below_decoration(s)
                    elseif below_statistic == :se
                        s = sprintf1(statisticformat, sqrt(rr[resultIndex].vcov[index[1],index[1]]))
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
            regressandBlock[1,rIndex+1] = haskey(labels,string(rr[rIndex].yname)) ? labels[string(rr[rIndex].yname)] : string(rr[rIndex].yname)
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
            feBlock = Array{String}(0,numberOfResults+1)
            for fe in feList
                feLine = fill("", 1, numberOfResults+1)
                for resultIndex = 1:numberOfResults if isFERegressionResult(rr[resultIndex])
                    index = find(fe .== febyrr[resultIndex])
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

        if length(regression_statistics)>0
            # we have a statistics block (N, R^2, etc)
            print_statistics_block = true

            # one line for each statistic
            statisticBlock = fill("", length(regression_statistics), numberOfResults+1)
            for i = 1:length(regression_statistics)
                if regression_statistics[i] == :nobs
                    statisticBlock[i,1] = haskey(labels, "__LABEL_STATISTIC_N__") ? labels["__LABEL_STATISTIC_N__"] : renderSettings.label_statistic_n
                    for resultIndex = 1:numberOfResults
                        statisticBlock[i,resultIndex+1] = sprintf1("%i",rr[resultIndex].nobs)
                    end
                elseif regression_statistics[i] == :r2
                    statisticBlock[i,1] = haskey(labels, "__LABEL_STATISTIC_R2__") ? labels["__LABEL_STATISTIC_R2__"] : renderSettings.label_statistic_r2
                    for resultIndex = 1:numberOfResults
                        statisticBlock[i,resultIndex+1] = sprintf1(statisticformat, rr[resultIndex].r2)
                    end
                elseif regression_statistics[i] == :r2_a
                    statisticBlock[i,1] = haskey(labels, "__LABEL_STATISTIC_R2_A__") ? labels["__LABEL_STATISTIC_R2_A__"] : renderSettings.label_statistic_r2_a
                    for resultIndex = 1:numberOfResults
                        statisticBlock[i,resultIndex+1] = isdefined(rr[resultIndex], :r2_a) ? sprintf1(statisticformat, rr[resultIndex].r2_a) : ""
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
                end

            end
        else
            print_statistics_block = false
        end

        # construct alignment string:
        align = "l" * ("r" ^ numberOfResults)

        bodyBlocks = [estimateBlock]

        if print_fe_block
            push!(bodyBlocks,feBlock)
        end

        if print_statistics_block
            push!(bodyBlocks,statisticBlock)
        end

        # if we're numbering the regression columns, add a block before the other stuff

        if number_regressions
            insert!(bodyBlocks,1,regressionNumberBlock)
        end

        # create AbstractTable
        tab = AbstractTable(numberOfResults+1, "", regressandBlock, bodyBlocks , "")

        # create output stream
        if renderSettings.outfile == ""
            outstream = STDOUT
        else
            try
                outstream = open(renderSettings.outfile, "w")
            catch ex
                error("Error opening file $(renderSettings.outfile): $(ex.msg)")
            end
        end

        render(outstream, tab , align, renderSettings )

        # if we're writing to a file, close it
        if renderSettings.outfile != ""
            close(outstream)
        end

    end


end
