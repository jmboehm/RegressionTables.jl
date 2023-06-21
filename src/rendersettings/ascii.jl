abstract type AbstractAscii <: AbstractRenderType end
struct AsciiTable <: AbstractAscii end

full_string(val::Pair, rndr::AbstractAscii) = to_string(rndr, first(val))

function print_row(io::IO, row::DataRow, rndr::AbstractAscii)
    for (i, x) in enumerate(row.data)
        print(
            io,
            make_padding(full_string(x, rndr), row.colwidths[i], row.align[i])
        )
        if i < length(row.data)
            print(io, colsep(rndr))
        end
    end
    println(io)
    if row.print_underlines
        for (i, x) in enumerate(row.data)
            s = isa(x, Pair) ? to_string(rndr, first(x)) : to_string(rndr, x)
            if length(s) > 0
                print(io, headerrule(rndr, row.colwidths[i]))
            else
                print(io, " " ^ row.colwidths[i])
            end
            if i < length(row.data)
                print(io, colsep(rndr))
            end
        end
        println(io)
    end
end

function total_length(tab::RegressionTable, r=1:size(tab, 2), widths=colwidths(tab), sep=colsep(tab))
    sum(widths[r]) + (length(r)-1) * length(sep)
end

encapsulateRegressand(::AbstractAscii, s, args...) = "$s"
tablestart(::AbstractAscii) = ""
tableend(::AbstractAscii) = ""
headerrule(::AbstractAscii, l) = "-" ^ l
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