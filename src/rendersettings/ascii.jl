"""
    abstract type AbstractAscii <: AbstractRenderType end

The abstract type for most plain text rendering. Printing is defined using the `AbstractAscii`, so
new tables (with different defaults) can be created by subtyping `AbstractAscii` with minimal effort.
"""
abstract type AbstractAscii <: AbstractRenderType end

"""
    struct AsciiTable <: AbstractAscii end

The main concrete type for [`AbstractAscii`](@ref). This is the default type
used for plain text rendering.
"""
struct AsciiTable <: AbstractAscii end

function Base.print(io::IO, row::DataRow{T}) where {T<:AbstractAscii}
    render = T()
    print(io, linestart(render))# in case we want to add something before the line
    for (i, x) in enumerate(row.data)
        print(
            io,
            make_padding(repr(render, x), row.colwidths[i], row.align[i])
        )
        if i < length(row.data)
            print(io, colsep(render))
        end
    end
    print(io, lineend(render))
    # do not print new line here, let the caller do it
    if any(row.print_underlines)
        println(io)# if print underlines, then need new line
        for (i, x) in enumerate(row.data)
            s = isa(x, Pair) ? repr(render, first(x)) : repr(render, x)
            if length(s) > 0 && row.print_underlines[i]
                print(io, underline(render, row.colwidths[i]))
            else
                print(io, " " ^ row.colwidths[i])
            end
            if i < length(row.data)
                print(io, colsep(render))
            end
        end
        
    end
end

function total_length(tab::RegressionTable, r=1:size(tab, 2), widths=colwidths(tab), sep=colsep(tab))
    sum(widths[r]) + (length(r)-1) * length(sep)
end

underline(::AbstractAscii, l) = "-" ^ l
toprule(::AbstractAscii, l) = "-" ^ l
midrule(::AbstractAscii, l) = "-" ^ l
bottomrule(::AbstractAscii, l) = "-" ^ l


underline(tab::RegressionTable{<:AbstractAscii}) = underline(tab.render, total_length(tab))
toprule(tab::RegressionTable{<:AbstractAscii}) = toprule(tab.render, total_length(tab))
midrule(tab::RegressionTable{<:AbstractAscii}) = midrule(tab.render, total_length(tab))
bottomrule(tab::RegressionTable{<:AbstractAscii}) = bottomrule(tab.render, total_length(tab))
