
# render a block of a RegressionTable
function render(io::IO, block::Array{String, 2}, colWidths::Vector{Int64}, align::String, settings::RenderSettings = asciiSettings; isHeader::Bool = false)

    c = size(block,2)

    if length(colWidths) != c
        error("colWidths has invalid length.")
    end
    if length(align) != c
        error("align string has invalid length.")
    end

    # print the whole thing
    for row = 1:size(block,1)
        s = settings.linestart
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
                # if the printstring is too long, so be it
                l = max(l,0)
                r = max(r,0)
                s = s * (" " ^ l) * printstring * (" " ^ r)
            end
            if col < c
                s = s * (isHeader ? settings.headercolsep : settings.colsep)
            end
        end
        s = s * settings.linebreak
        println(io, s)
    end

end


# render a whole table
function render(io::IO, tab::RegressionTable, align::String, settings::RenderSettings)

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
    headerLabels = Vector{String}(undef,0)
    headerWidths = Vector{Int64}(undef,0)
    headerCellStartEnd = Vector{Vector{Int64}}(undef,0)
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
                headerWidths[end] += length(settings.headercolsep) + colWidths[rIndex]
                headerCellStartEnd[end][2] += 1
            else
                push!(headerLabels, tab.header[1,rIndex])
                push!(headerWidths, colWidths[rIndex])
                push!(headerCellStartEnd, [rIndex, rIndex])
            end
        end
    end
    # second line
    headerArray = Array{String}(undef,1,length(headerLabels))
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
        secondRow = Array{String}(undef,1,length(headerLabels))
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
    render(io, headerArray, headerWidths, ("c" ^ size(headerArray,2)), settings, isHeader=true)
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
