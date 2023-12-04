abstract type AbstractTypst <: AbstractRenderType end
struct TypstTable <: AbstractTypst end

function tablestart(::TypstTable, align)
    cols = [c == 'l' ? "left" : c == 'r' ? "right" : "center" for c in align]
    cols_align = join(cols, ", ")
    cols = join(fill("auto", length(cols)), ", ")

"""
#import "@preview/tablex:0.0.6": colspanx, hlinex, gridx
#gridx(
    columns: ($cols),
    align: ($cols_align),
    column-gutter: 1fr,
"""
end

wrapper(::AbstractTypst, x) = "\$\"\"^($x)\$"

tableend(::TypstTable) = ")"

function Base.repr(rndr::AbstractTypst, val::Pair; align="c", args...)
    s = Base.repr(rndr, first(val); args...)
    if length(s) == 0 && length(last(val)) == 1
        s
    else
        multicolumn(rndr, s, length(last(val)), align)
    end
end
function multicolumn(rndr::AbstractTypst, s, cols::Int, align="c")
    x = if align == "c" || align == 'c'
        "center"
    elseif align == "l" || align == 'l'
        "left"
    elseif align == "r" || align == 'r'
        "right"
    end
    "colspanx($cols, align: $x)[$s]"
end

underline(::AbstractTypst, colmin::Int, colmax::Int) = "hlinex(start: $(colmin-1), end: $(colmax), stop-pre-gutter: true)"

toprule(x::AbstractTypst) = linestart(x) * "hlinex(), "
midrule(x::AbstractTypst) = linestart(x) * "hlinex(), "
bottomrule(x::AbstractTypst) = linestart(x) * "hlinex(), "
linestart(::AbstractTypst) = "  "
lineend(::AbstractTypst) = ","
tablestart(tab::RegressionTable{<:AbstractTypst}) = tablestart(tab.rndr, tab.align)
colsep(::AbstractTypst) = ", "

label(::AbstractTypst, x::Type{Nobs}) = "_N_"
label(::AbstractTypst, x::Type{R2}) = "_R_\$\"\"^2\$"
label(::AbstractTypst, x::Type{FStat}) = "_F_"
label_p(::AbstractTypst, ) = "_p_"

interaction_combine(::AbstractTypst) = " \$times\$ "

function Base.print(io::IO, row::DataRow{T}) where {T<:AbstractTypst}
    rndr = T()
    print(io, linestart(rndr))
    for (i, x) in enumerate(row.data)
        s = if isa(x, Pair)
            render(rndr, x; align = row.align[i])
        else
            "[" * render(rndr, x; align = row.align[i]) * "]"
        end
        print(io, make_padding(s, row.colwidths[i], row.align[i]))
        if i < length(row.data)
            print(io, colsep(rndr))
        end
    end
    print(io, lineend(rndr))
    if any(row.print_underlines)
        println(io)
        print(io, linestart(rndr))
        for (i, x) in enumerate(row.data)
            s = isa(x, Pair) ? render(rndr, first(x)) : render(rndr, x)
            if length(s) == 0 || !row.print_underlines[i]
                continue
            end
            if isa(x, Pair)
                print(io, underline(rndr, first(last(x)), last(last(x))))
            else
                print(io, underline(rndr, i,i))
            end
            print(io, colsep(rndr))
        end
    end
end
