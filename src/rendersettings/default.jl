
"""
    label_p(render::AbstractRenderType) = "p"
    label_p(render::AbstractLatex) = "\\\$p\\\$"
    label_p(render::AbstractHtml) = "<i>p</i>"
"""
label_p(render::AbstractRenderType) = "p"

"""
    wrapper(render::AbstractRenderType, s)

Used to wrap a string, particularly for [`estim_decorator`](@ref) and defaults to `s` (i.e., no wrapper).
For example, to wrap the stars in Latex, run:
```julia
RegressionTables.wrapper(::AbstractLatex, deco) = "\$^{\$deco}\$"
```
"""
wrapper(render::AbstractRenderType, s) = s

"""
    interaction_combine(render::AbstractRenderType) = " & "
    interaction_combine(render::AbstractLatex) = " \\\$\\times\\\$ "
    interaction_combine(render::AbstractHtml) = " &times; "

Used to separate pieces of [`InteractedCoefName`](@ref) and defaults to:
- " & " in the general case
- `"\$ \\times \$"` in Latex
- `" &times; "` in HTML

Change this by rerunning the function with the desired default, for example:
```julia
RegressionTables.interaction_combine(render::AbstractLatex) = " \\& "
```
"""
interaction_combine(render::AbstractRenderType) = " & "

"""
    categorical_equal(render::AbstractRenderType)

Used to separate the name and level of [`CategoricalCoefName`](@ref) and defaults to ": ".
"""
categorical_equal(render::AbstractRenderType) = ":"

"""
    random_effect_separator(render::AbstractRenderType)

Used to separate the left and right hand side of [`RandomEffectCoefName`](@ref) and defaults to " | ".
"""
random_effect_separator(render::AbstractRenderType) = " | "

"""
    label_ols(render::AbstractRenderType) = "OLS"

Also see [`RegressionType`](@ref)
"""
label_ols(render::AbstractRenderType) = "OLS"

"""
    label_iv(render::AbstractRenderType) = "IV"

Also see [`RegressionType`](@ref)
"""
label_iv(render::AbstractRenderType) = "IV"

"""
    label_distribution(render::AbstractRenderType, d::D) where {D <: UnivariateDistribution} = string(Base.typename(D).wrapper)
    label_distribution(render::AbstractRenderType, d::NegativeBinomial) = "Negative Binomial"
    label_distribution(render::AbstractRenderType, d::InverseGaussian) = "Inverse Gaussian"

How to label non-linear regressions and defaults to the name of the distribution. For example, `Probit` will be "Probit".
Two exceptions are given for `NegativeBinomial` and `InverseGaussian`, which are "Negative Binomial" and "Inverse Gaussian", respectively.
This can be changed for a specific distribution by running:
```julia
RegressionTables.label_distribution(render::AbstractRenderType, d::Poisson) = "Poisson"
```
"""
label_distribution(render::AbstractRenderType, d::D) where {D <: UnivariateDistribution} = string(Base.typename(D).wrapper)
label_distribution(render::AbstractRenderType, d::NegativeBinomial) = "Negative Binomial"
label_distribution(render::AbstractRenderType, d::InverseGaussian) = "Inverse Gaussian"

"""
    below_decoration(render::AbstractRenderType, s)

Used to decorate a string below the main string and defaults to `"(\$s)"`.
Change this by running:
```julia
RegressionTables.below_decoration(render::AbstractRenderType, s) = "(\$s)"
```
"""
below_decoration(render::AbstractRenderType, s) = "($s)"

"""
    number_regressions_decoration(render::AbstractRenderType, s)

Used to decorate the regression number (e.g., "(1)") and defaults to `"(\$s)"`.
Change this by running:
```julia
RegressionTables.number_regressions_decoration(render::AbstractRenderType, s) = "(\$s)"
```
"""
number_regressions_decoration(render::AbstractRenderType, s) = "($s)"

"""
    fe_suffix(render::AbstractRenderType)

Used to add a suffix to the fixed effects and defaults to " Fixed Effects".
Change this by running:
```julia
RegressionTables.fe_suffix(render::AbstractRenderType) = " Fixed Effects"
```
"""
fe_suffix(render::AbstractRenderType) = " Fixed Effects"


"""
    cluster_suffix(render::AbstractRenderType)

Used to add a suffix to the clustering and defaults to " Clustering".
Change this by running:
```julia
RegressionTables.cluster_suffix(render::AbstractRenderType) = " Clustering"
```
"""
cluster_suffix(render::AbstractRenderType) = " Clustering"

"""
    fe_value(render::AbstractRenderType, v)

Determines how to render a yes/no value for fixed effects, defaults to "Yes" and "".
Can be changed by running:
```julia
RegressionTables.fe_value(render::AbstractRenderType, v) = v ? "Yes" : "No"
```
"""
fe_value(render::AbstractRenderType, v) = v ? "Yes" : ""

"""
    Base.repr(render::AbstractRenderType, x; args...)

Will render x as a string
"""
Base.repr(render::AbstractRenderType, x; args...) = "$x"

"""
    Base.repr(render::AbstractRenderType, x::Pair; args...)

By default, will render the first element of the pair according to the render type. In cases of [`AbstractLatex`](@ref)
or [`AbstractHtml`](@ref), uses the second element to determine number of columns to span.
"""
Base.repr(render::AbstractRenderType, x::Pair; args...) = repr(render, first(x); args...)

"""
    Base.repr(render::AbstractRenderType, x::Int; args...)

By default, will render the integer with commas
"""
Base.repr(render::AbstractRenderType, x::Int; args...) = format(x, commas=true)

"""
    Base.repr(render::AbstractRenderType, x::Float64; digits=default_digits(render, x), commas=true, str_format=nothing, args...)

By default, will render the float with commas and the default number of digits. If `str_format` is specified, will use
that instead of `digits` and `commas`
"""
function Base.repr(render::AbstractRenderType, x::Float64; digits=default_digits(render, x), commas=true, str_format=nothing, args...)
    if str_format !== nothing
        cfmt(str_format, x)
    else
        format(x; precision=digits, commas)
    end
end

"""
    Base.repr(render::AbstractRenderType, x::Nothing; args...)

By default, will render the nothing as an empty string
"""
Base.repr(render::AbstractRenderType, x::Nothing; args...) = ""

"""
    Base.repr(render::AbstractRenderType, x::Missing; args...)

By default, will render the missing as an empty string
"""
Base.repr(render::AbstractRenderType, x::Missing; args...) = ""

"""
    Base.repr(render::AbstractRenderType, x::AbstractString; args...)

By default, will render the string as is
"""
Base.repr(render::AbstractRenderType, x::AbstractString; args...) = String(x)

"""
    Base.repr(render::AbstractRenderType, x::Bool; args...)

By default, will render the boolean as "Yes" or ""
"""
Base.repr(render::AbstractRenderType, x::Bool; args...) = x ? "Yes" : ""

"""
    Base.repr(render::AbstractRenderType, x::AbstractRegressionStatistic; digits=default_digits(render, x), args...)

By default, will render the statistic with commas and the default number of digits
"""
Base.repr(render::AbstractRenderType, x::AbstractRegressionStatistic; digits=default_digits(render, x), args...) = repr(render, value(x); digits, args...)

"""
    Base.repr(render::AbstractRenderType, x::AbstractR2; digits=default_digits(render, x), args...)

By default, will render the same as `AbstractRegressionStatistic`
"""
Base.repr(render::AbstractRenderType, x::AbstractR2; digits=default_digits(render, x), args...) = repr(render, value(x); digits, args...)

"""
    Base.repr(render::AbstractRenderType, x::AbstractUnderStatistic; digits=default_digits(render, x), args...)

By default, will render with the default number of digits and surrounded by parentheses `(1.234)`
"""
Base.repr(render::AbstractRenderType, x::AbstractUnderStatistic; digits=default_digits(render, x), args...) = below_decoration(render, repr(render, value(x); digits, commas=false, args...))

"""
    Base.repr(render::AbstractRenderType, x::ConfInt; digits=default_digits(render, x), args...)

By default, will render with the default number of digits and surrounded by parentheses `(1.234, 5.678)`
"""
Base.repr(render::AbstractRenderType, x::ConfInt; digits=default_digits(render, x), args...) = below_decoration(render, repr(render, value(x)[1]; digits) * ", " * Base.repr(render::AbstractRenderType, value(x)[2]; digits))

"""
    Base.repr(render::AbstractRenderType, x::CoefValue; digits=default_digits(render, x), args...)

By default, will render with the default number of digits and surrounded by parentheses and will call [`estim_decorator`](@ref) for the decoration
"""
Base.repr(render::AbstractRenderType, x::CoefValue; digits=default_digits(render, x), args...) = estim_decorator(render, repr(render, value(x); digits, commas=false, args...), x.pvalue)

"""
    Base.repr(render::AbstractRenderType, x::Type{V}; args...) where {V <: AbstractRegressionStatistic}

By default, will call the `label` function related to the type
"""
Base.repr(render::AbstractRenderType, x::Type{V}; args...) where {V <: AbstractRegressionStatistic} = label(render, V)

"""
    Base.repr(render::AbstractRenderType, x::Type{RegressionType}; args...)

By default, will call the `label` function related to the `RegressionType`
"""
Base.repr(render::AbstractRenderType, x::Type{RegressionType}; args...) = label(render, x)

"""
    Base.repr(render::AbstractRenderType, x::Tuple; args...)    

By default, will render the tuple with spaces between the elements
"""
Base.repr(render::AbstractRenderType, x::Tuple; args...) = join(repr.(render, x; args...), " ")

"""
    Base.repr(render::AbstractRenderType, x::AbstractCoefName; args...)

By default, will render the name of the coefficient, also see [Regression Statistics](@ref)
"""
Base.repr(render::AbstractRenderType, x::AbstractCoefName; args...) = repr(render, value(x); args...)

"""
    Base.repr(render::AbstractRenderType, x::FixedEffectCoefName; args...)

By default, will render the coefficient and add `" Fixed Effects"` as a suffix, also see [Regression Statistics](@ref)
"""
Base.repr(render::AbstractRenderType, x::FixedEffectCoefName; args...) = repr(render, value(x); args...) * fe_suffix(render)

"""
    Base.repr(render::AbstractRenderType, x::RandomEffectCoefName; args...)

By default, will render the coefficient and add the `" Clustering"` function as a separator, also see [Regression Statistics](@ref)
"""
Base.repr(render::AbstractRenderType, x::ClusterCoefName; args...) = repr(render, value(x); args...) * cluster_suffix(render)

"""
    Base.repr(render::AbstractRenderType, x::InteractedCoefName; args...)

By default, will render the coefficient and add the `interaction_combine` function as a separator, also see [Regression Statistics](@ref)
"""
Base.repr(render::AbstractRenderType, x::InteractedCoefName; args...) = join(repr.(render, value(x); args...), interaction_combine(render))

"""
    Base.repr(render::AbstractRenderType, x::CategoricalCoefName; args...)

By default, will render the coefficient and add the `categorical_equal` function as a separator, also see [Regression Statistics](@ref)
"""
Base.repr(render::AbstractRenderType, x::CategoricalCoefName; args...) = "$(value(x))$(categorical_equal(render)) $(x.level)"

"""
    Base.repr(render::AbstractRenderType, x::InterceptCoefName; args...)

By default, will render the coefficient as `(Intercept)`, also see [Regression Statistics](@ref)
"""
Base.repr(render::AbstractRenderType, x::InterceptCoefName; args...) = "(Intercept)"

"""
    Base.repr(render::AbstractRenderType, x::HasControls; args...)

By default, will render the same as `Bool` ("Yes" and "")
"""
Base.repr(render::AbstractRenderType, x::HasControls; args...) = repr(render, value(x); args...)

"""
    Base.repr(render::AbstractRenderType, x::RegressionNumbers; args...)

By default, will render the number in parentheses (e.g., "(1)", "(2)"...)
"""
Base.repr(render::AbstractRenderType, x::RegressionNumbers; args...) = number_regressions_decoration(render, repr(render, value(x); args...))

"""
    Base.repr(render::AbstractRenderType, x::Type{V}; args...) where {V <: HasControls}

By default, will call the `label` function related to the type
"""
Base.repr(render::AbstractRenderType, x::Type{V}; args...) where {V <: HasControls} = label(render, V)

"""
    Base.repr(render::AbstractRenderType, x::RegressionType; args...)

By default, will check if the `RegressionType` is an instrumental variable regression and call the `label` function related to the type.
If it is an instrumental variable, will then call [`label_iv`](@ref), otherwise it will call the related distribution.
"""
Base.repr(render::AbstractRenderType, x::RegressionType; args...) = x.is_iv ? label_iv(render) : repr(render, value(x); args...)

"""
    Base.repr(render::AbstractRenderType, x::D; args...) where {D <: UnivariateDistribution}

Will print the distribution as is (e.g., `Probit` will be "Probit"), unless another function overrides this behavior (e.g., `Normal`,
`InverseGaussian`, `NegativeBinomial`)
"""
Base.repr(render::AbstractRenderType, x::D; args...) where {D <: UnivariateDistribution} = string(Base.typename(D).wrapper)

"""
    Base.repr(render::AbstractRenderType, x::InverseGaussian; args...)

By default, will be "Inverse Gaussian"
"""
Base.repr(render::AbstractRenderType, x::InverseGaussian; args...) = "Inverse Gaussian"

"""
    Base.repr(render::AbstractRenderType, x::NegativeBinomial; args...)

By default, will be "Negative Binomial"
"""
Base.repr(render::AbstractRenderType, x::NegativeBinomial; args...) = "Negative Binomial"

"""
    Base.repr(render::AbstractRenderType, x::Normal; args...)

By default, will call [`label_ols`](@ref)
"""
Base.repr(render::AbstractRenderType, x::Normal; args...) = repr(render, label_ols(render); args...)


"""
    Base.repr(render::AbstractRenderType, x::RandomEffectCoefName; args...)

How to render a [`RandomEffectCoefName`](@ref) and defaults to the right hand side, then the separator, then the left hand side.
"""
Base.repr(render::AbstractRenderType, x::RandomEffectCoefName; args...) = 
    repr(render, x.rhs; args...) * random_effect_separator(render) * repr(render, x.lhs; args...)

"""
    Base.repr(render::AbstractRenderType, x::FixedEffectValue; args...)

How to render a [`FixedEffectValue`](@ref) and defaults to calling [`fe_value`](@ref)
"""
Base.repr(render::AbstractRenderType, x::FixedEffectValue; args...) = fe_value(render, value(x))

"""
    Base.repr(render::AbstractRenderType, x::ClusterValue; args...)

How to render a [`ClusterValue`](@ref) and defaults to how `true` and `false` is displayed.

If wanting to show the size of the clusters, run:
```julia
RegressionTables.repr(render::AbstractRenderType, x::ClusterValue; args...) = repr(render, value(x); args...)
```
"""
Base.repr(render::AbstractRenderType, x::ClusterValue; args...) = repr(render, value(x) > 0; args...)

"""
    Base.repr(render::AbstractRenderType, x::RandomEffectValue; args...)

How to render a [`RandomEffectValue`](@ref) and defaults to calling another render function, dependent on the type of the value
"""
Base.repr(render::AbstractRenderType, x::RandomEffectValue; args...) = repr(render, value(x); args...)

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
tablestart(tab::RegressionTable{<:AbstractRenderType}) = tablestart(tab.render)
toprule(tab::RegressionTable{<:AbstractRenderType}) = toprule(tab.render)
midrule(tab::RegressionTable{<:AbstractRenderType}) = midrule(tab.render)
bottomrule(tab::RegressionTable{<:AbstractRenderType}) = bottomrule(tab.render)
tableend(tab::RegressionTable{<:AbstractRenderType}) = tableend(tab.render)

linestart(tab::RegressionTable{<:AbstractRenderType}) = linestart(tab.render)
lineend(tab::RegressionTable{<:AbstractRenderType}) = lineend(tab.render)
colsep(tab::RegressionTable{<:AbstractRenderType}) = colsep(tab.render)
underline(tab::RegressionTable{<:AbstractRenderType}) = underline(tab.render)
linestart(row::DataRow{<:AbstractRenderType}) = linestart(row.render)
lineend(row::DataRow{<:AbstractRenderType}) = lineend(row.render)
colsep(row::DataRow{<:AbstractRenderType}) = colsep(row.render)
underline(row::DataRow{<:AbstractRenderType}) = underline(row.render)
