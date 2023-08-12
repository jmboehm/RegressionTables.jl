"""
    abstract type AbstractHTML <: AbstractRenderType end

The abstract type for most plain text rendering. Printing is defined using the `AbstractHTML`, so
new tables (with different defaults) can be created by subtyping `AbstractHTML` with minimal effort.
"""
abstract type AbstractHTML <: AbstractRenderType end
struct HTMLTable <: AbstractHTML end

function (::Type{T})(val::Pair; align='c', print_underlines=false, args...) where T<:AbstractHTML
    s = T(first(val); args...)
    if length(s) == 0
        s
    else
        multicolumn(T(), s, length(last(val)), align, print_underlines)
    end
end

function Base.print(io::IO, row::DataRow{T}) where {T<:AbstractHTML}
    print(io, "<tr>")
    for (i, x) in enumerate(row.data)
        if isa(x, Pair)
            s = T(x; align=row.align[i], print_underlines=row.print_underlines[i])
            if length(s) == 0
                print(io, "<td></td>")
                continue
            end
            s = make_padding(s, row.colwidths[i], row.align[i])

            print(io,s)
        else
            s = make_padding(T(x), row.colwidths[i], row.align[i])
            print(io, "<td>", s, "</td>")
        end
    end
    print(io, "</tr>")
end



function multicolumn(::AbstractHTML, s, cols::Int, align="c", underline=true)
    align = if align == "c" || align == 'c'
        "center"
    elseif align == "l" || align == 'l'
        "left"
    elseif align == "r" || align == 'r'
        "right"
    else
        "center"
    end
    u = if underline
        "border-bottom:1px solid;"
    else
        ""
    end
    "<td colspan=\"$cols\" style=\"padding:0.2cm; text-align:$align; $u\">$s</td>"
end
tablestart(::AbstractHTML) = """
<table>
<style>
table {
    border-collapse: collapse;
    border: none;
    border-top: double;
    border-bottom: double;
}
th, td {
    padding: 0.2em;
    padding-left: 0.8em;
    padding-right: 0.8em;
}
</style>
<tbody>
"""
tableend(::AbstractHTML) = "</tbody></table>"
underline(::AbstractHTML) = ""

# toprule: just a spacer <tr>
toprule(::AbstractHTML) = "<tr><td style=\"padding:0.1cm\" colspan=\"100%\"></td></tr>"
# midrule: a <tr> with black border on bottom, and a <tr> spacer
midrule(::AbstractHTML) = "<tr style=\"border-bottom:1px solid\"><td style=\"padding:0.1cm\" colspan=\"100%\"></td></tr><tr><td style=\"padding:0.1cm\" colspan=\"100%\"></td></tr>"
# bottomrule: a slightly larger spacer
bottomrule(::AbstractHTML) = "<tr><td style=\"padding:0.15cm\" colspan=\"100%\"></td></tr>"
colsep(::AbstractHTML) = "<td></td>"
linestart(::AbstractHTML) = "<tr><td>"
lineend(::AbstractHTML) = " </td></tr>"


label(::AbstractHTML, x::Type{Nobs}) = "<i>N</i>"
label(::AbstractHTML, x::Type{R2}) = "<i>R<sup>2</sup></i>"
label(::AbstractHTML, x::Type{FStat}) = "<i>F</i>"
label_p(::AbstractHTML) = "<i>p</i>"
interaction_combine(::AbstractHTML) = " &times; "

# if both MIME is html and the table is an HTMLTable, then show the table as html
Base.show(io::IO, x::MIME{Symbol("text/html")}, tab::RegressionTable{<:AbstractHTML}) = show(io, tab)
Base.show(io::IO, x::MIME{Symbol("text/markdown")}, tab::RegressionTable{<:AbstractHTML}) = show(io, tab)