
abstract type AbstractRenderType end

Base.broadcastable(o::AbstractRenderType) = Ref(o)

struct DataRow{T<:AbstractRenderType}
    data::Vector
    align::String
    colwidths::Vector{Int}
    print_underlines::Bool
    rndr::T
    function DataRow(
        data::Vector,
        align="l" * "r" ^ (length(data) - 1),
        colwidths=fill(0, length(data)),
        print_underlines::Bool=false,
        rndr::T=AsciiTable();
        combine_equals=print_underlines
    ) where {T<:AbstractRenderType}
        @assert length(data) == length(colwidths) == length(align) "Not all the correct length"
        if combine_equals
            values = []
            new_align = ""
            new_widths = Int[]
            x = first(data)
            j_start = firstindex(data)
            j_end = firstindex(data)
            for i in eachindex(data)
                if data[i] != x
                    if x == ""
                        for i in j_start:j_end
                            push!(values, x)
                            new_align *= align[i]
                            push!(new_widths, colwidths[i])
                        end
                    else
                        push!(values, x => j_start:j_end)
                        new_align *= align[j_start]
                        push!(new_widths, sum(colwidths[j_start:j_end]))
                    end
                    x = data[i]
                    j_start = i
                    j_end = i
                else
                    j_end = i
                end
            end
            if x == ""
                for i in j_start:j_end
                    push!(values, x)
                    new_align *= align[i]
                    push!(new_widths, colwidths[i])
                end
            else
                push!(values, x => j_start:j_end)
                new_align *= align[j_start]
                push!(new_widths, sum(colwidths[j_start:j_end]))
            end
            new{T}(values, new_align, new_widths, print_underlines, rndr)
        else
            new{T}(data, align, colwidths, print_underlines, rndr)
        end
    end
end
DataRow(x::DataRow) = x
(::Type{T})(x::DataRow) where {T<:AbstractRenderType} = DataRow(x.data, x.align, x.colwidths, x.print_underlines, T())

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

Base.show(io::IO, row::DataRow) = print(io, row)

function calc_widths(rows::Vector{DataRow{T}}) where {T<:AbstractRenderType}
    out_lengths = fill(0, length(rows[1]))
    for row in rows
        for (i, value) in enumerate(row.data)
            s = T(value)
            if length(s) == 0
                continue
            end
            if isa(value, Pair)
                diff = length(s) - sum(out_lengths[last(value)]) - length(colsep(T())) * (length(last(value))-1)
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

function update_widths!(row::DataRow{T}, new_lengths) where {T}
    #@assert length(row) == length(new_lengths) "Wrong number of lengths"
    x = 1
    for (i, value) in enumerate(row.data)
        if isa(value, Pair)
            row.colwidths[i] = sum(new_lengths[last(value)]) + length(colsep(T())) * (length(last(value))-1)
            x += length(last(value))
        else
            row.colwidths[i] = new_lengths[x]
            x += 1
        end
    end
end