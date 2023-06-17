
function encapsulateRegressand(::AbstractHTML, s, cols::Int, align="c", underline=true)
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
headerrule(::AbstractHTML) = ""
function print_headerrule(io::IO, ::AbstractHTML, row::HeaderRow)
    # if length(headerCellStartEnd)<2
    #     error("Invalid headerCellStartEnd: need to have at least two columns.")
    # end
    # s = ""
    # for i in headerCellStartEnd[2:end]
    #     s = s * "\\cmidrule(lr){$(i[1])-$(i[2])}" * " "
    # end
    # return s
    print(io, "")
end

# toprule: just a spacer <tr>
toprule(::AbstractHTML) = "<tr><td style=\"padding:0.1cm\" colspan=\"100%\"></td></tr>"
# midrule: a <tr> with black border on bottom, and a <tr> spacer
midrule(::AbstractHTML) = "<tr style=\"border-bottom:1px solid\"><td style=\"padding:0.1cm\" colspan=\"100%\"></td></tr><tr><td style=\"padding:0.1cm\" colspan=\"100%\"></td></tr>"
# bottomrule: a slightly larger spacer
bottomrule(::AbstractHTML) = "<tr><td style=\"padding:0.15cm\" colspan=\"100%\"></td></tr>"
headercolsep(::AbstractHTML) = " "
colsep(::AbstractHTML) = ""
linestart(::AbstractHTML) = "<tr><td>"
linebreak(::AbstractHTML) = " </td></tr>"

# functions to make multiple dispatch easier
tablestart(tab::RegressionTable{<:AbstractHTML}) = tablestart(tab.render)
tableend(tab::RegressionTable{<:AbstractHTML}) = tableend(tab.render)
headerrule(tab::RegressionTable{<:AbstractHTML}, colmin::Int, colmax::Int) = headerule(tab.render, colmin, colmax)
print_headerrule(io, tab::RegressionTable{<:AbstractHTML}, row::HeaderRow) = print_headerrule(io, tab.render, row)
toprule(tab::RegressionTable{<:AbstractHTML}) = toprule(tab.render)
midrule(tab::RegressionTable{<:AbstractHTML}) = midrule(tab.render)
bottomrule(tab::RegressionTable{<:AbstractHTML}) = bottomrule(tab.render)
headercolsep(tab::RegressionTable{<:AbstractHTML}) = headercolsep(tab.render)
colsep(tab::RegressionTable{<:AbstractHTML}) = colsep(tab.render)
linestart(tab::RegressionTable{<:AbstractHTML}) = linestart(tab.render)
linebreak(tab::RegressionTable{<:AbstractHTML}) = linebreak(tab.render)


label(::AbstractHTML, x::Type{<:Nobs}) = "<i>N</i>"
label(::AbstractHTML, x::Type{<:R2}) = "<i>R<sup>2</sup></i>"
label(::AbstractHTML, x::Type{<:FStat}) = "<i>F</i>"
label_p(::AbstractHTML) = "<i>p</i>"
