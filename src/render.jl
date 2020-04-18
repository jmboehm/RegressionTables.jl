
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

    # construct, but not print, the header
    colWidths = column_widths(tab, align)
    adjusted = true
    
    global header_vec = []
    
    while adjusted
      header_vec = map(1:size(tab.header, 1)) do i
        h = header(tab, tab.header[i:i,:], settings, colWidths)
        @unpack adjusted, h = adjust_widths!(colWidths, h, settings)
        @unpack headerArray, hr = headerrule(h, settings)

        (h=h, hr=hr, headerArray=headerArray)
      end
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
    map(header_vec) do head
        @unpack headerArray, h, hr = head
        render(io, headerArray, h.headerWidths, ("c" ^ size(headerArray,2)), settings, isHeader=true)
        if hr.print_headerrule_separately
            println(io, hr.headerrule)
        end
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
