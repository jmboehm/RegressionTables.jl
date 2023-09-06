
"""
    abstract type AbstractRenderType end

The generic top level type for render types. Most defaults are set here unless there is a reason it needs to be set at
a lower level. Subtypes are still abstract types and include [`AbstractAscii`](@ref), [`AbstractLatex`](@ref), and [`AbstractHtml`](@ref).
"""
abstract type AbstractRenderType end

Base.broadcastable(o::AbstractRenderType) = Ref(o)

"""
    mutable struct DataRow{T<:AbstractRenderType} <: AbstractVector{String}
        data::Vector
        align::String
        colwidths::Vector{Int}
        print_underlines::Vector{Bool}
        render::T
    end

    DataRow(x::DataRow) = x

    (::Type{T})(x::DataRow) where {T<:AbstractRenderType} = DataRow(x.data, x.align, x.colwidths, x.print_underlines, T())

    function DataRow(
        data::Vector,
        align,
        colwidths,
        print_underlines,
        render::AbstractRenderType;
        combine_equals=false
    )

    function DataRow(
        data::Vector;
        align="l" * "r" ^ (length(data) - 1),
        colwidths=fill(0, length(data)),
        print_underlines=zeros(Bool, length(data)),
        render::AbstractRenderType=AsciiTable(),
        combine_equals=false
    )

DataRow forms the fundamental element of a RegressionTable. For a user, these can be passed as 
additional elements to `group` or `extralines` in [`regtable`](@ref).
A DataRow is typed with an [`AbstractRenderType`](@ref),
which controls how the DataRow is displayed. The default is [`AsciiTable`](@ref). The DataRow contains four other elements:
- `data::Vector`: The data to be displayed in the row. Can be individual elements (e.g., [1, 2, 3]) or pairs with a range
   (e.g., [1 => 1:2, 2 => 3:4]), or a combination of the two.
- `align::String`: A string of ('l', 'r', 'c'), one for each element of `data`, indicating that elements alignment.
- `colwidths::Vector{Int}`: A vector of integers, one for each element of `data`, indicating the width of the column.
   Can calculate the widths automatically using [`calc_widths`](@ref) and update them with [`update_widths!`](@ref).
- `print_underlines::Vector{Bool}`: A vector of booleans, one for each element of `data`, indicating whether to print
   an underline under the element. This is useful for printing the header of a table.

DataRow is a subtype of `AbstractVector{String}`. It implements `getindex` and `setindex!`, which allows changing of individual
elements.

!!! note
    In most cases, it is not necessary to specify the render type for DataRow. While constructing a RegressionTable,
    the render type is changed to the render type of the RegressionTable.

## Examples

```jldoctest
julia> DataRow(["", "Group 1" => 2:3, "Group 2" => 4:5])
   Group 1   Group 2

julia> DataRow(["", "Group 1", "Group 1", "Group 2", "Group 2"]; combine_equals=true)
   Group 1   Group 2

julia> DataRow(["", "Group 1" => 2:3, "Group 2" => 4:5])
   Group 1   Group 2

julia> DataRow(["   ", "Group 1" => 2:3, "Group 2" => 4:5]; print_underlines=[false, false, true])
      Group 1   Group 2
                -------

julia> DataRow(["Group 0", "Group 1" => 2:3, "Group 2" => 4:5]; colwidths=[20, 20, 20], align="lcr", print_underlines=true)
Group 0                       Group 1                      Group 2
--------------------   --------------------   --------------------

julia> DataRow(["", "Group 1" => 2:3, "Group 2" => 4:5]; render=LatexTable())
 & \\multicolumn{2}{r}{Group 1} & \\multicolumn{2}{r}{Group 2} \\\\ 
```
"""
mutable struct DataRow{T<:AbstractRenderType} <: AbstractVector{String}
    data::Vector
    align::String
    colwidths::Vector{Int}
    print_underlines::Vector{Bool}
    render::T
    function DataRow(
        data::Vector,
        align,
        colwidths,
        print_underlines,
        render::T;
        combine_equals=false
    ) where {T<:AbstractRenderType}
        @assert length(data) == length(colwidths) == length(align) == length(print_underlines) "Not all the correct length"
        if combine_equals
            x = new{T}([], "", Int[], Bool[], render)
            for i in eachindex(data, colwidths, print_underlines)
                add_element!(x, data[i], align[i], colwidths[i], print_underlines[i], i)
            end
        else
            x = new{T}(data, align, colwidths, print_underlines, render)
        end
        if all(x.colwidths .== 0)
            update_widths!(x)
            x
        else
            x
        end
    end
end
DataRow(x::DataRow) = x
(::Type{T})(x::DataRow) where {T<:AbstractRenderType} = DataRow(x.data, x.align, x.colwidths, x.print_underlines, T())
function DataRow(
    data::Vector;
    align="l" * "r" ^ (length(data) - 1),
    colwidths=fill(0, length(data)),
    print_underlines=zeros(Bool, length(data)),
    render::AbstractRenderType=AsciiTable(),
    combine_equals=false
)
    if isa(print_underlines, Bool)
        print_underlines = fill(print_underlines, length(data))
    end
    DataRow(data, align, colwidths, print_underlines, render; combine_equals)
end

"""
    add_element!(row::DataRow, val, align_i, colwidth_i, print_underline_i, i)

Adds an element to the row and is only called when `combine_equals=true`. This means that if the last
element in the row is the same as the provided `val`, then the last element is extended to include the new column.
"""
function add_element!(row::DataRow, val, align_i, colwidth_i, print_underline_i, i)
    if val == ""
        push!(row.data, val)
        row.align *= align_i
        push!(row.colwidths, colwidth_i)
        push!(row.print_underlines, print_underline_i)        
    elseif length(row.data) == 0
        push!(row.data, val => i:i)
        row.align *= align_i
        push!(row.colwidths, colwidth_i)
        push!(row.print_underlines, print_underline_i)        
    else
        prev = last(row.data)
        if isa(prev, Pair)
            if prev[1] == val # if same as previous value, then modify that value to extend extra column
                row.data[end] = prev[1] => prev[2][1]:i
                row.colwidths[end] += colwidth_i
            else
                push!(row.data, val => i:i)
                row.align *= align_i
                push!(row.colwidths, colwidth_i)
                push!(row.print_underlines, print_underline_i)                
            end
        else
            if prev == val
                row.data[end] = prev => i-1:i
                row.colwidths[end] += colwidth_i
            else
                push!(row.data, val => i:i)
                row.align *= align_i
                push!(row.colwidths, colwidth_i)
                push!(row.print_underlines, print_underline_i)                
            end
        end
    end
    row
end

"""
    add_element!(row::DataRow, val::Pair, align_i, colwidth_i, print_underline_i, i)

Adds an element to the row and is only called when `combine_equals=true`. Since `val` is a pair,
is is simply added to the row as is, this allows for the creation of two multicolumn cells that
have the same information but are separate.
"""
function add_element!(row::DataRow, val::Pair, align_i, colwidth_i, print_underline_i, i)
    # if it is a pair, add as is even if previous element has same initial value
    push!(row.data, val)
    row.align *= align_i
    push!(row.colwidths, colwidth_i)
    push!(row.print_underlines, print_underline_i)
    row
end

Base.size(x::DataRow) = (length(x.data),)
function Base.getindex(row::DataRow{T}, i) where {T}
    v = 0
    for x in row.data
        if isa(x, Pair)
            v += length(last(x))
        else
            v += 1
        end
        if v >= i
            return repr(T(), x)
        end
    end
    error("Index $i out of bounds")
end
function Base.setindex!(row::DataRow, val, i)
    v = 0
    for j in eachindex(row.data)
        x = row.data[j]
        if isa(x, Pair)
            v += length(last(x))
        else
            v += 1
        end
        if v >= i
            row.data[j] = val
            return val
        end
    end
    error("Index $i out of bounds")
end
Base.IndexStyle(::Type{<:DataRow}) = IndexLinear()
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

Base.show(io::IO, x::MIME{Symbol("text/plain")}, row::DataRow) = show(io, row)

Base.display(row::DataRow) = show(row)
Base.display(x::MIME, row::DataRow) = show(row)

"""
    calc_widths(rows::Vector{DataRow{T}}) where {T<:AbstractRenderType}

Calculate the widths of each column in the table. For rows with multicolumn cells, the width of the multicolumn is divided evenly
among the columns it spans.
"""
function calc_widths(rows::Vector{DataRow{T}}) where {T<:AbstractRenderType}
    render = T()
    out_lengths = fill(0, length(rows[1]))
    for row in rows
        for (i, value) in enumerate(row.data)
            s = repr(render, value)
            if length(s) == 0
                continue
            end
            if isa(value, Pair)
                diff = length(s) - sum(out_lengths[last(value)]) - length(colsep(render)) * (length(last(value))-1)
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

"""
    update_widths!(row::DataRow{T}, new_lengths=length.(repr.(T(), row.data))) where {T}

Updates the widths of each column in the row. If lengths are provided, then it should equate to the total number
of columns in the table, not the number of elements in the row.
"""
function update_widths!(row::DataRow{T}, new_lengths=length.(repr.(T(), row.data))) where {T}
    #@assert length(row) == length(new_lengths) "Wrong number of lengths"
    render = T()
    if length(row.data) == length(new_lengths)
        row.colwidths = new_lengths
        return row
    end
    x = 1
    for (i, value) in enumerate(row.data)
        if isa(value, Pair)
            row.colwidths[i] = sum(new_lengths[last(value)]) + length(colsep(render)) * (length(last(value))-1)
            x += length(last(value))
        else
            row.colwidths[i] = new_lengths[x]
            x += 1
        end
    end
end