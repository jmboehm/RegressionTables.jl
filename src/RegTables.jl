__precompile__(true)

module RegTables

    ##############################################################################
    ##
    ## Dependencies
    ##
    ##############################################################################

    #import DataFrames: DataFrame, AbstractDataFrame, ModelMatrix, ModelFrame, Terms, coefnames, Formula, completecases, names!, pool, @formula
    import FixedEffectModels: AbstractRegressionResult, RegressionResult, RegressionResultIV, RegressionResultFE, RegressionResultFEIV

    # order = ["varname_1", "varname_2", ...]

    type RenderSettings
        hline::String   # horizontal line. If character, repeat
        colsep::String  # separator between columns
        linebreak::String   # link break string
    end

    latexSettings = RenderSettings("\hline", " & ", " \\ ")
    asciiSettings = RenderSettings("-", " ", "\n")

    type Regressor
        name::String
        estimate::Float64
        se::Float64
    end
    # type Statistic
    #     label::String


    type AbstractTable
        header::String
        bodies::Vector{Array{String, 2}}
        footer::String

        function AbstractTable(columns::Int64, header::String, bodies::Vector{Array{String, 2}}, footer::String)
            this = new()
            if any([size(body,2) for body in bodies] .!= columns)
                error("Incorrect number of columns in table")
            end
            if (size(bodies,1) == 0 ) || (size(bodies[1],1)==0)
                error("Table must contain at least one body, and at least one row in the first body.")
            end
            this.header = header
            this.bodies = bodies
            this.footer = footer
            return this
        end

    end

    columns(tab::AbstractTable) = size(tab.bodies[1],2)

    type RegressionTable
        numberofcolumns::Int64
        lhsnames::Vector{String} # if one, use for all columns, otherwise separate
        regressors::Vector{Regressor}

        # this contains
        regressorArray::Array{String, 2}
        statisticArrays::Vector{Array{String, 2}}

    end

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
                if align[col] == 'l'
                    s = s * rpad(block[row,col],colWidths[col])
                elseif align[col] == 'r'
                    s = s * lpad(block[row,col],colWidths[col])
                elseif align[col] == 'c'
                    l = iseven(colWidths[col]-length(block[row,col])) ? (colWidths[col]-length(block[row,col]))/2 : (colWidths[col]-length(block[row,col])+1)/2
                    r = iseven(colWidths[col]-length(block[row,col])) ? (colWidths[col]-length(block[row,col]))/2 : (colWidths[col]-length(block[row,col])-1)/2
                    s = s * (" " ^ l) * block[row,col] * (" " ^ r)
                end
                if col < c
                    s = s * settings.colsep
                end
            end
            s = s * settings.linebreak
            println(io, s)
        end

    end

    function render(io::IO, tab::AbstractTable, align::String, settings::RenderSettings)

        c = columns(tab)

        if length(align) != c
            error("align string has invalid length.")
        end

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


        # print the whole thing

        # first the header
        if tab.header == ""
            # don't print anything
        elseif length(tab.footer) == 1
            println(io, tab.header ^ (sum(colWidths) + (columns(tab)-1)*length(settings.colsep)))
        else
            println(io, tab.header)
        end
        for b = 1:size(tab.bodies,1)

            render(io, tab.bodies[b], colWidths, align, settings)

            # if we're not at the last block, print the hline
            if b < size(tab.bodies,1)
                if length(settings.hline)==1
                    # one character, extend over the whole line
                    println(io, settings.hline ^ (sum(colWidths) + (columns(tab)-1)*length(settings.colsep))  )
                else
                    println(io, settings.hline)
                end
            end
        end
        # print the footer
        if tab.footer == ""
            # don't print anything
        elseif length(tab.footer) == 1
            println(io, tab.footer ^ (sum(colWidths) + (columns(tab)-1)*length(settings.colsep)))
        else
            println(io, tab.footer)
        end

    end

    function regtable(rr::AbstractRegressionResult...; lhslabel::String = "")

        println("Showing regtable... \n")

        for r in rr
            @show r.coef
            @show r.vcov
        end

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
