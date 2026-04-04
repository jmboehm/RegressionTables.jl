
abstract type AbstractXlsx <: AbstractAscii end
struct XlsxTable <: AbstractXlsx end

default_file(render::AbstractXlsx, rrs) = "results.xlsx"
horizontal_gap_spacing(::AbstractRenderType) = 5
vertical_gap_spacing(::AbstractRenderType) = 1
col_padding(::AbstractRenderType) = 2
print_gridlines(::AbstractRenderType) = false
xlsx_font(::AbstractRenderType) = "Times New Roman"
xlsx_font_size(::AbstractRenderType) = 12
initial_row_gap(::AbstractRenderType) = 0
initial_col_gap(::AbstractRenderType) = 1

function next_col(s)
    if s == ""
        return "A"
    end
    if s[end] == 'Z'
        return next_col(s[1:end-1]) * "A"
    end
    s[1:end-1] * string(Char(s[end] + 1))
end

function row_val(row, tab::RegressionTable)
    hor_gap = tab.breaks |> unique
    row += 2*sum(row .> hor_gap)
    row += 2
    row + initial_row_gap(tab.render)
end

function col_letter(col::Int)
    col_name = ""
    while col > 0
        col, rem = divrem(col, 26)
        if rem == 0
            col_name = "Z" * col_name
            col -= 1
        else
            col_name = string(Char(rem + 64)) * col_name
        end
    end
    col_name
end

function col_index(col::Int, tab::RegressionTable)
    ver_gap = tab.vertical_gaps |> unique
    col + sum(col .> ver_gap) + initial_col_gap(tab.render)
end

function col_letter(col, tab::RegressionTable)
    col_letter(col_index(col, tab))
end

function cell_name(row, col, tab::RegressionTable)
    col_letter(col, tab) * string(row_val(row, tab))
end

xlsx_format(render::AbstractRenderType, x::Real; digits=default_digits(render, x), args...) = "0." * "0"^digits
xlsx_format(render::AbstractRenderType, x::AbstractRegressionStatistic; digits=default_digits(render, x), args...) = xlsx_format(render, value(x); digits, args...)
xlsx_format(render::AbstractRenderType, x::Int; args...) = "#,###"
function xlsx_format(render::AbstractRenderType, x::AbstractUnderStatistic; digits=default_digits(render, x), args...)
    below_decoration(render, xlsx_format(render, value(x); digits, args...)) * ";" * below_decoration(render, "-" * xlsx_format(render, value(x); digits, args...))
end
xlsx_format(render::AbstractRenderType, x::CoefValue; digits=default_digits(render, x), args...) = xlsx_format(render, value(x); digits, args...)
xlsx_format(render::AbstractRenderType, x::Union{Nothing, Missing}; args...) = ""

function escape_decorator(s)
    if s ∈ ('*', "*")
        return "\\$s"
    else
        return s
    end
end
