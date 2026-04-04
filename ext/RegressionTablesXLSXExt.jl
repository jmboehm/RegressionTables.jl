module RegressionTablesXLSXExt

using XLSX, RegressionTables
import RegressionTables:
    AbstractXlsx, AbstractUnderStatistic, AbstractRegressionStatistic, CoefValue,
    value, value_pvalue, estim_decorator, default_symbol, escape_decorator, xlsx_format,
    row_val, col_letter, col_index, cell_name,
    xlsx_font, xlsx_font_size, horizontal_gap_spacing, vertical_gap_spacing,
    col_padding, print_gridlines, initial_row_gap, initial_col_gap

function Base.write(file::String, tab::RegressionTable{T}) where {T <: AbstractXlsx}
    write_xlsx(file, tab)
end

function Base.write(file::Tuple{String, String}, tab::RegressionTable{T}) where {T <: AbstractXlsx}
    write_xlsx(file[1], tab; sheet=file[2])
end

function write_xlsx(file::String, tab::RegressionTable{T}; sheet="Sheet") where {T <: AbstractXlsx}
    render = T()

    xf = if isfile(file)
        XLSX.opentemplate(file)
    else
        XLSX.newxlsx(sheet)
    end

    ws = if XLSX.hassheet(xf, sheet)
        xf[sheet]
    else
        XLSX.addsheet!(xf, sheet)
    end

    first_row_excel = 1 + initial_row_gap(render)
    last_row_excel  = row_val(size(tab, 1), tab) + 2
    first_col_i     = initial_col_gap(render) + 1
    last_col_i      = col_index(size(tab, 2), tab)

    # Pre-populate all cells in the bounding box with "" so setBorder can be applied to them
    for r in first_row_excel:last_row_excel
        for c in first_col_i:last_col_i
            ws["$(col_letter(c))$r"] = ""
        end
    end

    # Write cell values and per-cell formatting
    for (i, x) in enumerate(tab.data)
        col_idx = 1
        for j in eachindex(x.data)
            y = x.data[j]
            c = cell_name(i, col_idx, tab)
            align = x.align[j] == 'r' ? "right" : x.align[j] == 'c' ? "center" : "left"

            write_xlsx(render, ws, c, y)
            XLSX.setFont(ws, c; name=xlsx_font(render), size=xlsx_font_size(render))
            XLSX.setAlignment(ws, c; horizontal=align)

            if x.print_underlines[j]
                # Explicit black color required: white allsides border is applied later and
                # setBorder merges attributes, so the color must be set here to override it.
                XLSX.setBorder(ws, c; bottom=["style" => "thin", "color" => "FF000000"])
            end

            if isa(y, Pair)
                merge_end = cell_name(i, col_idx + length(last(y)) - 1, tab)
                XLSX.mergeCells(ws, "$(c):$(merge_end)")
                col_idx += length(last(y))
            else
                col_idx += 1
            end
        end
    end

    # Set column widths for data columns and vertical-gap columns
    for (i, v) in enumerate(tab.colwidths)
        c = col_index(i, tab)
        XLSX.setColumnWidth(ws, c; width=v + col_padding(render))
    end
    for v in tab.vertical_gaps
        c = col_index(v, tab) + 1  # gap column immediately follows data column v
        XLSX.setColumnWidth(ws, c; width=vertical_gap_spacing(render))
    end

    # Apply white uniform border to full table range to visually hide gridlines.
    # This must come AFTER per-cell underlines so those borders are applied on top.
    # Rule borders (toprule/midrule/bottomrule) applied after this will override the
    # white bottom border with explicit black.
    if !print_gridlines(render)
        first_cell = "$(col_letter(first_col_i))$(first_row_excel)"
        last_cell  = "$(col_letter(last_col_i))$(last_row_excel)"
        XLSX.setUniformBorder(ws, "$(first_cell):$(last_cell)"; allsides=["style" => "thin", "color" => "FFFFFFFF"])
    end

    # Apply toprule / midrule / bottomrule rule borders
    vals = vcat([-2, size(tab, 1)], tab.breaks) |> unique |> sort
    for v in vals
        underline_row(render, ws, tab, row_val(v, tab), "thin")
    end

    XLSX.writexlsx(file, xf; overwrite=true)
end

function underline_row(render, ws, tab, row, border_style)
    n_cols      = col_index(size(tab, 2), tab)
    first_col_i = initial_col_gap(render) + 1
    # Set row heights for the two gap rows surrounding the rule line
    XLSX.setRowHeight(ws, "A$(row+1):A$(row+2)"; height=horizontal_gap_spacing(render))
    # Apply bottom border to the first gap row (the visible rule line)
    for c in first_col_i:n_cols
        cell = col_letter(c) * string(row + 1)
        XLSX.setBorder(ws, cell; bottom=["style" => border_style, "color" => "FF000000"])
    end
end

# ── Cell-level write dispatchers ──────────────────────────────────────────────

# Default: convert to string representation
function write_xlsx(render, ws, cell, val; kwargs...)
    ws[cell] = repr(render, val)
end

# Real numbers: set numeric value and apply number format
function write_xlsx(render, ws, cell, val::Real; fmt=xlsx_format(render, val), kwargs...)
    ws[cell] = val
    if !isempty(fmt)
        XLSX.setFormat(ws, cell; format=fmt)
    end
end

# Statistics: extract numeric value and delegate with format
function write_xlsx(render, ws, cell, val::Union{AbstractUnderStatistic, AbstractRegressionStatistic}; kwargs...)
    write_xlsx(render, ws, cell, value(val); fmt=xlsx_format(render, val))
end

# CoefValue: build significance-decorated number format string
function write_xlsx(render, ws, cell, val::CoefValue; kwargs...)
    base_fmt = xlsx_format(render, value(val))
    new_fmt  = estim_decorator(render, base_fmt, value_pvalue(val); sym=escape_decorator(default_symbol(render)))
    write_xlsx(render, ws, cell, value(val); fmt=new_fmt)
end

# Pair (multicolumn label): write the label; cell merge is handled by the caller
function write_xlsx(render, ws, cell, val::Pair; kwargs...)
    write_xlsx(render, ws, cell, first(val))
end

end # module
