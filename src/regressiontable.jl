

"""
    mutable struct RegressionTable{T<:AbstractRenderType} <: AbstractMatrix{String}
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
        render::T=AsciiTable();
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

The `RegressionTable` is a subtype of the `AbstractMatrix{String}` type (though this functionality is somewhat experimental).
Importantly, this implements `getindex` and `setindex!`, which means individual elements of the table can be modified after
its construction. See examples below. It also allows a `RegressionTable` to be passed to a function that expects a matrix,
for example, exporting to a `DataFrame` [DataFrames.jl](https://github.com/JuliaData/DataFrames.jl) would be `DataFrame(Matrix(tab), :auto)`.
Note that this will not keep multicolumn, unerlines, etc. information, but could be useful for exporting to other formats.

This type also has two convenience constructors which might be helpful if using this package to print summary statistics.

## Example
```jldoctest; setup=:(using RegressionTables, RDatasets, DataFrames)
julia> df = RDatasets.dataset("datasets", "iris");

julia> df = describe(df, :mean, :std, :q25, :median, :q75; cols=["SepalLength", "SepalWidth", "PetalLength", "PetalWidth"]);

julia> t = RegressionTables.RegressionTable(names(df), Matrix(df))
 
----------------------------------------------------
variable       mean    std     q25    median    q75
----------------------------------------------------
SepalLength   5.843   0.828   5.100    5.800   6.400
SepalWidth    3.057   0.436   2.800    3.000   3.300
PetalLength   3.758   1.765   1.600    4.350   5.100
PetalWidth    1.199   0.762   0.300    1.300   1.800
----------------------------------------------------

julia> t[1, 2] = "Mean of Variable";

julia> t[2, 3] = 0;

julia> RegressionTables.update_widths!(t); # necessary if a column gets longer

julia> t
 
---------------------------------------------------------------
variable      Mean of Variable    std     q25    median    q75
---------------------------------------------------------------
SepalLength              5.843       0   5.100    5.800   6.400
SepalWidth               3.057   0.436   2.800    3.000   3.300
PetalLength              3.758   1.765   1.600    4.350   5.100
PetalWidth               1.199   0.762   0.300    1.300   1.800
---------------------------------------------------------------
```
"""
mutable struct RegressionTable{T<:AbstractRenderType} <: AbstractMatrix{String}
    data::Vector{DataRow{T}}
    align::String
    render::T
    breaks::Vector{Int}
    colwidths::Vector{Int}
    vertical_gaps::Vector{Int}# necessary for future Excel integration
    function RegressionTable(
        data::Vector{DataRow{T}},
        align::String,
        breaks=[length(data)],
        colwidths::Vector{Int}=zeros(Int, length(data[1])),
        vertical_gaps::Union{Nothing, Vector{Int}}=nothing
    ) where {T<:AbstractRenderType}
        if all(colwidths .== 0)
            colwidths = calc_widths(data)
        end
        update_widths!.(data, Ref(colwidths))
        if vertical_gaps === nothing
            vertical_gaps = find_vertical_gaps(data)
        end
        @assert all(length.(data) .== length(colwidths)) && length(colwidths) == length(align) "Not all the correct length"
        @assert length(data) .>= maximum(breaks) "Breaks must be less than the number of rows"
        new{T}(data,align, T(), breaks, colwidths, vertical_gaps)
    end
end

function find_vertical_gaps(data::Vector{DataRow{T}}) where T
    out = Set{Int}()
    for row in data
        i = 0
        for (j, x) in enumerate(row.data)
            if isa(x, Pair)
                i += length(last(x))
            else
                i += 1
            end
            if row.print_underlines[j] && i < length(row)
                push!(out, i)
            end
        end
    end
    sort(collect(out))
end

Base.size(tab::RegressionTable) = (length(data(tab)), length(data(tab)[1]))
Base.size(tab::RegressionTable, i::Int) = size(tab)[i]
Base.getindex(tab::RegressionTable, i::Int, j::Int) = data(tab)[i][j]
Base.setindex!(tab::RegressionTable, val, i::Int, j::Int) = data(tab)[i][j] = val
Base.getindex(tab::RegressionTable, i::Int) = data(tab)[i]
function Base.setindex!(tab::RegressionTable{T}, val::DataRow, i::Int) where {T<:AbstractRenderType}
    data(tab)[i] = T(val)
    update_widths!(tab)
    tab
end

Base.setindex!(tab::RegressionTable, val::AbstractVector, i::Int) = setindex!(tab, DataRow(val), i)
function Base.insert!(tab::RegressionTable{T}, i::Int, row:: DataRow) where {T<:AbstractRenderType}
    @assert length(row) == length(data(tab)[2]) "Row is not the correct length"
    x = T(row)
    insert!(data(tab), i, x)
    update_widths!(tab)
    tab
end

Base.insert!(tab::RegressionTable, i::Int, row::AbstractVector) = insert!(tab, i, DataRow(row))

function update_widths!(tab::RegressionTable)
    colwidths = calc_widths(data(tab))
    update_widths!.(data(tab), Ref(colwidths))
    tab.colwidths = colwidths
    tab
end


data(tab::RegressionTable) = tab.data
align(tab::RegressionTable) = tab.align
colwidths(tab::RegressionTable) = tab.colwidths

function (::Type{T})(tab::RegressionTable) where T<:AbstractRenderType
    RegressionTable(
        T.(data(tab)),
        align(tab),
        tab.breaks,
    )
end

RegressionTable(header::Vector, body::Matrix, args...; vargs...) = RegressionTable(reshape(header, 1, :), body, args...; vargs...)
function RegressionTable(
    header::Matrix,
    body::Matrix,
    render::T=AsciiTable();
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
Base.show(io::IO, x::MIME{Symbol("text/plain")}, tab::RegressionTable) = show(io, tab) # ignore mime type since a display type is already specified
Base.display(tab::RegressionTable) = show(tab)
Base.display(v::MIME, tab::RegressionTable) = show(tab)

function Base.write(x::String, tab::RegressionTable)
    open(x, "w") do io
        print(io, tab)
    end
end