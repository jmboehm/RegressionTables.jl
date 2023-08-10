

"""
    mutable struct RegressionTable{T<:AbstractRenderType}
        data::Vector{DataRow{T}}
        align::String
        render::T
        breaks::Vector{Int}
        colwidths::Vector{Int}
    end

    RegressionTable(header::Vector, body::Matrix, args...; vargs...)
    RegressionTable(
        header::Matrix,
        body::Matrix,
        rndr::T=AsciiTable();
        breaks=[size(header, 1)],
        align='l' * 'r' ^ (size(header, 2) - 1),
        colwidths=fill(0, size(header, 2)),
        header_align='l' * 'c' ^ (size(header, 2) - 1),
        extralines::Vector = DataRow[]
    ) where T<:AbstractRenderType

The general container. This provides some general information about the table. The [`DataRow`](@ref) handles the main printing,
but this provides other necessary information, especially the `break` field, which is used to determine where to put the
lines (e.g., `\\midrule` in LaTeX).
- `data`: A vector of [`DataRow`](@ref) objects.
- `align`: A string of characters, one for each column, indicating the alignment of the column. The characters are
    `l` for left, `c` for center, and `r` for right.
- `render`: The render type of the table. This must be the same as the render type of the [`DataRow`](@ref) objects and is used for convenience.
- `breaks`: A vector of integers, indicating where to put the lines (e.g., `\\midrule` in LaTeX). When displayed, the break will be placed after
   the line number is printed (breaks = [5] will print a break after the 5th line is printed).
- `colwidths`: A vector of integers, one for each column, indicating the width of the column. Can calculate the widths
    automatically using [`calc_widths`](@ref) and update them with [`update_widths!`](@ref).

This type also has two convenience constructors which might be helpful if using this package to print summary statistics.

## Example
```jldoctest; setup=:(using RegressionTables, RDatasets, DataFrames)
df = RDatasets.dataset("datasets", "iris");
df = describe(df, :mean, :std, :q25, :median, :q75; cols=["SepalLength", "SepalWidth", "PetalLength", "PetalWidth"]);
RegressionTables.RegressionTable(names(df), Matrix(df))

# output

 
----------------------------------------------------
variable       mean    std     q25    median    q75
----------------------------------------------------
SepalLength   5.843   0.828   5.100    5.800   6.400
SepalWidth    3.057   0.436   2.800    3.000   3.300
PetalLength   3.758   1.765   1.600    4.350   5.100
PetalWidth    1.199   0.762   0.300    1.300   1.800
----------------------------------------------------
```
"""
mutable struct RegressionTable{T<:AbstractRenderType}
    data::Vector{DataRow{T}}
    align::String
    render::T
    breaks::Vector{Int}
    colwidths::Vector{Int}
    function RegressionTable(
        data::Vector{DataRow{T}},
        align::String,
        breaks=[length(data)],
        colwidths::Vector{Int}=zeros(Int, length(data[1])),
    ) where {T<:AbstractRenderType}
        if all(colwidths .== 0)
            colwidths = calc_widths(data)
        end
        update_widths!.(data, Ref(colwidths))
        @assert all(length.(data) .== length(colwidths)) && length(colwidths) == length(align) "Not all the correct length"
        @assert length(data) .>= maximum(breaks) "Breaks must be less than the number of rows"
        new{T}(data,align, T(), breaks, colwidths)
    end
end

Base.size(tab::RegressionTable) = (length(data(tab)), length(data(tab)[1]))
Base.size(tab::RegressionTable, i::Int) = size(tab)[i]
data(tab::RegressionTable) = tab.data
align(tab::RegressionTable) = tab.align
colwidths(tab::RegressionTable) = tab.colwidths

RegressionTable(header::Vector, body::Matrix, args...; vargs...) = RegressionTable(reshape(header, 1, :), body, args...; vargs...)
function RegressionTable(
    header::Matrix,
    body::Matrix,
    rndr::T=AsciiTable();
    breaks=[size(header, 1)],
    align='l' * 'r' ^ (size(header, 2) - 1),
    colwidths=fill(0, size(header, 2)),
    header_align='l' * 'c' ^ (size(header, 2) - 1),
    extralines::Vector = DataRow[]
) where T<:AbstractRenderType
    @assert size(body, 2) == size(header, 2) == length(colwidths) "Incorrect number of columns in table compared to header"
    @assert size(body, 1) > 0 && size(header, 1) > 0 "Table must contain at least one body, and at least one row in the first body."
    out = Vector{DataRow{T}}()
    for i in 1:size(header, 1)
        push!(
            out,
            DataRow(
                header[i, :],
                header_align,
                colwidths,
                fill(i < size(header, 1), size(header, 2)),
                T();# if header is last row, don't print underlines
                combine_equals=i < size(header, 1)
            )
        )
    end
    for i in 1:size(body, 1)
        push!(
            out,
            DataRow(
                body[i, :],
                align,
                colwidths,
                fill(false, size(header, 2)),
                T()
            )
        )
    end
    for x in extralines
        push!(out, T(DataRow(x)))
    end
    return RegressionTable(out, align, breaks, colwidths)
end
# render a whole table
function Base.print(io::IO, tab::RegressionTable)

    println(io, tablestart(tab))
    println(io, toprule(tab))
    for (i, row) in enumerate(data(tab))
        println(io, row)
        if i ∈ tab.breaks
            println(io, midrule(tab))
        end
    end
    println(io, bottomrule(tab))
    # print bottomrule
    println(io, tableend(tab))
end
Base.show(io::IO, tab::RegressionTable) = print(io, tab)

function Base.write(x::String, tab::RegressionTable)
    open(x, "w") do io
        print(io, tab)
    end
end