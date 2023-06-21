abstract type AbstractLatex <: AbstractRenderType end
struct LatexTable <: AbstractLatex end

function full_string(val::Pair, rndr::AbstractLatex, align="c")
    s = to_string(rndr, first(val))
    if length(s) == 0
        s
    else
        encapsulateRegressand(rndr, to_string(rndr, first(val)), length(last(val)), align)
    end
end

function print_row(io::IO, row::DataRow, rndr::AbstractLatex)
    for (i, x) in enumerate(row.data)
        print(
            io,
            make_padding(full_string(x, rndr, row.align[i]), row.colwidths[i], row.align[i])
        )
        if i < length(row.data)
            print(io, colsep(rndr))
        end
    end
    println(io, " \\\\")
    if row.print_underlines
        for (i, x) in enumerate(row.data)
            s = isa(x, Pair) ? to_string(rndr, first(x)) : to_string(rndr, x)
            if length(s) == 0
                continue
            end
            if isa(x, Pair)
                print(io, headerrule(rndr, first(last(x)), last(last(x))))
            else
                print(io, headerrule(rndr, i,i))
            end
        end
        println(io)
    end
end


encapsulateRegressand(::AbstractLatex, s, cols::Int, align="c") = "\\multicolumn{$cols}{$align}{$s}"
tablestart(::AbstractLatex, align) = "\\begin{tabular}{$align}"
tableend(::AbstractLatex) = "\\end{tabular}"
headerrule(::AbstractLatex, colmin::Int, colmax::Int) = "\\cmidrule(lr){$(colmin)-$(colmax)}"

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