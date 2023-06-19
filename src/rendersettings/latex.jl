encapsulateRegressand(::AbstractLatex, s, cols::Int, align="c") = "\\multicolumn{$cols}{$align}{$s}"
tablestart(::AbstractLatex, align) = "\\begin{tabular}{$align}"
tableend(::AbstractLatex) = "\\end{tabular}"
headerrule(::AbstractLatex, colmin::Int, colmax::Int) = "\\cmidrule(lr){$(colmin)-$(colmax)}"

function print_headerrule(io, rndr::AbstractLatex, row::HeaderRow)
    for value in row.values
        if length(first(value)) > 0
            print(io, headerrule(rndr, last(value)[1], last(value)[end]))
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

# functions to make multiple dispatch easier
tablestart(tab::RegressionTable{<:AbstractLatex}) = tablestart(tab.render, tab.align)
tableend(tab::RegressionTable{<:AbstractLatex}) = tableend(tab.render)
headerrule(tab::RegressionTable{<:AbstractLatex}, colmin::Int, colmax::Int) = headerule(tab.render, colmin, colmax)

print_headerrule(io, tab::RegressionTable{<:AbstractLatex}, row::HeaderRow) = print_headerrule(io, tab.render, row)

toprule(tab::RegressionTable{<:AbstractLatex}) = toprule(tab.render)
midrule(tab::RegressionTable{<:AbstractLatex}) = midrule(tab.render)
bottomrule(tab::RegressionTable{<:AbstractLatex}) = bottomrule(tab.render)
headercolsep(tab::RegressionTable{<:AbstractLatex}) = headercolsep(tab.render)
colsep(tab::RegressionTable{<:AbstractLatex}) = colsep(tab.render)
linestart(tab::RegressionTable{<:AbstractLatex}) = linestart(tab.render)
linebreak(tab::RegressionTable{<:AbstractLatex}) = linebreak(tab.render)



label(::AbstractLatex, x::Type{<:Nobs}) = "\$N\$"
label(::AbstractLatex, x::Type{<:R2}) = "\$R^2\$"
label(::AbstractLatex, x::Type{<:FStat}) = "\$F\$"
label_p(::AbstractLatex) = "\$p\$"
wrapper(::AbstractLatex, x) = "\$^{$x}\$"
interaction_combine(::AbstractLatex) = " \$\\times\$ "