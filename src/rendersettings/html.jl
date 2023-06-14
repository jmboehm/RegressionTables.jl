encapsulateRegressand(::AbstractHTML, s, colmin::Int, colmax::Int) = "<td colspan=\"$(colmax-colmin+1)\" style=\"padding:0.2cm; text-align:center; border-bottom:1px solid;\">$s</td>"
tablestart(::AbstractHTML) = "<table style=\"border-collapse:collapse; border:none;border-top:double;border-bottom:double;\">\n<tbody>"
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
colsep(::AbstractHTML) = " </td><td style=\"padding:0.2em; padding-left:0.8em; padding-right:0.8em;\"> "
linestart(::AbstractHTML) = "<tr><td>"
linebreak(::AbstractHTML) = " </td></tr>"


label(tab::AbstractHTML, x::Type{<:Nobs}) = "<i>N</i>"
label(tab::AbstractHTML, x::Type{<:R2}) = "<i>R<sup>2</sup></i>"
label(tab::AbstractHTML, x::Type{<:FStat}) = "<i>F</i>"
label_p(tab::AbstractHTML) = "<i>p</i>"
