
"""
    label_p(rndr::AbstractRenderType) = "p"
    label_p(rndr::AbstractLatex) = "\\\$p\\\$"
    label_p(rndr::AbstractHtml) = "<i>p</i>"
"""
label_p(rndr::AbstractRenderType) = "p"

"""
    wrapper(rndr::AbstractRenderType, s)

Used to wrap a string, particularly for [`estim_decorator`](@ref) and defaults to `s` (i.e., no wrapper).
For example, to wrap the stars in Latex, run:
```julia
RegressionTables.wrapper(::AbstractLatex, deco) = "\$^{\$deco}\$"
```
"""
wrapper(rndr::AbstractRenderType, s) = s

"""
    interaction_combine(rndr::AbstractRenderType) = " & "
    interaction_combine(rndr::AbstractLatex) = " \\\$\\times\\\$ "
    interaction_combine(rndr::AbstractHtml) = " &times; "

Used to separate pieces of [`InteractedCoefName`](@ref) and defaults to:
- " & " in the general case
- `"\$ \\times \$"` in Latex
- `" &times; "` in HTML

Change this by rerunning the function with the desired default, for example:
```julia
RegressionTables.interaction_combine(rndr::AbstractLatex) = " \\& "
```
"""
interaction_combine(rndr::AbstractRenderType) = " & "

"""
    categorical_equal(rndr::AbstractRenderType)

Used to separate the name and level of [`CategoricalCoefName`](@ref) and defaults to ": ".
"""
categorical_equal(rndr::AbstractRenderType) = ":"

"""
    random_effect_separator(rndr::AbstractRenderType)

Used to separate the left and right hand side of [`RandomEffectCoefName`](@ref) and defaults to " | ".
"""
random_effect_separator(rndr::AbstractRenderType) = " | "

"""
    label_ols(rndr::AbstractRenderType) = "OLS"

Also see [`RegressionType`](@ref)
"""
label_ols(rndr::AbstractRenderType) = "OLS"

"""
    label_iv(rndr::AbstractRenderType) = "IV"

Also see [`RegressionType`](@ref)
"""
label_iv(rndr::AbstractRenderType) = "IV"

"""
    label_distribution(rndr::AbstractRenderType, d::D) where {D <: UnivariateDistribution} = string(Base.typename(D).wrapper)
    label_distribution(rndr::AbstractRenderType, d::NegativeBinomial) = "Negative Binomial"
    label_distribution(rndr::AbstractRenderType, d::InverseGaussian) = "Inverse Gaussian"

How to label non-linear regressions and defaults to the name of the distribution. For example, `Probit` will be "Probit".
Two exceptions are given for `NegativeBinomial` and `InverseGaussian`, which are "Negative Binomial" and "Inverse Gaussian", respectively.
This can be changed for a specific distribution by running:
```julia
RegressionTables.label_distribution(rndr::AbstractRenderType, d::Poisson) = "Poisson"
```
"""
label_distribution(rndr::AbstractRenderType, d::D) where {D <: UnivariateDistribution} = string(Base.typename(D).wrapper)
label_distribution(rndr::AbstractRenderType, d::NegativeBinomial) = "Negative Binomial"
label_distribution(rndr::AbstractRenderType, d::InverseGaussian) = "Inverse Gaussian"

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
    fe_value(rndr::AbstractRenderType, v)

Determines how to render a yes/no value for fixed effects, defaults to "Yes" and "".
Can be changed by running:
```julia
RegressionTables.fe_value(rndr::AbstractRenderType, v) = v ? "Yes" : "No"
```
"""
fe_value(rndr::AbstractRenderType, v) = v ? "Yes" : ""

"""
    Base.repr(rndr::AbstractRenderType, x; args...)

Will render x as a string
"""
Base.repr(rndr::AbstractRenderType, x; args...) = "$x"

"""
    Base.repr(rndr::AbstractRenderType, x::Pair; args...)

By default, will render the first element of the pair according to the render type. In cases of [`AbstractLatex`](@ref)
or [`AbstractHtml`](@ref), uses the second element to determine number of columns to span.
"""
Base.repr(rndr::AbstractRenderType, x::Pair; args...) = repr(rndr, first(x); args...)

"""
    Base.repr(rndr::AbstractRenderType, x::Int; args...)

By default, will render the integer with commas
"""
Base.repr(rndr::AbstractRenderType, x::Int; args...) = format(x, commas=true)

"""
    Base.repr(rndr::AbstractRenderType, x::Float64; digits=default_digits(rndr, x), commas=true, str_format=nothing, args...)

By default, will render the float with commas and the default number of digits. If `str_format` is specified, will use
that instead of `digits` and `commas`
"""
function Base.repr(rndr::AbstractRenderType, x::Float64; digits=default_digits(rndr, x), commas=true, str_format=nothing, args...)
    if str_format !== nothing
        sprintf1(str_format, x)
    else
        format(x; precision=digits, commas)
    end
end

"""
    Base.repr(rndr::AbstractRenderType, x::Nothing; args...)

By default, will render the nothing as an empty string
"""
Base.repr(rndr::AbstractRenderType, x::Nothing; args...) = ""

"""
    Base.repr(rndr::AbstractRenderType, x::Missing; args...)

By default, will render the missing as an empty string
"""
Base.repr(rndr::AbstractRenderType, x::Missing; args...) = ""

"""
    Base.repr(rndr::AbstractRenderType, x::AbstractString; args...)

By default, will render the string as is
"""
Base.repr(rndr::AbstractRenderType, x::AbstractString; args...) = String(x)

"""
    Base.repr(rndr::AbstractRenderType, x::Bool; args...)

By default, will render the boolean as "Yes" or ""
"""
Base.repr(rndr::AbstractRenderType, x::Bool; args...) = x ? "Yes" : ""

"""
    Base.repr(rndr::AbstractRenderType, x::AbstractRegressionStatistic; digits=default_digits(rndr, x), args...)

By default, will render the statistic with commas and the default number of digits
"""
Base.repr(rndr::AbstractRenderType, x::AbstractRegressionStatistic; digits=default_digits(rndr, x), args...) = repr(rndr, value(x); digits, args...)

"""
    Base.repr(rndr::AbstractRenderType, x::AbstractR2; digits=default_digits(rndr, x), args...)

By default, will render the same as `AbstractRegressionStatistic`
"""
Base.repr(rndr::AbstractRenderType, x::AbstractR2; digits=default_digits(rndr, x), args...) = repr(rndr, value(x); digits, args...)

"""
    Base.repr(rndr::AbstractRenderType, x::AbstractUnderStatistic; digits=default_digits(rndr, x), args...)

By default, will render with the default number of digits and surrounded by parentheses `(1.234)`
"""
Base.repr(rndr::AbstractRenderType, x::AbstractUnderStatistic; digits=default_digits(rndr, x), args...) = below_decoration(rndr, repr(rndr, value(x); digits, commas=false, args...))

"""
    Base.repr(rndr::AbstractRenderType, x::ConfInt; digits=default_digits(rndr, x), args...)

By default, will render with the default number of digits and surrounded by parentheses `(1.234, 5.678)`
"""
Base.repr(rndr::AbstractRenderType, x::ConfInt; digits=default_digits(rndr, x), args...) = below_decoration(rndr, repr(rndr, value(x)[1]; digits) * ", " * Base.repr(rndr::AbstractRenderType, value(x)[2]; digits))

"""
    Base.repr(rndr::AbstractRenderType, x::CoefValue; digits=default_digits(rndr, x), args...)

By default, will render with the default number of digits and surrounded by parentheses and will call [`estim_decorator`](@ref) for the decoration
"""
Base.repr(rndr::AbstractRenderType, x::CoefValue; digits=default_digits(rndr, x), args...) = estim_decorator(rndr, repr(rndr, value(x); digits, commas=false, args...), x.pvalue)

"""
    Base.repr(rndr::AbstractRenderType, x::Type{V}; args...) where {V <: AbstractRegressionStatistic}

By default, will call the `label` function related to the type
"""
Base.repr(rndr::AbstractRenderType, x::Type{V}; args...) where {V <: AbstractRegressionStatistic} = label(rndr, V)

"""
    Base.repr(rndr::AbstractRenderType, x::Type{RegressionType}; args...)

By default, will call the `label` function related to the `RegressionType`
"""
Base.repr(rndr::AbstractRenderType, x::Type{RegressionType}; args...) = label(rndr, x)

"""
    Base.repr(rndr::AbstractRenderType, x::Tuple; args...)    

By default, will render the tuple with spaces between the elements
"""
Base.repr(rndr::AbstractRenderType, x::Tuple; args...) = join(repr.(rndr, x; args...), " ")

"""
    Base.repr(rndr::AbstractRenderType, x::AbstractCoefName; args...)

By default, will render the name of the coefficient, also see [Regression Statistics](@ref)
"""
Base.repr(rndr::AbstractRenderType, x::AbstractCoefName; args...) = repr(rndr, value(x); args...)

"""
    Base.repr(rndr::AbstractRenderType, x::FixedEffectCoefName; args...)

By default, will render the coefficient and add `" Fixed Effects"` as a suffix, also see [Regression Statistics](@ref)
"""
Base.repr(rndr::AbstractRenderType, x::FixedEffectCoefName; args...) = repr(rndr, value(x); args...) * fe_suffix(rndr)

"""
    Base.repr(rndr::AbstractRenderType, x::InteractedCoefName; args...)

By default, will render the coefficient and add the `interaction_combine` function as a separator, also see [Regression Statistics](@ref)
"""
Base.repr(rndr::AbstractRenderType, x::InteractedCoefName; args...) = join(repr.(rndr, value(x); args...), interaction_combine(rndr))

"""
    Base.repr(rndr::AbstractRenderType, x::CategoricalCoefName; args...)

By default, will render the coefficient and add the `categorical_equal` function as a separator, also see [Regression Statistics](@ref)
"""
Base.repr(rndr::AbstractRenderType, x::CategoricalCoefName; args...) = "$(value(x))$(categorical_equal(rndr)) $(x.level)"

"""
    Base.repr(rndr::AbstractRenderType, x::InterceptCoefName; args...)

By default, will render the coefficient as `(Intercept)`, also see [Regression Statistics](@ref)
"""
Base.repr(rndr::AbstractRenderType, x::InterceptCoefName; args...) = "(Intercept)"

"""
    Base.repr(rndr::AbstractRenderType, x::HasControls; args...)

By default, will render the same as `Bool` ("Yes" and "")
"""
Base.repr(rndr::AbstractRenderType, x::HasControls; args...) = repr(rndr, value(x); args...)

"""
    Base.repr(rndr::AbstractRenderType, x::RegressionNumbers; args...)

By default, will render the number in parentheses (e.g., "(1)", "(2)"...)
"""
Base.repr(rndr::AbstractRenderType, x::RegressionNumbers; args...) = number_regressions_decoration(rndr, repr(rndr, value(x); args...))

"""
    Base.repr(rndr::AbstractRenderType, x::Type{V}; args...) where {V <: HasControls}

By default, will call the `label` function related to the type
"""
Base.repr(rndr::AbstractRenderType, x::Type{V}; args...) where {V <: HasControls} = label(rndr, V)

"""
    Base.repr(rndr::AbstractRenderType, x::RegressionType; args...)

By default, will check if the `RegressionType` is an instrumental variable regression and call the `label` function related to the type.
If it is an instrumental variable, will then call [`label_iv`](@ref), otherwise it will call the related distribution.
"""
Base.repr(rndr::AbstractRenderType, x::RegressionType; args...) = x.is_iv ? label_iv(rndr) : repr(rndr, value(x); args...)

"""
    Base.repr(rndr::AbstractRenderType, x::D; args...) where {D <: UnivariateDistribution}

Will print the distribution as is (e.g., `Probit` will be "Probit"), unless another function overrides this behavior (e.g., `Normal`,
`InverseGaussian`, `NegativeBinomial`)
"""
Base.repr(rndr::AbstractRenderType, x::D; args...) where {D <: UnivariateDistribution} = string(Base.typename(D).wrapper)

"""
    Base.repr(rndr::AbstractRenderType, x::InverseGaussian; args...)

By default, will be "Inverse Gaussian"
"""
Base.repr(rndr::AbstractRenderType, x::InverseGaussian; args...) = "Inverse Gaussian"

"""
    Base.repr(rndr::AbstractRenderType, x::NegativeBinomial; args...)

By default, will be "Negative Binomial"
"""
Base.repr(rndr::AbstractRenderType, x::NegativeBinomial; args...) = "Negative Binomial"

"""
    Base.repr(rndr::AbstractRenderType, x::Normal; args...)

By default, will call [`label_ols`](@ref)
"""
Base.repr(rndr::AbstractRenderType, x::Normal; args...) = repr(rndr, label_ols(rndr); args...)


"""
    Base.repr(rndr::AbstractRenderType, x::RandomEffectCoefName; args...)

How to render a [`RandomEffectCoefName`](@ref) and defaults to the right hand side, then the separator, then the left hand side.
"""
Base.repr(rndr::AbstractRenderType, x::RandomEffectCoefName; args...) = 
    repr(rndr, x.rhs; args...) * random_effect_separator(rndr) * repr(rndr, x.lhs; args...)

"""
    Base.repr(rndr::AbstractRenderType, x::FixedEffectValue; args...)

How to render a [`FixedEffectValue`](@ref) and defaults to calling [`fe_value`](@ref)
"""
Base.repr(rndr::AbstractRenderType, x::FixedEffectValue; args...) = fe_value(rndr, value(x))

"""
    Base.repr(rndr::AbstractRenderType, x::RandomEffectValue; args...)

How to render a [`RandomEffectValue`](@ref) and defaults to calling another render function, dependent on the type of the value
"""
Base.repr(rndr::AbstractRenderType, x::RandomEffectValue; args...) = repr(rndr, value(x); args...)

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
