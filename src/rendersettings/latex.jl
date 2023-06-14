encapsulateRegressand(::AbstractLatex, s, colmin::Int, colmax::Int, align="c") = "\\multicolumn{$(colmax-colmin+1)}{$align}{$s}"
tablestart(tab::AbstractLatex) = "\\begin{tabular}{$(align(tab))}"
tableend(::AbstractLatex) = "\\end{tabular}"
headerrule(::AbstractLatex, colmin::Int, colmax::Int) = "\\cmidrule(lr){$(colmin)-$(colmax)}"

function print_headerrule(io, tab::AbstractLatex, row::HeaderRow)
    for value in row.values
        if length(first(value)) > 0
            print(io, headerrule(tab, last(value)[1], last(value)[end]))
        end
    end
    println(io)
end
toprule(::AbstractLatex) = "\\toprule"
midrule(::AbstractLatex) = "\\midrule"
bottomrule(::AbstractLatex) = "\\bottomrule"
headercolsep(::AbstractLatex) = " & "
colsep(::AbstractLatex) = " & "
linestart(::AbstractLatex) = ""
linebreak(::AbstractLatex) = " \\\\ "


label(tab::AbstractLatex, x::Type{<:Nobs}) = "\$N\$"
label(tab::AbstractLatex, x::Type{<:R2}) = "\$R^2\$"
label(tab::AbstractLatex, x::Type{<:FStat}) = "\$F\$"
label_p(tab::AbstractLatex) = "\$p\$"
wrapper(tab::AbstractLatex, x) = "\$^{$x}\$"
