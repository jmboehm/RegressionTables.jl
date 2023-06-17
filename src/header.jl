struct HeaderRow
    values::Vector{Pair{String, UnitRange{Int}}} # value, column range
    parent::RegressionTable
end
struct Header
    rows::Vector{HeaderRow}
    parent::RegressionTable
end

function HeaderRow(tab::RegressionTable, i::Int)
    data = header(tab)[i, :]
    values = Vector{Pair{String, UnitRange{Int}}}()
    x = first(data)
    j_start = firstindex(data)
    j_end = firstindex(data)
    for i in eachindex(data)
        if data[i] != x
            push!(values, x => j_start:j_end)
            x = data[i]
            j_start = i
            j_end = i
        else
            j_end = i
        end
    end
    # push last value
    push!(values, x => j_start:j_end)
    return HeaderRow(values, tab)
end

function Header(tab::RegressionTable)
    data = header(tab)
    rows = Vector{HeaderRow}()
    for i in 1:size(data, 1)
        push!(rows, HeaderRow(tab, i))
    end
    return Header(rows, tab)
end

function Base.print(io::IO, row::HeaderRow; not_last_row=true)
    print(io, linestart(row.parent))
    for (i, value) in enumerate(row.values)
        s = if !not_last_row || length(first(value)) == 0
            first(value)
        else
            encapsulateRegressand(row.parent, first(value), last(value)[1], last(value)[end])
        end
        print_cell(
            io,
            row.parent,
            s,
            total_length(row.parent, last(value)),
            'c',
            i < length(row.values);
            hdr=true
        )
    end
    println(io, linebreak(row.parent))
    if not_last_row
        print_headerrule(io, row.parent, row)
    end
end

function Base.print(io::IO, header::Header)
    for (i, row) in enumerate(header.rows)
        not_last_row = i < length(header.rows)
        print(io, row, not_last_row=not_last_row)
    end
    println(io, midrule(header.parent))
end 