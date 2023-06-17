
abstract type AbstractRenderType end

abstract type AbstractLatex <: AbstractRenderType end

abstract type AbstractHTML <: AbstractRenderType end

abstract type AbstractAscii <: AbstractRenderType end

struct AsciiTable <: AbstractAscii end

struct LatexTable <: AbstractLatex end

struct HTMLTable <: AbstractHTML end

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

full_string(val::Pair, rndr::AbstractAscii) = to_string(rndr, first(val))
function full_string(val::Pair, rndr::AbstractLatex, align="c")
    s = to_string(rndr, first(val))
    if length(s) == 0
        s
    else
        encapsulateRegressand(rndr, to_string(rndr, first(val)), length(last(val)), align)
    end
end
function full_string(val::Pair, rndr::AbstractHTML, align='c', print_underlines=false)
    s = to_string(rndr, first(val))
    if length(s) == 0
        s
    else
        encapsulateRegressand(rndr, s, length(last(val)), align, print_underlines)
    end
end
full_string(val, rndr, args...) = to_string(rndr, val)


function print_row(io::IO, row::DataRow, rndr::AbstractAscii)
    for (i, x) in enumerate(row.data)
        print(
            io,
            make_padding(full_string(x, rndr), row.colwidths[i], row.align[i])
        )
        if i < length(row.data)
            print(io, colsep(rndr))
        end
    end
    println(io)
    if row.print_underlines
        for (i, x) in enumerate(row.data)
            s = isa(x, Pair) ? to_string(rndr, first(x)) : to_string(rndr, x)
            if length(s) > 0
                print(io, headerrule(rndr, row.colwidths[i]))
            else
                print(io, " " ^ row.colwidths[i])
            end
            if i < length(row.data)
                print(io, colsep(rndr))
            end
        end
        println(io)
    end
end

function print_row(io::IO, row::DataRow, rndr::AbstractLatex)
    for (i, x) in enumerate(row.data)
        print(
            io,
            make_padding(full_string(x, rndr, row.align[i]), row.colwidths[i], row.align[i])
        )
        if i < length(row.data)
            print(io, colsep(rndr))
        end
    end
    println(io, " \\\\")
    if row.print_underlines
        for (i, x) in enumerate(row.data)
            s = isa(x, Pair) ? to_string(rndr, first(x)) : to_string(rndr, x)
            if length(s) == 0
                continue
            end
            if isa(x, Pair)
                print(io, headerrule(rndr, first(last(x)), last(last(x))))
            else
                print(io, headerrule(rndr, i,i))
            end
        end
        println(io)
    end
end

function print_row(io::IO, row::DataRow, rndr::AbstractHTML)
    print(io, "<tr>")
    for (i, x) in enumerate(row.data)
        if isa(x, Pair)
            s = full_string(x, rndr, row.align[i], row.print_underlines)
            if length(s) == 0
                print(io, "<td></td>")
                continue
            end
            s = make_padding(s, row.colwidths[i], row.align[i])

            print(
                io,
                s
            )
        else
            s = make_padding(to_string(rndr, x), row.colwidths[i], row.align[i])
            print(io, "<td>", s, "</td>")
        end
    end
    println(io, "</tr>")
end

Base.show(io::IO, row::DataRow) = print_row(io, row, AsciiTable())

Base.show(io::IO, mime::MIME"text/html", row::DataRow; rndr=HTMLTable()) = print_row(io, row, rndr)

Base.show(io::IO, mime::MIME"text/latex", row::DataRow; rndr=LatexTable()) = print_row(io, row, rndr)

Base.show(io::IO, mime::MIME"text/plain", row::DataRow; rndr=AsciiTable()) = print_row(io, row, rndr)

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