
label_p(rndr::AbstractRenderType) = "p"

wrapper(rndr::AbstractRenderType, s) = s

"""
    interaction_combine(rndr::AbstractRenderType)

Used to separate pieces of [`InteractedCoefName`](@ref) and defaults to " & ". 
"""
interaction_combine(rndr::AbstractRenderType) = " & "

"""
    categorical_equal(rndr::AbstractRenderType)

Used to separate the name and level of [`CategoricalCoefName`](@ref) and defaults to ": ".
"""
categorical_equal(rndr::AbstractRenderType) = ":"

random_effect_separator(rndr::AbstractRenderType) = " | "

"""
    label_ols(rndr::AbstractRenderType)

Used to label regressions with a Normal distribution and defaults to "OLS".
Also see [`label_iv`](@ref) and [`RegressionType`](@ref)
"""
label_ols(rndr::AbstractRenderType) = "OLS"

"""
    label_iv(rndr::AbstractRenderType)

Used to label regressions with an instrumental variable and defaults to "IV".
Also see [`label_ols`](@ref) and [`RegressionType`](@ref)
"""
label_iv(rndr::AbstractRenderType) = "IV"

"""
    below_decoration(rndr::AbstractRenderType, s)

Used to decorate a string below the main string and defaults to `"(\$s)"`.
Change this by running:
```julia
RegressionTables.below_decoration(rndr::AbstractRenderType, s) = "(\$s)"
```
"""
below_decoration(rndr::AbstractRenderType, s) = "($s)"

"""
    number_regressions_decoration(rndr::AbstractRenderType, s)

Used to decorate the regression number (e.g., "(1)") and defaults to `"(\$s)"`.
Change this by running:
```julia
RegressionTables.number_regressions_decoration(rndr::AbstractRenderType, s) = "(\$s)"
```
"""
number_regressions_decoration(rndr::AbstractRenderType, s) = "($s)"

"""
    fe_suffix(rndr::AbstractRenderType)

Used to add a suffix to the fixed effects and defaults to " Fixed Effects".
Change this by running:
```julia
RegressionTables.fe_suffix(rndr::AbstractRenderType) = " Fixed Effects"
```
"""
fe_suffix(rndr::AbstractRenderType) = " Fixed Effects"

"""
    render(rndr, x; args...)

Will render x as a string
"""
render(rndr, x; args...) = "$x"

"""
    render(rndr, x::Pair; args...)

By default, will render the first element of the pair according to the render type. In cases of [`AbstractLatex`](@ref)
or [`AbstractHtml`](@ref), uses the second element to determine number of columns to span.
"""
render(rndr, x::Pair; args...) = render(rndr, first(x); args...)

"""
    render(rndr, x::Int; args...)

By default, will render the integer with commas
"""
render(rndr, x::Int; args...) = format(x, commas=true)

"""
    render(rndr, x::Float64; digits=default_digits(rndr, x), commas=true, str_format=nothing, args...)

By default, will render the float with commas and the default number of digits. If `str_format` is specified, will use
that instead of `digits` and `commas`
"""
function render(rndr, x::Float64; digits=default_digits(rndr, x), commas=true, str_format=nothing, args...)
    if str_format !== nothing
        sprintf1(str_format, x)
    else
        format(x; precision=digits, commas)
    end
end

"""
    render(rndr, x::Nothing; args...)

By default, will render the nothing as an empty string
"""
render(rndr, x::Nothing; args...) = ""

"""
    render(rndr, x::Missing; args...)

By default, will render the missing as an empty string
"""
render(rndr, x::Missing; args...) = ""

"""
    render(rndr, x::AbstractString; args...)

By default, will render the string as is
"""
render(rndr, x::AbstractString; args...) = String(x)

"""
    render(rndr, x::Bool; args...)

By default, will render the boolean as "Yes" or ""
"""
render(rndr, x::Bool; args...) = x ? "Yes" : ""

"""
    render(rndr, x::AbstractRegressionStatistic; digits=default_digits(rndr, x), args...)

By default, will render the statistic with commas and the default number of digits
"""
render(rndr, x::AbstractRegressionStatistic; digits=default_digits(rndr, x), args...) = render(rndr, value(x); digits, args...)

"""
    render(rndr, x::AbstractR2; digits=default_digits(rndr, x), args...)

By default, will render the same as `AbstractRegressionStatistic`
"""
render(rndr, x::AbstractR2; digits=default_digits(rndr, x), args...) = render(rndr, value(x); digits, args...)

"""
    render(rndr, x::AbstractUnderStatistic; digits=default_digits(rndr, x), args...)

By default, will render with the default number of digits and surrounded by parentheses `(1.234)`
"""
render(rndr, x::AbstractUnderStatistic; digits=default_digits(rndr, x), args...) = below_decoration(rndr, render(rndr, value(x); digits, commas=false, args...))

"""
    render(rndr, x::ConfInt; digits=default_digits(rndr, x), args...)

By default, will render with the default number of digits and surrounded by parentheses `(1.234, 5.678)`
"""
render(rndr, x::ConfInt; digits=default_digits(rndr, x), args...) = below_decoration(rndr, render(rndr, value(x)[1]; digits) * ", " * render(rndr, value(x)[2]; digits))

"""
    render(rndr, x::CoefValue; digits=default_digits(rndr, x), args...)

By default, will render with the default number of digits and surrounded by parentheses and will call [`estim_decorator`](@ref) for the decoration
"""
render(rndr, x::CoefValue; digits=default_digits(rndr, x), args...) = estim_decorator(rndr, render(rndr, value(x); digits, commas=false, args...), x.pvalue)

"""
    render(rndr, x::Type{V}; args...) where {V <: AbstractRegressionStatistic}

By default, will call the `label` function related to the type
"""
render(rndr, x::Type{V}; args...) where {V <: AbstractRegressionStatistic} = label(rndr, V)

"""
    render(rndr, x::Type{RegressionType}; args...)

By default, will call the `label` function related to the `RegressionType`
"""
render(rndr, x::Type{RegressionType}; args...) = label(rndr, x)

"""
    render(rndr, x::Tuple; args...)    

By default, will render the tuple with spaces between the elements
"""
render(rndr, x::Tuple; args...) = join(render.(rndr, x; args...), " ")

"""
    render(rndr, x::AbstractCoefName; args...)

By default, will render the name of the coefficient, also see [Regression Statistics](@ref)
"""
render(rndr, x::AbstractCoefName; args...) = render(rndr, value(x); args...)

"""
    render(rndr, x::FixedEffectCoefName; args...)

By default, will render the coefficient and add `" Fixed Effects"` as a suffix, also see [Regression Statistics](@ref)
"""
render(rndr, x::FixedEffectCoefName; args...) = render(rndr, value(x); args...) * fe_suffix(rndr)

"""
    render(rndr, x::InteractedCoefName; args...)

By default, will render the coefficient and add the `interaction_combine` function as a separator, also see [Regression Statistics](@ref)
"""
render(rndr, x::InteractedCoefName; args...) = join(render.(rndr, value(x); args...), interaction_combine(rndr))

"""
    render(rndr, x::CategoricalCoefName; args...)

By default, will render the coefficient and add the `categorical_equal` function as a separator, also see [Regression Statistics](@ref)
"""
render(rndr, x::CategoricalCoefName; args...) = "$(value(x))$(categorical_equal(rndr)) $(x.level)"

"""
    render(rndr, x::InterceptCoefName; args...)

By default, will render the coefficient as `(Intercept)`, also see [Regression Statistics](@ref)
"""
render(rndr, x::InterceptCoefName; args...) = "(Intercept)"

"""
    render(rndr, x::HasControls; args...)

By default, will render the same as `Bool` ("Yes" and "")
"""
render(rndr, x::HasControls; args...) = render(rndr, value(x); args...)

"""
    render(rndr, x::RegressionNumbers; args...)

By default, will render the number in parentheses (e.g., "(1)", "(2)"...)
"""
render(rndr, x::RegressionNumbers; args...) = number_regressions_decoration(rndr, render(rndr, value(x); args...))

"""
    render(rndr, x::Type{V}; args...) where {V <: HasControls}

By default, will call the `label` function related to the type
"""
render(rndr, x::Type{V}; args...) where {V <: HasControls} = label(rndr, V)

"""
    render(rndr, x::RegressionType; args...)

By default, will check if the `RegressionType` is an instrumental variable regression and call the `label` function related to the type.
If it is an instrumental variable, will then call [`label_iv`](@ref), otherwise it will call the related distribution.
"""
render(rndr, x::RegressionType; args...) = x.is_iv ? label_iv(rndr) : render(rndr, value(x); args...)

"""
    render(rndr, x::D; args...) where {D <: UnivariateDistribution}

Will print the distribution as is (e.g., `Probit` will be "Probit"), unless another function overrides this behavior (e.g., `Normal`,
`InverseGaussian`, `NegativeBinomial`)
"""
render(rndr, x::D; args...) where {D <: UnivariateDistribution} = string(Base.typename(D).wrapper)

"""
    render(rndr, x::InverseGaussian; args...)

By default, will be "Inverse Gaussian"
"""
render(rndr, x::InverseGaussian; args...) = "Inverse Gaussian"

"""
    render(rndr, x::NegativeBinomial; args...)

By default, will be "Negative Binomial"
"""
render(rndr, x::NegativeBinomial; args...) = "Negative Binomial"

"""
    render(rndr, x::Normal; args...)

By default, will call [`label_ols`](@ref)
"""
render(rndr, x::Normal; args...) = render(rndr, label_ols(rndr); args...)

render(rndr, x::RandomEffectCoefName; args...) = 
    render(rndr, x.rhs; args...) * random_effect_separator(rndr) * render(rndr, x.lhs; args...)

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
