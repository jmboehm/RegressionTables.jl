abstract type AbstractTypst <: AbstractRenderType end
struct TypstTable <: AbstractTypst end

function tablestart(::AbstractTypst, align)
    cols = [c == 'l' ? "left" : c == 'r' ? "right" : "center" for c in align]
    cols_align = join(cols, ", ")
    cols = join(fill("auto", length(cols)), ", ")

"""
#table(
    columns: ($cols),
    align: ($cols_align),
    column-gutter: 1fr,
    stroke: none,
"""
end

wrapper(::AbstractTypst, x) = "\$\"\"^($x)\$"

tableend(::AbstractTypst) = ")"

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
    "table.cell(colspan: $cols, align: $x)[$s]"
end

underline(::AbstractTypst, colmin::Int, colmax::Int) = "table.hline(start: $(colmin-1), end: $(colmax), stroke: 0.5pt)"

toprule(x::AbstractTypst) = linestart(x) * "table.hline(), "
midrule(x::AbstractTypst) = linestart(x) * "table.hline(stroke: 0.7pt), "
bottomrule(x::AbstractTypst) = linestart(x) * "table.hline(), "
linestart(::AbstractTypst) = "  "
lineend(::AbstractTypst) = ","
tablestart(tab::RegressionTable{<:AbstractTypst}) = tablestart(tab.render, tab.align)
colsep(::AbstractTypst) = ", "

label(::AbstractTypst, x::Type{Nobs}) = "_N_"
label(::AbstractTypst, x::Type{R2}) = "_R_\$\"\"^2\$"
label(::AbstractTypst, x::Type{FStat}) = "_F_"
label_p(::AbstractTypst, ) = "_p_"

interaction_combine(::AbstractTypst) = " \$times\$ "

function Base.print(io::IO, row::DataRow{T}) where {T<:AbstractTypst}
    render = T()
    print(io, linestart(render))
    for (i, x) in enumerate(row.data)
        s = if isa(x, Pair)
            repr(render, x; align = row.align[i])
        else
            "[" * repr(render, x; align = row.align[i]) * "]"
        end
        print(io, make_padding(s, row.colwidths[i], row.align[i]))
        if i < length(row.data)
            print(io, colsep(render))
        end
    end
    print(io, lineend(render))
    if any(row.print_underlines)
        println(io)
        print(io, linestart(render))
        for (i, x) in enumerate(row.data)
            s = isa(x, Pair) ? repr(render, first(x)) : repr(render, x)
            if length(s) == 0 || !row.print_underlines[i]
                continue
            end
            if isa(x, Pair)
                print(io, underline(render, first(last(x)), last(last(x))))
            else
                print(io, underline(render, i,i))
            end
            print(io, colsep(render))
        end
    end
end
