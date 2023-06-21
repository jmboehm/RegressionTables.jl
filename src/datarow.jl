struct DataRow
    data::Vector
    align::String
    colwidths::Vector{Int}
    print_underlines::Bool
    function DataRow(
        data::Vector,
        align="l" * "r" ^ (length(data) - 1),
        colwidths=fill(0, length(data)),
        print_underlines::Bool=false;
        combine_equals=print_underlines
    )
        if combine_equals
            values = Vector{Pair{<:Any, UnitRange{Int}}}()
            new_align = ""
            x = first(data)
            j_start = firstindex(data)
            j_end = firstindex(data)
            for i in eachindex(data)
                if data[i] != x
                    push!(values, x => j_start:j_end)
                    new_align *= align[j_start]
                    x = data[i]
                    j_start = i
                    j_end = i
                else
                    j_end = i
                end
            end
            push!(values, x => j_start:j_end)
            new_align *= align[j_start]
            new_widths = [sum(colwidths[i]) for i in last.(values)]
            new(values, new_align, new_widths, print_underlines)
        else
            new(data, align, colwidths, print_underlines)
        end
    end
end
DataRow(x::DataRow) = x

function Base.length(x::DataRow)
    out = 0
    for x in x.data
        if isa(x, Pair)
            out += length(last(x))
        else
            out += 1
        end
    end
    out
end

Base.show(io::IO, row::DataRow) = print_row(io, row, AsciiTable())

function calc_widths(rows::Vector{DataRow}, rndr)
    out_lengths = fill(0, length(rows[1]))
    for row in rows
        for (i, value) in enumerate(row.data)
            s = full_string(value, rndr)
            if length(s) == 0
                continue
            end
            if isa(value, Pair)
                diff = length(s) - sum(out_lengths[last(value)]) - length(colsep(rndr)) * (length(last(value))-1)
                if diff > 0
                    # increase width
                    to_add = Int(round(diff / length(last(value))))
                    out_lengths[last(value)] .+= to_add
                    if length(last(value)) * to_add < diff # did not quite add enough
                        out_lengths[last(value)[end]] += diff - length(last(value)) * to_add
                    end
                end
            else
                out_lengths[i] = max(out_lengths[i], length(s))
            end
        end
    end
    out_lengths
end

function update_widths!(row::DataRow, new_lengths, rndr)
    @assert length(row) == length(new_lengths) "Wrong number of lengths"
    for (i, value) in enumerate(row.data)
        if isa(value, Pair)
            row.colwidths[i] = sum(new_lengths[last(value)]) + length(colsep(rndr)) * (length(last(value))-1)
        else
            row.colwidths[i] = new_lengths[i]
        end
    end
end