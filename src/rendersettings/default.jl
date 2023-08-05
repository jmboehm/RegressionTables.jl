
label_p(rndr::AbstractRenderType) = "p"

wrapper(rndr::AbstractRenderType, s) = s

interaction_combine(rndr::AbstractRenderType) = " & "
categorical_equal(rndr::AbstractRenderType) = ":"

default_ols_label(rndr::AbstractRenderType) = "OLS"
default_iv_label(rndr::AbstractRenderType) = "IV"



(::Type{T})(x; args...) where {T <: AbstractRenderType} = "$x"
(::Type{T})(x::Pair; args...) where {T <: AbstractRenderType} = T(first(x); args...)
(::Type{T})(x::Int; args...) where {T <: AbstractRenderType} = format(x, commas=true)
(::Type{T})(x::Float64; digits=default_round_digits(T(), x), args...) where {T <: AbstractRenderType} = format(x, precision=digits, commas=true)
(::Type{T})(x::Nothing; args...) where {T <: AbstractRenderType} = ""
(::Type{T})(x::Missing; args...) where {T <: AbstractRenderType} = ""
(::Type{T})(x::AbstractString; args...) where {T <: AbstractRenderType} = String(x)
(::Type{T})(x::Bool; args...) where {T <: AbstractRenderType} = x ? "Yes" : ""
(::Type{T})(x::AbstractRegressionStatistic; digits=default_round_digits(T(), x), args...) where {T <: AbstractRenderType} = T(value(x); digits, args...)
(::Type{T})(x::AbstractR2; digits=default_round_digits(T(), x), args...) where {T <: AbstractRenderType} = T(value(x); digits, args...)
(::Type{T})(x::AbstractUnderStatistic; digits=default_round_digits(T(), x), args...) where {T <: AbstractRenderType} = "(" * T(value(x); digits, args...) * ")"
(::Type{T})(x::CoefValue; digits=default_round_digits(T(), x), args...) where {T <: AbstractRenderType} = estim_decorator(T(), T(value(x); digits, args...), x.pvalue)
(::Type{T})(x::Type{V}; args...) where {T <:AbstractRenderType, V <: AbstractRegressionStatistic} = label(T(), V)
(::Type{T})(x::Type{RegressionType}; args...) where {T <: AbstractRenderType} = label(T(), x)
(::Type{T})(x::Tuple; args...) where {T <: AbstractRenderType} = join(T.(x; args...), " ")
(::Type{T})(x::AbstractCoefName; args...) where {T <: AbstractRenderType} = T(value(x); args...)
(::Type{T})(x::InteractedCoefName; args...) where {T <: AbstractRenderType} = join(T.(values(x); args...), interaction_combine(T()))
(::Type{T})(x::CategoricalCoefName; args...) where {T <: AbstractRenderType} = "$(value(x))$(categorical_equal(T())) $(x.level)"
(::Type{T})(x::InterceptCoefName; args...) where {T <: AbstractRenderType} = "(Intercept)"
(::Type{T})(x::HasControls; args...) where {T <: AbstractRenderType} = T(value(x); args...)
(::Type{T})(x::Type{V}; args...) where {T <: AbstractRenderType, V <: HasControls} = label(T(), V)

(::Type{T})(x::RegressionType; args...) where {T<: AbstractRenderType} = x.is_iv ? T(default_iv_label(T()); args...) : T(value(x); args...)
(::Type{T})(x::D;args...) where {T<: AbstractRenderType, D<:UnivariateDistribution} = T(string(Base.typename(D).wrapper); args...)
(::Type{T})(x::InverseGaussian; args...) where {T<: AbstractRenderType} = T("Inverse Gaussian"; args...)
(::Type{T})(x::NegativeBinomial; args...) where {T<: AbstractRenderType} = T("Negative Binomial"; args...)
(::Type{T})(x::Normal; args...) where {T<: AbstractRenderType,} = T(default_ols_label(T()); args...)

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
