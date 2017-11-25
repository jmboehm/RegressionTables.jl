__precompile__(true)

module RegressionTables

    ##############################################################################
    ##
    #   TODO:
    #
    #   FUNCTIONALITY:
    #   - Implement labels for yname, coefnames
    #   - Generic replacement dictionary for labels
    #   - For statistics, check if statistic exists (depends on RegressionResult)
    #   - More statistics (F)
    #   - Fixed effect for FE regressions
    #   - t-test based on DOF instead of DOF->infty
    #
    #   TECHNICAL:
    #   - Rewrite table cell/row formats using an encapsulating function instead
    #      of strings (which would allow HTML <td></td>)
    #   - Formatting option: string (or function) for spacer rows
    #
    ##
    ##############################################################################

# TODO:
#   - Implement labels for yname, coefnames
#   - For statistics, check if statistic exists (depends on RegressionResult)
#   - Have option minimum column width (to avoid titles being truncated)

    ##############################################################################
    ##
    ## Dependencies
    ##
    ##############################################################################

    #import DataFrames: DataFrame, AbstractDataFrame, ModelMatrix, ModelFrame, Terms, coefnames, Formula, completecases, names!, pool, @formula
    import FixedEffectModels: AbstractRegressionResult, RegressionResult, RegressionResultIV, RegressionResultFE, RegressionResultFEIV
    import Formatting: sprintf1

    # order = ["varname_1", "varname_2", ...]

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
        foutfile = outfile
        encapsulateRegressand = latexRegressandTransform
        header = latexTableHeader
        footer = latexTableFooter
        return RenderSettings(toprule, midrule, bottomrule, headerrule, colsep, linebreak, foutfile, encapsulateRegressand, header, footer)
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
        foutfile = outfile
        encapsulateRegressand = asciiRegressandTransform
        header = asciiTableHeader
        footer = asciiTableFooter
        return RenderSettings(toprule, midrule, bottomrule, headerrule, colsep, linebreak, foutfile, encapsulateRegressand, header, footer)
    end

    # * 5%, ** 1%, *** 0.1%
    # TODO this should be made exact
    function default_estim_decoration(s::String, estimate::Float64, se::Float64)
        t = abs(estimate/se)
        if (t < 1.645)
            return "$s"
        elseif (t < 1.95996)
            return "$s"
        elseif (t < 2.57583)
            return "$s*"
        elseif (t < 3.29053)
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

    columns(tab::AbstractTable) = size(tab.bodies[1],2)

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
            #elseif align[col] == 'c'
            #    colWidths[colIndex] = maximum(search.([b[r,c] for b in tab.bodies for r=1:size(b,1) ],'.') ) - 1 +
            #                            maximum(length.([b[r,c] for b in tab.bodies for r=1:size(b,1) ]) - search.([b[r,c] for b in tab.bodies for r=1:size(b,1) ],'.') )
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
        # second line -- this needs to be improved TODO
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

    # estimformat: string that describes the format of the estimate. Defaults to "%0.3f".
    # statisticformat: string that describes the format of the number below the estimate (se/t). Defaults to "%0.4f".

    # Label option:
    #   labels::Dict is a Dict that contains for each variable (string) a display label. If not found, defaults to variable name

    # number_regressions: bool that determines whether numbers should be shown above each regression column. defaults to true.
    # number_regressions_decoration: function that takes the column number and returns the formatted string. defaults to "($i)".

    # Options for statistics:
    #   :nobs Number of Observations
    #   :r2 R^2
    #   :f  F-Statistic
    #   :dof Degrees of Freedom (not yet implemented)

    # settings::RenderSettings

    function regtable(rr::AbstractRegressionResult...;
        lhs_labels::Vector{String} = Vector{String}(),
        regressors::Vector{String} = Vector{String}(),
        estimformat::String = "%0.3f",
        estim_decoration::Function = default_estim_decoration,
        statisticformat::String = "%0.3f",
        below_statistic::Symbol = :se,
        below_decoration::Function = s::String -> "($s)",
        regression_statistics::Vector{Symbol} = [:nobs, :r2],
        regression_statistics_label::Vector{String} = Vector{String}(0),
        number_regressions::Bool = true,
        number_regressions_decoration::Function = i::Int64 -> "($i)",
        renderSettings::RenderSettings = asciiOutput()
        )

        numberOfResults = size(rr,1)
        println("Found $numberOfResults regression results.")

        # Check options
        #
        # regression_statistics_label:
        if (length(regression_statistics_label)>0) &&
            (length(regression_statistics_label) != length(regression_statistics))
            error("Argument regression_statistics_label needs to have
                either zero length or the same length as regression_statistics.")
        end
        # lhs_labels
        if (length(lhs_labels)>0) &&
            (length(lhs_labels) != numberOfResults)
            error("Argument lhs_labels needs to have either zero length or the same length as the number of regressions.")
        end

        # Create an AbstractTable from the regression results

        #println("Showing regtable... \n")

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
                estimateLine[1,1] = regressor
                # add to estimateBlock
                estimateBlock = [estimateBlock; estimateLine]
            end
        end

        # Regressand block
        #   needs to be separately rendered
        regressandBlock = fill("", 1, numberOfResults+1)
        for rIndex = 1:numberOfResults
            regressandBlock[1,rIndex+1] = (length(lhs_labels)>0 ? lhs_labels[rIndex] : rr[rIndex].yname)
        end

        # Regression numbering block (if we do it)
        if number_regressions
            regressionNumberBlock = fill("", 1, numberOfResults + 1)
            for rIndex = 1:numberOfResults
                regressionNumberBlock[1,rIndex+1] = number_regressions_decoration(rIndex)
            end
        end

        if length(regression_statistics)>0
            # we have a statistics block (N, R^2, etc)

            # one line for each statistic
            statisticBlock = fill("", length(regression_statistics), numberOfResults+1)
            for i = 1:length(regression_statistics)
                if regression_statistics[i] == :nobs
                    statisticBlock[i,1] = length(regression_statistics_label)>0 ? regression_statistics_label[i] : "N"
                    for resultIndex = 1:numberOfResults
                        statisticBlock[i,resultIndex+1] = sprintf1("%i",rr[resultIndex].nobs)
                    end
                elseif regression_statistics[i] == :r2
                    statisticBlock[i,1] = length(regression_statistics_label)>0 ? regression_statistics_label[i] : "R2"
                    for resultIndex = 1:numberOfResults
                        statisticBlock[i,resultIndex+1] = sprintf1(statisticformat, rr[resultIndex].r2)
                    end
                elseif regression_statistics[i] == :f
                    statisticBlock[i,1] = length(regression_statistics_label)>0 ? regression_statistics_label[i] : "F"
                    for resultIndex = 1:numberOfResults
                        statisticBlock[i,resultIndex+1] = sprintf1(statisticformat, rr[resultIndex].F)
                    end
                end
            end
        else

        end

        # construct alignment string:
        align = "l" * ("r" ^ numberOfResults)

        bodyBlocks = [estimateBlock,statisticBlock]

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

        return estimateBlock, statisticBlock

        # for r in rr
        #     @show r.coef
        #     @show r.vcov
        # end

        # coef(x::AbstractRegressionResult) = x.coef
        # coefnames(x::AbstractRegressionResult) = x.coefnames
        # vcov(x::AbstractRegressionResult) = x.vcov
        # nobs(x::AbstractRegressionResult) = x.nobs
        # df_residual(x::AbstractRegressionResult) = x.df_residual
        # function confint(x::AbstractRegressionResult)
        #     scale = quantile(TDist(x.df_residual), 1 - (1-0.95)/2)
        #     se = stderr(x)
        #     hcat(x.coef -  scale * se, x.coef + scale * se)
        # end

        #@show rr

    end


end
