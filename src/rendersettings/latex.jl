"""
    abstract type AbstractLatex <: AbstractRenderType end

The abstract type for most plain text rendering. Printing is defined using the `AbstractLatex`, so
new tables (with different defaults) can be created by subtyping `AbstractLatex` with minimal effort.
"""
abstract type AbstractLatex <: AbstractRenderType end

"""
    struct LatexTable <: AbstractLatex end

The main concrete type for [`AbstractLatex`](@ref). This type is
used to create Latex tables.
"""
struct LatexTable <: AbstractLatex end

"""
    struct LatexTableStar <: AbstractLatex end

An alternative concrete type for [`AbstractLatex`](@ref). This type is
used to create Latex tables that span the entire text width.
"""
struct LatexTableStar <: AbstractLatex end

function render(rndr::AbstractLatex, val::Pair; align="c", args...)
    s = render(rndr, first(val); args...)
    # need to print the multicolumn version since it will miss & otherwise
    if length(s) == 0 && length(last(val)) == 1
        s
    else
        multicolumn(rndr, s, length(last(val)), align)
    end
end

function Base.print(io::IO, row::DataRow{T}) where T<:AbstractLatex
    rndr = T()
    print(io, linestart(rndr))
    for (i, x) in enumerate(row.data)
        print(
            io,
            make_padding(render(rndr, x; align = row.align[i]), row.colwidths[i], row.align[i])
        )
        if i < length(row.data)
            print(io, colsep(rndr))
        end
    end
    print(io, lineend(rndr))
    if any(row.print_underlines)
        println(io)
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
        end
    end
end


multicolumn(::AbstractLatex, s, cols::Int, align="c") = "\\multicolumn{$cols}{$align}{$s}"
tablestart(::AbstractLatex, align) = "\\begin{tabular}{$align}"
tableend(::AbstractLatex) = "\\end{tabular}"
tablestart(::LatexTableStar, align) = "\\begin{tabular*}{\\textwidth}{$(align[1])@{\\extracolsep{\\fill}}$(align[2:end])}"
tableend(::LatexTableStar) = "\\end{tabular*}"
underline(::AbstractLatex, colmin::Int, colmax::Int) = "\\cmidrule(lr){$(colmin)-$(colmax)} "

toprule(::AbstractLatex) = "\\toprule"
midrule(::AbstractLatex) = "\\midrule"
bottomrule(::AbstractLatex) = "\\bottomrule"
colsep(::AbstractLatex) = " & "
linestart(::AbstractLatex) = ""
lineend(::AbstractLatex) = " \\\\ "

# functions to make multiple dispatch easier
tablestart(tab::RegressionTable{<:AbstractLatex}) = tablestart(tab.rndr, tab.align)
underline(tab::RegressionTable{<:AbstractLatex}, colmin::Int, colmax::Int) = headerule(tab.rndr, colmin, colmax)




label(::AbstractLatex, x::Type{Nobs}) = "\$N\$"
label(::AbstractLatex, x::Type{R2}) = "\$R^2\$"
label(::AbstractLatex, x::Type{FStat}) = "\$F\$"
label_p(::AbstractLatex) = "\$p\$"
#wrapper(::AbstractLatex, x) = #"\$^{$x}\$"
interaction_combine(::AbstractLatex) = " \$\\times\$ "