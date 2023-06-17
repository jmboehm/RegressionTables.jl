function total_length(tab::RegressionTable, r=1:size(tab, 2), widths=colwidths(tab), sep=colsep(tab))
    sum(widths[r]) + (length(r)-1) * length(sep)
end

encapsulateRegressand(::AbstractAscii, s, args...) = "$s"
tablestart(::AbstractAscii) = ""
tableend(::AbstractAscii) = ""
headerrule(::AbstractAscii, l) = "-" ^ l
function print_headerrule(io::IO, rndr::AbstractAscii, row::HeaderRow)
    for (i, value) in enumerate(row.values)
        if length(first(value)) > 0
            print(io, headerrule(rndr, total_length(row.parent, last(value))))
        else
            print(io, " " ^ total_length(row.parent, last(value)))
        end
        if i < length(row.values)
            print(io, colsep(rndr))
        end
    end
    println(io)
end
toprule(::AbstractAscii, l) = "-" ^ l
midrule(::AbstractAscii, l) = "-" ^ l
bottomrule(::AbstractAscii, l) = "-" ^ l
headercolsep(::AbstractAscii) = "   "
colsep(::AbstractAscii) = "   "
linestart(::AbstractAscii) = ""
linebreak(::AbstractAscii) = ""

# functions to make multiple dispatch easier
encapsulateRegressand(tab::RegressionTable{<:AbstractAscii}, s, args...) = encapsulateRegressand(tab.render, s, args...)
tablestart(tab::RegressionTable{<:AbstractAscii}) = tablestart(tab.render)
tableend(tab::RegressionTable{<:AbstractAscii}) = tableend(tab.render)
headerrule(tab::RegressionTable{<:AbstractAscii}) = headerrule(tab.render, total_length(tab))
toprule(tab::RegressionTable{<:AbstractAscii}) = toprule(tab.render, total_length(tab))
midrule(tab::RegressionTable{<:AbstractAscii}) = midrule(tab.render, total_length(tab))
bottomrule(tab::RegressionTable{<:AbstractAscii}) = bottomrule(tab.render, total_length(tab))
headercolsep(tab::RegressionTable{<:AbstractAscii}) = headercolsep(tab.render)
colsep(tab::RegressionTable{<:AbstractAscii}) = colsep(tab.render)
linestart(tab::RegressionTable{<:AbstractAscii}) = linestart(tab.render)
linebreak(tab::RegressionTable{<:AbstractAscii}) = linebreak(tab.render)
print_headerrule(io::IO, tab::RegressionTable{<:AbstractAscii}, row::HeaderRow) = print_headerrule(io, tab.render, row)