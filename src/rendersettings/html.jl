"""
    abstract type AbstractHtml <: AbstractRenderType end

The abstract type for most plain text rendering. Printing is defined using the `AbstractHtml`, so
new tables (with different defaults) can be created by subtyping `AbstractHtml` with minimal effort.
"""
abstract type AbstractHtml <: AbstractRenderType end

"""
    struct HtmlTable <: AbstractHtml end    

The main concrete type for [`AbstractHtml`](@ref). This type is
used to create HTML tables.
"""
struct HtmlTable <: AbstractHtml end

function (::Type{T})(val::Pair; align='c', print_underlines=false, args...) where T<:AbstractHtml
    s = T(first(val); args...)
    if length(s) == 0
        s
    else
        multicolumn(T(), s, length(last(val)), align, print_underlines)
    end
end

function Base.print(io::IO, row::DataRow{T}) where {T<:AbstractHtml}
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



function multicolumn(::AbstractHtml, s, cols::Int, align="c", underline=true)
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
tablestart(::AbstractHtml) = """
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
tableend(::AbstractHtml) = "</tbody></table>"
underline(::AbstractHtml) = ""

# toprule: just a spacer <tr>
toprule(::AbstractHtml) = "<tr><td style=\"padding:0.1cm\" colspan=\"100%\"></td></tr>"
# midrule: a <tr> with black border on bottom, and a <tr> spacer
midrule(::AbstractHtml) = "<tr style=\"border-bottom:1px solid\"><td style=\"padding:0.1cm\" colspan=\"100%\"></td></tr><tr><td style=\"padding:0.1cm\" colspan=\"100%\"></td></tr>"
# bottomrule: a slightly larger spacer
bottomrule(::AbstractHtml) = "<tr><td style=\"padding:0.15cm\" colspan=\"100%\"></td></tr>"
colsep(::AbstractHtml) = "<td></td>"
linestart(::AbstractHtml) = "<tr><td>"
lineend(::AbstractHtml) = " </td></tr>"


label(::AbstractHtml, x::Type{Nobs}) = "<i>N</i>"
label(::AbstractHtml, x::Type{R2}) = "<i>R<sup>2</sup></i>"
label(::AbstractHtml, x::Type{FStat}) = "<i>F</i>"
label_p(::AbstractHtml) = "<i>p</i>"
interaction_combine(::AbstractHtml) = " &times; "

# if both MIME is html and the table is an HtmlTable, then show the table as html
Base.show(io::IO, x::MIME{Symbol("text/html")}, tab::RegressionTable{<:AbstractHtml}) = show(io, tab)
Base.show(io::IO, x::MIME{Symbol("text/markdown")}, tab::RegressionTable{<:AbstractHtml}) = show(io, tab)