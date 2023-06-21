
abstract type AbstractRenderType end

full_string(val, rndr, args...) = to_string(rndr, val)

label_p(rndr::AbstractRenderType) = "p"

wrapper(rndr::AbstractRenderType, s) = s

interaction_combine(rndr::AbstractRenderType) = " & "
categorical_equal(rndr::AbstractRenderType) = ":"

round_digits(rndr::AbstractRenderType, x::AbstractRegressionStatistic) = round_digits(rndr, value(x))
round_digits(rndr::AbstractRenderType, x::AbstractUnderStatistic) = round_digits(rndr, value(x))
round_digits(rndr::AbstractRenderType, x::CoefValue) = round_digits(rndr, value(x))
round_digits(rndr::AbstractRenderType, x) = 3

to_string(rndr::AbstractRenderType, x; args...) = "$x"
to_string(rndr::AbstractRenderType, x::Int; args...) = format(x, commas=true)
to_string(rndr::AbstractRenderType, x::Float64; digits=round_digits(rndr, x)) = format(x, precision=digits)
to_string(rndr::AbstractRenderType, x::Nothing; args...) = ""
to_string(rndr::AbstractRenderType, x::Missing; args...) = ""
to_string(rndr::AbstractRenderType, x::AbstractString; args...) = String(x)
to_string(rndr::AbstractRenderType, x::Bool; args...) = x ? "Yes" : ""
to_string(rndr::AbstractRenderType, x::AbstractRegressionStatistic; digits=round_digits(rndr, x)) = to_string(rndr, value(x); digits)
to_string(rndr::AbstractRenderType, x::AbstractUnderStatistic; digits=round_digits(rndr, x)) = "(" * to_string(rndr, value(x); digits) * ")"
to_string(rndr::AbstractRenderType, x::CoefValue; digits=round_digits(rndr, x)) = estim_decorator(rndr, to_string(rndr, value(x); digits), x.pvalue)
to_string(rndr::AbstractRenderType, x::RegressionType; args...) = to_string(rndr, value(x))
to_string(rndr::AbstractRenderType, x::Type{T}; args...) where {T <: AbstractRegressionStatistic} = label(rndr, T)
to_string(rndr::AbstractRenderType, x::Type{RegressionType}; args...) = label(rndr, x)
to_string(rndr::AbstractRenderType, x::Tuple) = join(to_string.(Ref(rndr), x), " ")
to_string(rndr::AbstractRenderType, x::AbstractCoefName) = to_string(rndr, value(x))
to_string(rndr::AbstractRenderType, x::InteractedCoefName) = join(to_string.(Ref(rndr), values(x)), interaction_combine(rndr))
to_string(rndr::AbstractRenderType, x::CategoricalCoefName) = "$(value(x))$(categorical_equal(rndr)) $(x.level)"
to_string(rndr::AbstractRenderType, x::InterceptCoefName) = "(Intercept)"


function make_padding(s, colWidth, align)
    if align == 'l'
        s = rpad(s, colWidth)
    elseif align == 'r'
        s = lpad(s, colWidth)
    elseif align == 'c'
        diff = colWidth - length(s)
        l = iseven(diff) ? Int64((diff)/2) : Int64((diff+1)/2)
        r = iseven(diff) ? Int64((diff)/2) : Int64((diff-1)/2)
        # if the printstring is too long, so be it
        l = max(l,0)
        r = max(r,0)
        s = (" " ^ l) * s * (" " ^ r)
    end
    s
end
