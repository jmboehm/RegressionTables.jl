
label_p(rndr::AbstractRenderType) = "p"

wrapper(rndr::AbstractRenderType, s) = s

"""
    interaction_combine(rndr::AbstractRenderType)

Used to separate pieces of [`InteractedCoefName`](@ref) and defaults to " & ". 
"""
interaction_combine(rndr::AbstractRenderType) = " & "
categorical_equal(rndr::AbstractRenderType) = ":"

default_ols_label(rndr::AbstractRenderType) = "OLS"
default_iv_label(rndr::AbstractRenderType) = "IV"


"""
    (::Type{T})(x; args...) where {T <: AbstractRenderType}

Will render x as a string
"""
(::Type{T})(x; args...) where {T <: AbstractRenderType} = "$x"

"""
    (::Type{T})(x::Pair; args...) where {T <: AbstractRenderType}

By default, will render the first element of the pair according to the render type. In cases of [`AbstractLatex`](@ref)
or [`AbstractHTML`](@ref), uses the second element to determine number of columns to span.
"""
(::Type{T})(x::Pair; args...) where {T <: AbstractRenderType} = T(first(x); args...)

"""
    (::Type{T})(x::Int; args...) where {T <: AbstractRenderType}

By default, will render the integer with commas
"""
(::Type{T})(x::Int; args...) where {T <: AbstractRenderType} = format(x, commas=true)

"""
    (::Type{T})(x::Float64; digits=default_round_digits(T(), x), commas=true, str_format=nothing, args...) where {T <: AbstractRenderType}

By default, will render the float with commas and the default number of digits. If `str_format` is specified, will use
that instead of `digits` and `commas`
"""
function (::Type{T})(x::Float64; digits=default_round_digits(T(), x), commas=true, str_format=nothing, args...) where {T <: AbstractRenderType}
    if str_format !== nothing
        sprintf1(str_format, x)
    else
        format(x; precision=digits, commas)
    end
end

"""
    (::Type{T})(x::Nothing; args...) where {T <: AbstractRenderType}

By default, will render the nothing as an empty string
"""
(::Type{T})(x::Nothing; args...) where {T <: AbstractRenderType} = ""

"""
    (::Type{T})(x::Missing; args...) where {T <: AbstractRenderType}

By default, will render the missing as an empty string
"""
(::Type{T})(x::Missing; args...) where {T <: AbstractRenderType} = ""

"""
    (::Type{T})(x::AbstractString; args...) where {T <: AbstractRenderType}

By default, will render the string as is
"""
(::Type{T})(x::AbstractString; args...) where {T <: AbstractRenderType} = String(x)

"""
    (::Type{T})(x::Bool; args...) where {T <: AbstractRenderType}

By default, will render the boolean as "Yes" or ""
"""
(::Type{T})(x::Bool; args...) where {T <: AbstractRenderType} = x ? "Yes" : ""

"""
    (::Type{T})(x::AbstractRegressionStatistic; digits=default_round_digits(T(), x), args...) where {T <: AbstractRenderType}

By default, will render the statistic with commas and the default number of digits
"""
(::Type{T})(x::AbstractRegressionStatistic; digits=default_round_digits(T(), x), args...) where {T <: AbstractRenderType} = T(value(x); digits, args...)

"""
    (::Type{T})(x::AbstractR2; digits=default_round_digits(T(), x), args...) where {T <: AbstractRenderType}

By default, will render the same as `AbstractRegressionStatistic`
"""
(::Type{T})(x::AbstractR2; digits=default_round_digits(T(), x), args...) where {T <: AbstractRenderType} = T(value(x); digits, args...)

"""
    (::Type{T})(x::AbstractUnderStatistic; digits=default_round_digits(T(), x), args...) where {T <: AbstractRenderType}

By default, will render with the default number of digits and surrounded by parentheses `(1.234)`
"""
(::Type{T})(x::AbstractUnderStatistic; digits=default_round_digits(T(), x), args...) where {T <: AbstractRenderType} = "(" * T(value(x); digits, commas=false, args...) * ")"

"""
    (::Type{T})(x::ConfInt; digits=default_round_digits(T(), x), args...) where {T <: AbstractRenderType}

By default, will render with the default number of digits and surrounded by parentheses `(1.234, 5.678)`
"""
(::Type{T})(x::ConfInt; digits=default_round_digits(T(), x), args...) where {T <: AbstractRenderType} = "(" * T(value(x)[1]; digits) * ", " * T(value(x)[2]; digits) * ")"

"""
    (::Type{T})(x::CoefValue; digits=default_round_digits(T(), x), args...) where {T <: AbstractRenderType}

By default, will render with the default number of digits and surrounded by parentheses and will call [`estim_decorator`](@ref) for the decoration
"""
(::Type{T})(x::CoefValue; digits=default_round_digits(T(), x), args...) where {T <: AbstractRenderType} = estim_decorator(T(), T(value(x); digits, commas=false, args...), x.pvalue)

"""
    (::Type{T})(x::Type{V}; args...) where {T <:AbstractRenderType, V <: AbstractRegressionStatistic}

By default, will call the `label` function related to the type
"""
(::Type{T})(x::Type{V}; args...) where {T <:AbstractRenderType, V <: AbstractRegressionStatistic} = label(T(), V)

"""
    (::Type{T})(x::Type{RegressionType}; args...) where {T <: AbstractRenderType}

By default, will call the `label` function related to the `RegressionType`
"""
(::Type{T})(x::Type{RegressionType}; args...) where {T <: AbstractRenderType} = label(T(), x)

"""
    (::Type{T})(x::Tuple; args...) where {T <: AbstractRenderType}    

By default, will render the tuple with spaces between the elements
"""
(::Type{T})(x::Tuple; args...) where {T <: AbstractRenderType} = join(T.(x; args...), " ")

"""
    (::Type{T})(x::AbstractCoefName; args...) where {T <: AbstractRenderType}

By default, will render the name of the coefficient, also see [Regression Statistics](@ref)
"""
(::Type{T})(x::AbstractCoefName; args...) where {T <: AbstractRenderType} = T(value(x); args...)

"""
    (::Type{T})(x::FixedEffectCoefName; args...) where {T <: AbstractRenderType}

By default, will render the coefficient and add `" Fixed Effects"` as a suffix, also see [Regression Statistics](@ref)
"""
(::Type{T})(x::FixedEffectCoefName; args...) where {T <: AbstractRenderType} = T(value(x); args...) * " Fixed Effects"

"""
    (::Type{T})(x::InteractedCoefName; args...) where {T <: AbstractRenderType}

By default, will render the coefficient and add the `interaction_combine` function as a separator, also see [Regression Statistics](@ref)
"""
(::Type{T})(x::InteractedCoefName; args...) where {T <: AbstractRenderType} = join(T.(values(x); args...), interaction_combine(T()))

"""
    (::Type{T})(x::CategoricalCoefName; args...) where {T <: AbstractRenderType}

By default, will render the coefficient and add the `categorical_equal` function as a separator, also see [Regression Statistics](@ref)
"""
(::Type{T})(x::CategoricalCoefName; args...) where {T <: AbstractRenderType} = "$(value(x))$(categorical_equal(T())) $(x.level)"

"""
    (::Type{T})(x::InterceptCoefName; args...) where {T <: AbstractRenderType}

By default, will render the coefficient as `(Intercept)`, also see [Regression Statistics](@ref)
"""
(::Type{T})(x::InterceptCoefName; args...) where {T <: AbstractRenderType} = "(Intercept)"

"""
    (::Type{T})(x::HasControls; args...) where {T <: AbstractRenderType}

By default, will render the same as `Bool` ("Yes" and "")
"""
(::Type{T})(x::HasControls; args...) where {T <: AbstractRenderType} = T(value(x); args...)

"""
    (::Type{T})(x::RegressionNumbers; args...) where {T <: AbstractRenderType}

By default, will render the number in parentheses (e.g., "(1)", "(2)"...)
"""
(::Type{T})(x::RegressionNumbers; args...) where {T <: AbstractRenderType} = "(" * T(value(x); args...) * ")"

"""
    (::Type{T})(x::Type{V}; args...) where {T <: AbstractRenderType, V <: HasControls}

By default, will call the `label` function related to the type
"""
(::Type{T})(x::Type{V}; args...) where {T <: AbstractRenderType, V <: HasControls} = label(T(), V)

"""
    (::Type{T})(x::RegressionType; args...) where {T<: AbstractRenderType}

By default, will check if the `RegressionType` is an instrumental variable regression and call the `label` function related to the type.
If it is an instrumental variable, will then call [`default_iv_label`](@ref), otherwise it will call the related distribution.
"""
(::Type{T})(x::RegressionType; args...) where {T<: AbstractRenderType} = x.is_iv ? T(default_iv_label(T()); args...) : T(value(x); args...)

"""
    (::Type{T})(x::D; args...) where {T<: AbstractRenderType, D<:UnivariateDistribution}

Will print the distribution as is (e.g., `Probit` will be "Probit"), unless another function overrides this behavior (e.g., `Normal`,
`InverseGaussian`, `NegativeBinomial`)
"""
(::Type{T})(x::D; args...) where {T<: AbstractRenderType, D<:UnivariateDistribution} = T(string(Base.typename(D).wrapper); args...)

"""
    (::Type{T})(x::InverseGaussian; args...) where {T<: AbstractRenderType}

By default, will be "Inverse Gaussian"
"""
(::Type{T})(x::InverseGaussian; args...) where {T<: AbstractRenderType} = T("Inverse Gaussian"; args...)

"""
    (::Type{T})(x::NegativeBinomial; args...) where {T<: AbstractRenderType}

By default, will be "Negative Binomial"
"""
(::Type{T})(x::NegativeBinomial; args...) where {T<: AbstractRenderType} = T("Negative Binomial"; args...)

"""
    (::Type{T})(x::Normal; args...) where {T<: AbstractRenderType}

By default, will call [`default_ols_label`](@ref)
"""
(::Type{T})(x::Normal; args...) where {T<: AbstractRenderType} = T(default_ols_label(T()); args...)

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

tablestart(::AbstractRenderType) = ""
toprule(::AbstractRenderType) = ""
midrule(::AbstractRenderType) = ""
bottomrule(::AbstractRenderType) = ""
tableend(::AbstractRenderType) = ""

linestart(::AbstractRenderType) = ""
lineend(::AbstractRenderType) = ""
colsep(::AbstractRenderType) = "   "
underline(::AbstractRenderType) = ""

# functions to make dispatch easier
tablestart(tab::RegressionTable{<:AbstractRenderType}) = tablestart(tab.rndr)
toprule(tab::RegressionTable{<:AbstractRenderType}) = toprule(tab.rndr)
midrule(tab::RegressionTable{<:AbstractRenderType}) = midrule(tab.rndr)
bottomrule(tab::RegressionTable{<:AbstractRenderType}) = bottomrule(tab.rndr)
tableend(tab::RegressionTable{<:AbstractRenderType}) = tableend(tab.rndr)

linestart(tab::RegressionTable{<:AbstractRenderType}) = linestart(tab.rndr)
lineend(tab::RegressionTable{<:AbstractRenderType}) = lineend(tab.rndr)
colsep(tab::RegressionTable{<:AbstractRenderType}) = colsep(tab.rndr)
underline(tab::RegressionTable{<:AbstractRenderType}) = underline(tab.rndr)
linestart(row::DataRow{<:AbstractRenderType}) = linestart(row.rndr)
lineend(row::DataRow{<:AbstractRenderType}) = lineend(row.rndr)
colsep(row::DataRow{<:AbstractRenderType}) = colsep(row.rndr)
underline(row::DataRow{<:AbstractRenderType}) = underline(row.rndr)
