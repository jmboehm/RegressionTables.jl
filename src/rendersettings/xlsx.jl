abstract type AbstractExcel <: AbstractAscii end
struct ExcelTable <: AbstractExcel end
default_file(render::AbstractExcel, rrs) = "results.xlsx"
horizontal_gap_spacing(::AbstractRenderType) = 5
vertical_gap_spacing(::AbstractRenderType) = 1
col_padding(::AbstractRenderType) = 2
print_gridlines(::AbstractRenderType) = false
excel_font(::AbstractRenderType) = "Times New Roman"
excel_font_size(::AbstractRenderType) = 12

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
    
    row
end

function col_letter(col, tab::RegressionTable)
    ver_gap = tab.vertical_gaps |> unique
    col += sum(col .> ver_gap)
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

function cell_name(row, col, tab::RegressionTable)
    col_letter(col, tab) * string(row_val(row, tab))
end



function underline_row(render::AbstractRenderType, ws, tab, row, pyxl, border_style)
    m = col_letter(size(tab, 2), tab) |> String
    v = "A" * string(row+1)
    ws.row_dimensions[row+1].height = horizontal_gap_spacing(render)
    ws.row_dimensions[row+2].height = horizontal_gap_spacing(render)
    ws[v].border = pyxl.styles.borders.Border(bottom=pyxl.styles.borders.Side(border_style=border_style))
    
    l = "A"
    while l != m
        l = next_col(l)
        c = l * string(row+1)
        ws[c].border = pyxl.styles.borders.Border(bottom=pyxl.styles.borders.Side(border_style=border_style))
    end
end
function toprule(render::AbstractRenderType, ws, tab, row, pyxl)
    underline_row(render, ws, tab, row, pyxl, "thin")
end

function midrule(render::AbstractRenderType, ws, tab, row, pyxl)
    underline_row(render, ws, tab, row, pyxl, "thin")
end

function bottomrule(render::AbstractRenderType, ws, tab, row, pyxl)
    underline_row(render, ws, tab, row, pyxl, "thin")
end

function Base.write(file::String, tab::RegressionTable{T}) where {T <: AbstractExcel}
    write_excel(file, tab)
end
function Base.write(file::Tuple{String, String}, tab::RegressionTable{T}) where {T <: AbstractExcel}
    write_excel(file[1], tab; sheet=file[2])
end


function write_excel(file::String, tab::RegressionTable{T}; sheet="Sheet") where {T}
    render = T()
    xlsx = pyimport("openpyxl")
    xlsx.styles.DEFAULT_FONT.name=excel_font(render)
    xlsx.styles.DEFAULT_FONT.size=excel_font_size(render)
    if isfile(file)
        wb = xlsx.load_workbook(file)
    else
        wb = xlsx.Workbook()
    end
    if sheet in wb.sheetnames
        ws = wb[sheet]
        wb.remove_sheet(ws)
    end
    ws = wb.create_sheet(sheet)
    ws.sheet_view.showGridLines=print_gridlines(render)
    for (i, x) in enumerate(tab.data)
        col_index = 1
        for j in eachindex(x.data)#ignores merged cells

            y = x.data[j]
            c = cell_name(i, col_index, tab)
            write_excel(render, ws, c, y)
            if x.print_underlines[j]
                ws[c].border = xlsx.styles.borders.Border(bottom=xlsx.styles.borders.Side(border_style="thin"))
            end
            align = if x.align[j] == 'r'
                "right"
            elseif x.align[j] == 'c'
                "center"
            else
                "left"
            end
            ws[c].alignment = xlsx.styles.Alignment(horizontal=align)
            ws[c].font = xlsx.styles.Font(name=excel_font(render), size=excel_font_size(render))

            if isa(y, Pair)
                merge_end = cell_name(i, col_index + length(last(y)) - 1, tab)
                m = "$(c):$merge_end"
                ws.merge_cells(m)
                col_index += length(last(y))
            else
                col_index += 1
            end

        end
    end
    for (i, v) in enumerate(tab.colwidths)
        col = col_letter(i, tab)
        ws.column_dimensions[col].width = v+col_padding(render)
    end
    for v in tab.vertical_gaps
        col = col_letter(v, tab)
        col = next_col(col)
        ws.column_dimensions[col].width = vertical_gap_spacing(render)
    end
    vals = vcat([-2, size(tab, 1)], tab.breaks) |> unique |> sort
    for (i, v) in enumerate(vals)
        row = row_val(v, tab)
        if i == 1
            toprule(render, ws, tab, row, xlsx)
        elseif i == length(vals)
            bottomrule(render, ws, tab, row, xlsx)
        else
            midrule(render, ws, tab, row, xlsx)
        end
    end
    wb.save(file)
end

excel_format(render::AbstractRenderType, x::Real; digits=default_digits(render, x), args...) = "0." * "0"^digits
excel_format(render::AbstractRenderType, x::AbstractRegressionStatistic; digits=default_digits(render, x), args...) = excel_format(render, value(x); digits, args...)
excel_format(render::AbstractRenderType, x::Int; args...) = "#,###"
function excel_format(render::AbstractRenderType, x::AbstractUnderStatistic; digits=default_digits(render, x), args...)
    below_decoration(render, excel_format(render, value(x); digits, args...))
end
excel_format(render::AbstractRenderType, x::CoefValue; digits=default_digits(render, x), args...) = excel_format(render, value(x); digits, args...)
excel_format(render::AbstractRenderType, x::Union{Nothing, Missing}; args...) = ""

function escape_decorator(s)
    if s ∈ ('*', "*")
        return "\\$s"
    else
        return s
    end
end

function write_excel(render, ws, cell, val; vargs...)
    v = repr(render, val)
    ws[cell] = v
end

function write_excel(render, ws, cell, val::Union{AbstractUnderStatistic, AbstractRegressionStatistic}; fmt=excel_format(render, val), vargs...)
    v = value(val)
    write_excel(render, ws, cell, v; fmt, vargs...)
end

function write_excel(render, ws, cell, val::CoefValue; fmt=excel_format(render, val), vargs...)
    new_fmt = estim_decorator(render, fmt, value_pvalue(val); sym=escape_decorator(default_symbol(render)))
    v = value(val)
    write_excel(render, ws, cell, v; fmt=new_fmt, vargs...)
end


function write_excel(render, ws, cell, val::Real; fmt=excel_format(render, val), vargs...)
    ws[cell] = val
    ws[cell].number_format = fmt
end


function write_excel(render, ws, cell, val::Pair; vargs...)
    write_excel(render, ws, cell, first(val); vargs...)
end