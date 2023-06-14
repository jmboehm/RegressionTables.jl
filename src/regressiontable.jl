
abstract type AbstractRenderType end

abstract type AbstractLatex <: AbstractRenderType end

abstract type AbstractHTML <: AbstractRenderType end

abstract type AbstractAscii <: AbstractRenderType end

struct AsciiTable <: AbstractAscii end

struct LatexTable <: AbstractLatex end

struct HTMLTable <: AbstractHTML end

function (::Type{T})(
    header,
    body,
    breaks=[size(body, 1)],
    align='l' * 'r' ^ (size(header, 2) - 1),
    colwidths=fill(0, size(header, 2));
) where T<:AbstractRenderType
    @assert size(body, 2) == size(header, 2) == length(colwidths) "Incorrect number of columns in table compared to header"
    @assert size(body, 1) > 0 && size(header, 1) > 0 "Table must contain at least one body, and at least one row in the first body."
    return T(header, body, breaks, align, colwidths)
end
function (::Type{T})(tab::AbstractRenderType) where {T<:AbstractRenderType}
    T(
        tab.header,
        tab.body,
        tab.breaks,
        tab.align,
        tab.colwidths,
        tab.overrides,
        tab.digits,
        tab.below_digits,
        tab.statistic_digits
    )
end

Base.size(tab::AbstractRenderType, args...) = size(body(tab), args...)
body(tab::AbstractRenderType) = tab.body
header(tab::AbstractRenderType) = tab.header
align(tab::AbstractRenderType) = tab.align
colwidths(tab::AbstractRenderType) = tab.colwidths


sections(tab::AbstractRenderType) = length(tab.beraks)
function section(tab::AbstractRenderType, i::Int)
    if i == 1
        return body(tab)[1:tab.breaks[1]]
    else
        return body(taB)[tab.breaks[i-1]+1:tab.breaks[i]]
    end
end

mutable struct RegressionTable{T<:AbstractRenderType}
    header::Matrix
    body::Matrix
    breaks::Vector{Int}
    align::String
    colwidths::Vector{Int}
    render::T
end
