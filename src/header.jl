import RegressionTables: columns

align_table(tab) = "l" * ("r" ^ (columns(tab) - 1))

function column_widths(tab, align)
    n_columns = columns(tab)
    
    if length(align) != n_columns
        error("align string has invalid length.")
    end

    # construct column width, first from the maximum of the bodies' column widths.
    colWidths = zeros(Int64, n_columns)
    for colIndex = 1:n_columns
        if (align[colIndex] == 'l') || (align[colIndex] == 'r') || (align[colIndex] == 'c')
            colWidths[colIndex] = maximum([length(b[r,colIndex]) for b in tab.bodies for r=1:size(b,1) ])
        else
            error("Invalid character in align string. Only 'l', 'r', 'c' are allowed.")
        end
    end

    colWidths
end

function header(tab, header, settings, colWidths)
  # header
  headerLabels = Vector{String}(undef,0)
  headerWidths = Vector{Int64}(undef,0)
  headerCellStartEnd = Vector{Vector{Int64}}(undef,0)
  # first column is empty (top left)
  push!(headerLabels, "")
  push!(headerWidths, colWidths[1])
  push!(headerCellStartEnd, [1,1])
  # first regression result
  push!(headerLabels, header[1,2])
  push!(headerWidths, colWidths[2])
  push!(headerCellStartEnd, [2,2])
  if columns(tab)>2
      for rIndex = 3:size(header,2)
          if header[1,rIndex] == header[1,rIndex-1]
              headerWidths[end] += length(settings.headercolsep) + colWidths[rIndex]
              headerCellStartEnd[end][2] += 1
          else
              push!(headerLabels, header[1,rIndex])
              push!(headerWidths, colWidths[rIndex])
              push!(headerCellStartEnd, [rIndex, rIndex])
          end
      end
  end
  
  headerArray = Array{String}(undef,1,length(headerLabels))
  headerArray[1,1] = ""
  for i = 2:size(headerArray,2)
      headerArray[1,i] = settings.encapsulateRegressand(headerLabels[i],headerCellStartEnd[i][1],headerCellStartEnd[i][2] )
  end
  
  (headerArray=headerArray, headerLabels=headerLabels, headerWidths=headerWidths, headerCellStartEnd=headerCellStartEnd)
end

"""
    now it could be that a columns of the header is wider than the colWidth of the bodies.
    in that case, make the last column of the bodies wider.
"""
function adjust_widths!(colWidths, header, settings)
    @unpack headerArray, headerCellStartEnd, headerLabels, headerWidths = header

    for i = 2:size(headerArray,2)
        totalWidth = sum([colWidths[cind] for cind in headerCellStartEnd[i][1] : headerCellStartEnd[i][2]]) + length(settings.colsep)*(headerCellStartEnd[i][2] - headerCellStartEnd[i][1])
        if length(headerArray[1,i])>totalWidth
            # extend width of cells
            colWidths[headerCellStartEnd[i][2]] +=  (length(headerArray[1,i])-totalWidth)
            headerWidths[i] += (length(headerArray[1,i])-totalWidth)
        end
    end
    (headerArray=headerArray, headerLabels=headerLabels, headerWidths=headerWidths, headerCellStartEnd=headerCellStartEnd)
end

# distinguish two cases:
#   if headerrule gives a string of length one, put into table, and repeat the string
function headerrule(header, settings)
    @unpack headerArray, headerCellStartEnd, headerLabels, headerWidths = header
    headerArray = copy(headerArray)
    
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
    (headerArray = headerArray, 
     hr = (headerrule=hr, print_headerrule_separately=print_headerrule_separately))
end