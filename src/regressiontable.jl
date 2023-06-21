
mutable struct RegressionTable{T<:AbstractRenderType}
    data::Vector{DataRow}
    align::String
    render::T
    breaks::Vector{Int}
    colwidths::Vector{Int}
    function RegressionTable(
        data::Vector{DataRow},
        align::String,
        rndr::T,
        breaks=[length(data)],
        colwidths::Vector{Int}=zeros(Int, length(data[1])),
    ) where {T<:AbstractRenderType}
        if all(colwidths .== 0)
            colwidths = calc_widths(data, rndr)
        end
        update_widths!.(data, Ref(colwidths), Ref(rndr))
        @assert all(length.(data) .== length(colwidths)) && length(colwidths) == length(align) "Not all the correct length"
        @assert length(data) .>= maximum(breaks) "Breaks must be less than the number of rows"
        new{T}(data,align, rndr, breaks, colwidths)
    end
end

Base.size(tab::RegressionTable) = (length(data(tab)), length(data(tab)[1]))
Base.size(tab::RegressionTable, i::Int) = size(tab)[i]
data(tab::RegressionTable) = tab.data
align(tab::RegressionTable) = tab.align
colwidths(tab::RegressionTable) = tab.colwidths

RegressionTable(header::Vector, body::Matrix, args...; vargs...) = RegressionTable(reshape(header, :, 1), body, args...; vargs...)
function RegressionTable(
    header::Matrix,
    body::Matrix,
    rndr=AsciiTable(),
    breaks=[size(header, 1)],
    align='l' * 'r' ^ (size(header, 2) - 1),
    colwidths=fill(0, size(header, 2));
    header_align='l' * 'c' ^ (size(header, 2) - 1),
    extralines::Vector = DataRow[]
) where T<:AbstractRenderType
    @assert size(body, 2) == size(header, 2) == length(colwidths) "Incorrect number of columns in table compared to header"
    @assert size(body, 1) > 0 && size(header, 1) > 0 "Table must contain at least one body, and at least one row in the first body."
    out = Vector{DataRow}()
    for i in 1:size(header, 1)
        push!(
            out,
            DataRow(
                header[i, :],
                header_align,
                colwidths,
                i < size(header, 1);# if header is last row, don't print underlines
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
            )
        )
    end
    for x in extralines
        push!(out, DataRow(x))
    end
    return RegressionTable(out, align, rndr, breaks, colwidths)
end
function (::Type{T})(tab::RegressionTable) where {T<:AbstractRenderType}
    RegressionTable(
        tab.data,
        tab.align,
        T(),
        tab.breaks,
        # colwidths not passed so it is reset to the correct widths
    )
end
# render a whole table
function Base.print(io::IO, tab::RegressionTable)

    println(io, tablestart(tab))
    println(io, toprule(tab))
    for (i, row) in enumerate(data(tab))
        print_row(io, row, tab.render)
        if i ∈ tab.breaks
            println(io, midrule(tab))
        end
    end
    println(io, bottomrule(tab))
    # print bottomrule
    println(io, tableend(tab))
end
Base.show(io::IO, tab::RegressionTable) = print(io, tab)