"""
    abstract type AbstractAscii <: AbstractRenderType end

The abstract type for most plain text rendering. Printing is defined using the `AbstractAscii`, so
new tables (with different defaults) can be created by subtyping `AbstractAscii` with minimal effort.
"""
abstract type AbstractAscii <: AbstractRenderType end
struct AsciiTable <: AbstractAscii end

(::Type{T})(val::Pair; args...) where {T<:AbstractAscii} = T(first(val); args...)

function Base.print(io::IO, row::DataRow{T}) where {T<:AbstractAscii}
    print(io, linestart(T()))# in case we want to add something before the line
    for (i, x) in enumerate(row.data)
        print(
            io,
            make_padding(T(x), row.colwidths[i], row.align[i])
        )
        if i < length(row.data)
            print(io, colsep(T()))
        end
    end
    # do not print new line here, let the caller do it
    if any(row.print_underlines)
        println(io)# if print underlines, then need new line
        for (i, x) in enumerate(row.data)
            s = isa(x, Pair) ? T(first(x)) : T(x)
            if length(s) > 0 && row.print_underlines[i]
                print(io, headerrule(T(), row.colwidths[i]))
            else
                print(io, " " ^ row.colwidths[i])
            end
            if i < length(row.data)
                print(io, colsep(T()))
            end
        end
        
    end
end

function total_length(tab::RegressionTable, r=1:size(tab, 2), widths=colwidths(tab), sep=colsep(tab))
    sum(widths[r]) + (length(r)-1) * length(sep)
end

tablestart(::AbstractAscii) = ""
tableend(::AbstractAscii) = ""
headerrule(::AbstractAscii, l) = "-" ^ l
toprule(::AbstractAscii, l) = "-" ^ l
midrule(::AbstractAscii, l) = "-" ^ l
bottomrule(::AbstractAscii, l) = "-" ^ l
colsep(::AbstractAscii) = "   "
linestart(::AbstractAscii) = ""


# functions to make multiple dispatch easier
tablestart(tab::RegressionTable{<:AbstractAscii}) = tablestart(tab.render)
tableend(tab::RegressionTable{<:AbstractAscii}) = tableend(tab.render)
headerrule(tab::RegressionTable{<:AbstractAscii}) = headerrule(tab.render, total_length(tab))
toprule(tab::RegressionTable{<:AbstractAscii}) = toprule(tab.render, total_length(tab))
midrule(tab::RegressionTable{<:AbstractAscii}) = midrule(tab.render, total_length(tab))
bottomrule(tab::RegressionTable{<:AbstractAscii}) = bottomrule(tab.render, total_length(tab))
headercolsep(tab::RegressionTable{<:AbstractAscii}) = headercolsep(tab.render)
colsep(tab::RegressionTable{<:AbstractAscii}) = colsep(tab.render)
linestart(tab::RegressionTable{<:AbstractAscii}) = linestart(tab.render)
