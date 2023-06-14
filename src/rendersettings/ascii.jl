function total_length(tab, r=1:size(tab, 2), widths=colwidths(tab), sep=colsep(tab))
    sum(widths[r]) + (length(r)-1) * length(sep)
end

encapsulateRegressand(::AbstractAscii, s, args...) = "$s"
tablestart(::AbstractAscii) = ""
tableend(::AbstractAscii) = ""
headerrule(tab::AbstractAscii, l = total_length(tab)) = "-" ^ l
function print_headerrule(io::IO, tab::AbstractAscii, row::HeaderRow)
    for (i, value) in enumerate(row.values)
        if length(first(value)) > 0
            print(io, headerrule(tab, total_length(tab, last(value))))
        else
            print(io, " " ^ total_length(tab, last(value)))
        end
        if i < length(row.values)
            print(io, colsep(tab))
        end
    end
    println(io)
end
toprule(tab::AbstractAscii, l = total_length(tab)) = "-" ^ l
midrule(tab::AbstractAscii, l = total_length(tab)) = "-" ^ l
bottomrule(tab::AbstractAscii, l = total_length(tab)) = "-" ^ l
headercolsep(::AbstractAscii) = "   "
colsep(::AbstractAscii) = "   "
linestart(::AbstractAscii) = ""
linebreak(::AbstractAscii) = ""
