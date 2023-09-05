"""
AbstractRegressionStatistic encapsulates all regression statistics
(e.g., number of observations, ``R^2``, etc.). In most cases, the individual regression
packages provide functions that access these, generally from the [StatsAPI.jl](https://github.com/JuliaStats/StatsAPI.jl)
package. If the function does not exist in the regression package, it is typically added in
the extension to this package. Since some statistics are not relevant for all regressions,
the value of the statistic is wrapped in a `Union` with `Nothing` to indicate that the
value is not available.

To define a new regression statistic, three things are needed:
1. A new type that is a subtype of `AbstractRegressionStatistic`
2. A constructor that takes a `RegressionModel` and returns the new type (or `nothing` if the statistic is not available)
3. A `label` function that is dependent on the [`AbstractRenderType`](@ref) and the type provided. This label is what is displayed in the
   left most column of the regression table.

It is also helpful to maintain consistency by defining the value as `val` within the struct.

For example:
```julia
struct YMean <: RegressionTable.AbstractRegressionStatistic
    val::Union{Float64, Nothing}
end
YMean(x::RegressionModel) = try
    YMean(mean(x.model.rr.y))
catch
    YMean(nothing)
end
RegressionTable.label(rndr::AbstractRenderType, x::Type{YMean}) = "Mean of Y"
```
"""
abstract type AbstractRegressionStatistic end


"""
    abstract type AbstractR2 <: AbstractRegressionStatistic end

Parent type for all ``R^2`` statistics. This is available to change the formatting of all ``R^2`` statistics.
For example, if the desired display for ``R^2`` is in the percentage term, run:
```julia
Base.repr(rndr::AbstractRenderType, x::RegressionTable.AbstractR2; vargs...) = repr(rndr, x.val * 100; digits=2) * "%"
# add second definition since Latex needs % escaped
Base.repr(rndr::AbstractRenderType::RegressionTables.AbstractLatex, x::RegressionTable.AbstractR2; vargs...) = repr(rndr, x.val * 100; digits=2) * "\\%"
```
"""
abstract type AbstractR2 <: AbstractRegressionStatistic end

"""
`Nobs` is the number of observations in the regression. Labels default to:
- "N" for `AbstractAscii`
- "\$N\$" for `AbstractLatex`
- "<i>N</i>" for `AbstractHtml`
"""
struct Nobs <: AbstractRegressionStatistic
    val::Union{Int, Nothing}
end
Nobs(x::RegressionModel) = try
    Nobs(nobs(x))
catch
    Nobs(nothing)
end

"""
    label(rndr::AbstractRenderType, x::Type{Nobs}) = "N"
    label(rndr::AbstractLatex, x::Type{Nobs}) = "\\\$N\\\$"
    label(rndr::AbstractHtml, x::Type{Nobs}) = "<i>N</i>"
"""
label(rndr::AbstractRenderType, x::Type{Nobs}) = "N"

"""
`R2` is the ``R^2`` of the regression. Labels default to:
- "R2" for `AbstractAscii`
- "\$R^2\$" for `AbstractLatex`
- "<i>R</i><sup>2</sup>" for `AbstractHtml`

!!! note
    The label for `R2` is used in other related statistics. So changing the label
    for `R2` will change the label for other ``R^2`` statistics as well.
"""
struct R2 <: AbstractR2
    val::Union{Float64, Nothing}
end
R2(x::RegressionModel) = try
    R2(r2(x))
catch
    R2(nothing)
end

"""
    label(rndr::AbstractRenderType, x::Type{R2}) = "R2"
    label(rndr::AbstractLatex, x::Type{R2}) = "\\\$R^2\\\$"
    label(rndr::AbstractHtml, x::Type{R2}) = "<i>R</i><sup>2</sup>"
"""
label(rndr::AbstractRenderType, x::Type{R2}) = "R2"

"""
`R2McFadden` is the McFadden ``R^2`` of the regression (often referred to as the Pseudo-``R^2``).
Labels default to:
- "Pseudo R2" for `AbstractAscii`
- "Pseudo \$R^2\$" for `AbstractLatex`
- "Pseudo <i>R</i><sup>2</sup>" for `AbstractHtml`
"""
struct R2McFadden <: AbstractR2
    val::Union{Float64, Nothing}
end
R2McFadden(x::RegressionModel) = try
    R2McFadden(r2(x, :McFadden))
catch
    R2McFadden(nothing)
end

"""
    label(rndr::AbstractRenderType, x::Type{R2McFadden}) = "Pseudo " * label(rndr, R2)
"""
label(rndr::AbstractRenderType, x::Type{R2McFadden}) = "Pseudo " * label(rndr, R2)

"""
See [`R2McFadden`](@ref) for details.
"""
const PseudoR2 = R2McFadden

"""
`R2CoxSnell` is the Cox-Snell ``R^2`` of the regression. Labels default to:
- "Cox-Snell R2" for `AbstractAscii`
- "Cox-Snell \$R^2\$" for `AbstractLatex`
- "Cox-Snell <i>R</i><sup>2</sup>" for `AbstractHtml`
"""
struct R2CoxSnell <: AbstractR2
    val::Union{Float64, Nothing}
end
R2CoxSnell(x::RegressionModel) = try
    R2CoxSnell(r2(x, :CoxSnell))
catch
    R2CoxSnell(nothing)
end

"""
    label(rndr::AbstractRenderType, x::Type{R2CoxSnell}) = "Cox-Snell " * label(rndr, R2)
"""
label(rndr::AbstractRenderType, x::Type{R2CoxSnell}) = "Cox-Snell " * label(rndr, R2)

"""
`R2Nagelkerke` is the Nagelkerke ``R^2`` of the regression. Labels default to:
- "Nagelkerke R2" for `AbstractAscii`
- "Nagelkerke \$R^2\$" for `AbstractLatex`
- "Nagelkerke <i>R</i><sup>2</sup>" for `AbstractHtml`
"""
struct R2Nagelkerke <: AbstractR2
    val::Union{Float64, Nothing}
end
R2Nagelkerke(x::RegressionModel) = try
    R2Nagelkerke(r2(x, :Nagelkerke))
catch
    R2Nagelkerke(nothing)
end

"""
    label(rndr::AbstractRenderType, x::Type{R2Nagelkerke}) = "Nagelkerke " * label(rndr, R2)
"""
label(rndr::AbstractRenderType, x::Type{R2Nagelkerke}) = "Nagelkerke " * label(rndr, R2)

"""
`R2Deviance` is the Deviance ``R^2`` of the regression. Labels default to:
- "Deviance R2" for `AbstractAscii`
- "Deviance \$R^2\$" for `AbstractLatex`
- "Deviance <i>R</i><sup>2</sup>" for `AbstractHtml`
"""
struct R2Deviance <: AbstractR2
    val::Union{Float64, Nothing}
end
R2Deviance(x::RegressionModel) = try
    R2Deviance(r2(x, :devianceratio))
catch
    R2Deviance(nothing)
end

"""
    label(rndr::AbstractRenderType, x::Type{R2Deviance}) = "Deviance " * label(rndr, R2)
"""
label(rndr::AbstractRenderType, x::Type{R2Deviance}) = "Deviance " * label(rndr, R2)

"""
`AdjR2` is the Adjusted ``R^2`` of the regression. Labels default to:
- "Adjusted R2" for `AbstractAscii`
- "Adjusted \$R^2\$" for `AbstractLatex`
- "Adjusted <i>R</i><sup>2</sup>" for `AbstractHtml`
"""
struct AdjR2 <: AbstractR2
    val::Union{Float64, Nothing}
end
AdjR2(x::RegressionModel) = try
    AdjR2(adjr2(x))
catch
    AdjR2(nothing)
end

"""
    label(rndr::AbstractRenderType, x::Type{AdjR2}) = "Adjusted " * label(rndr, R2)
"""
label(rndr::AbstractRenderType, x::Type{AdjR2}) = "Adjusted " * label(rndr, R2)

"""
`AdjR2McFadden` is the McFadden Adjusted ``R^2`` of the regression (often referred
to as the Pseudo Adjusted ``R^2``). Labels default to:
- "Pseudo Adjusted R2" for `AbstractAscii`
- "Pseudo Adjusted \$R^2\$" for `AbstractLatex`
- "Pseudo Adjusted <i>R</i><sup>2</sup>" for `AbstractHtml`
"""
struct AdjR2McFadden <: AbstractR2
    val::Union{Float64, Nothing}
end
AdjR2McFadden(x::RegressionModel) = try
    AdjR2McFadden(adjr2(x, :McFadden))
catch
    AdjR2McFadden(nothing)
end

"""
    label(rndr::AbstractRenderType, x::Type{AdjR2McFadden}) = "Pseudo " * label(rndr, AdjR2)
"""
label(rndr::AbstractRenderType, x::Type{AdjR2McFadden}) = "Pseudo " * label(rndr, AdjR2)

"""
See [`AdjR2McFadden`](@ref) for details.
"""
const AdjPseudoR2 = AdjR2McFadden

"""
`AdjR2Deviance` is the Deviance Adjusted ``R^2`` of the regression. Labels default to:
- "Deviance Adjusted R2" for `AbstractAscii`
- "Deviance Adjusted \$R^2\$" for `AbstractLatex`
- "Deviance Adjusted <i>R</i><sup>2</sup>" for `AbstractHtml`
"""
struct AdjR2Deviance <: AbstractR2
    val::Union{Float64, Nothing}
end
AdjR2Deviance(x::RegressionModel) = try
    AdjR2Deviance(adjr2(x, :devianceratio))
catch
    AdjR2Deviance(nothing)
end

"""
    label(rndr::AbstractRenderType, x::Type{AdjR2Deviance}) = "Deviance " * label(rndr, AdjR2)
"""
label(rndr::AbstractRenderType, x::Type{AdjR2Deviance}) = "Deviance " * label(rndr, AdjR2)

"""
`DOF` is the remaining degrees of freedom in the regression. Labels default to 
"Degrees of Freedom" for all tables.
"""
struct DOF <: AbstractRegressionStatistic
    val::Union{Int, Nothing}
end
DOF(x::RegressionModel) = try
    DOF(dof_residual(x))
catch
    DOF(nothing)
end

"""
    label(rndr::AbstractRenderType, x::Type{DOF}) = "Degrees of Freedom"
"""
label(rndr::AbstractRenderType, x::Type{DOF}) = "Degrees of Freedom"

"""
`LogLikelihood` is the log likelihood of the regression. Labels default to
"Log Likelihood" for all tables.
"""
struct LogLikelihood <: AbstractRegressionStatistic
    val::Union{Float64, Nothing}
end
LogLikelihood(x::RegressionModel) = try
    LogLikelihood(loglikelihood(x))
catch
    LogLikelihood(nothing)
end

"""
    label(rndr::AbstractRenderType, x::Type{LogLikelihood}) = "Log Likelihood"
"""
label(rndr::AbstractRenderType, x::Type{LogLikelihood}) = "Log Likelihood"

"""
`AIC` is the Akaike Information Criterion of the regression. Labels default to
"AIC" for all tables.
"""
struct AIC <: AbstractRegressionStatistic
    val::Union{Float64, Nothing}
end
AIC(x::RegressionModel) = try
    AIC(aic(x))
catch
    AIC(nothing)
end

"""
    label(rndr::AbstractRenderType, x::Type{AIC}) = "AIC"
"""
label(rndr::AbstractRenderType, x::Type{AIC}) = "AIC"

"""
`AICC` is the Corrected Akaike Information Criterion of the regression. Labels default to
"AICC" for all tables.
"""
struct AICC <: AbstractRegressionStatistic
    val::Union{Float64, Nothing}
end
AICC(x::RegressionModel) = try
    AICC(aicc(x))
catch
    AICC(nothing)
end

"""
    label(rndr::AbstractRenderType, x::Type{AICC}) = "AICC"
"""
label(rndr::AbstractRenderType, x::Type{AICC}) = "AICC"

"""
`BIC` is the Bayesian Information Criterion of the regression. Labels default to
"BIC" for all tables.
"""
struct BIC <: AbstractRegressionStatistic
    val::Union{Float64, Nothing}
end
BIC(x::RegressionModel) = try
    BIC(aicc(x))
catch
    BIC(nothing)
end

"""
    label(rndr::AbstractRenderType, x::Type{BIC}) = "BIC"
"""
label(rndr::AbstractRenderType, x::Type{BIC}) = "BIC"

"""
`FStat` is the F-statistic of the regression. Since the StatsAPI.jl package
does not provide a function for this, it is up to each package
extension to provide the relevant information. Labels default to:
- "F" for `AbstractAscii`
- "\$F\$" for `AbstractLatex`
- "<i>F</i>" for `AbstractHtml`
!!! note
    the `FStat` label is used in other labels, so changing it will change those labels as well.
"""
struct FStat <: AbstractRegressionStatistic
    val::Union{Float64, Nothing}
end
FStat(r::RegressionModel) = FStat(nothing)

"""
    label(rndr::AbstractRenderType, x::Type{FStat}) = "F"
    label(rndr::AbstractLatex, x::Type{FStat}) = "\\\$F\\\$"
    label(rndr::AbstractHtml, x::Type{FStat}) = "<i>F</i>"
"""
label(rndr::AbstractRenderType, x::Type{FStat}) = "F"

"""
`FStatPValue` is the p-value of the F-statistic of the regression. Since the StatsAPI.jl package
does not provide a function for this, it is up to each package
extension to provide the relevant information. Labels default to:
- "F p value" for `AbstractAscii`
- "\$F\$ \$p\$ value" for `AbstractLatex`
- "<i>F</i> <i>p</i> value" for `AbstractHtml`
"""
struct FStatPValue <: AbstractRegressionStatistic
    val::Union{Float64, Nothing}
end
FStatPValue(r::RegressionModel) = FStatPValue(nothing)

"""
    label(rndr::AbstractRenderType, x::Type{FStatPValue}) = label(rndr, FStat) * "-test " * label_p(rndr) * " value"
"""
label(rndr::AbstractRenderType, x::Type{FStatPValue}) = label(rndr, FStat) * "-test " * label_p(rndr) *" value"

"""
`FStatIV` is the first-stage F-statistic of an IV regression. Since the StatsAPI.jl
package does not provide a function for this, it is up to each package
extension to provide the relevant information. Labels default to:
- "First-stage F statistic" for `AbstractAscii`
- "First-stage \$F\$ statistic" for `AbstractLatex`
- "First-stage <i>F</i> statistic" for `AbstractHtml`
"""
struct FStatIV <: AbstractRegressionStatistic
    val::Union{Float64, Nothing}
end
FStatIV(r::RegressionModel) = FStatIV(nothing)

"""
    label(rndr::AbstractRenderType, x::Type{FStatIV}) = "First-stage " * label(rndr, FStat) * " statistic"
"""
label(rndr::AbstractRenderType, x::Type{FStatIV}) = "First-stage " * label(rndr, FStat) * " statistic"

"""
`FStatIVPValue` is the p-value of the first-stage F-statistic of an IV regression. Since the StatsAPI.jl
package does not provide a function for this, it is up to each package
extension to provide the relevant information. Labels default to:
- "First-stage p value" for `AbstractAscii`
- "First-stage \$p\$ value" for `AbstractLatex`
- "First-stage <i>p</i> value" for `AbstractHtml`
"""
struct FStatIVPValue <: AbstractRegressionStatistic
    val::Union{Float64, Nothing}
end
FStatIVPValue(r::RegressionModel) = FStatIVPValue(nothing)

"""
    label(rndr::AbstractRenderType, x::Type{FStatIVPValue}) = "First-stage " * label_p(rndr) * " value"
"""
label(rndr::AbstractRenderType, x::Type{FStatIVPValue}) = "First-stage " * label_p(rndr) * " value"

"""
`R2Within` is the within R-squared of a fixed effects regression. Since the StatsAPI.jl
package does not provide a function for this, it is up to each package
extension to provide the relevant information. Labels default to:
- "Within R2" for `AbstractAscii`
- "Within \$R^2\$" for `AbstractLatex`
- "Within <i>R</i><sup>2</sup>" for `AbstractHtml`
"""
struct R2Within <: AbstractR2
    val::Union{Float64, Nothing}
end
R2Within(r::RegressionModel) = R2Within(nothing)

"""
    label(rndr::AbstractRenderType, x::Type{R2Within}) = "Within " * label(rndr, R2)
"""
label(rndr::AbstractRenderType, x::Type{R2Within}) = "Within-" * label(rndr, R2)




value(s::AbstractRegressionStatistic) = s.val

Base.show(io::IO, s::AbstractRegressionStatistic) = show(io, value(s))
Base.print(io::IO, s::AbstractRegressionStatistic) = print(io, value(s))


"""
    abstract type AbstractUnderStatistic end

The abstract type for statistics that are below or next to the coefficients
(e.g., standard errors, t-statistics, confidence intervals, etc.). The default
available values are:
- [`StdError`](@ref)
- [`TStat`](@ref)
- [`ConfInt`](@ref)

New values can be added by subtyping `AbstractUnderStatistic` and defining
the struct and a constructor. The constructer should accept
the standard error, the coefficient, and the degrees of freedom.
"""
abstract type AbstractUnderStatistic end

"""
    struct TStat <: AbstractUnderStatistic
        val::Float64
    end
    TStat(se, coef, dof=0)

The t-statistic of a coefficient.
"""
struct TStat <: AbstractUnderStatistic
    val::Float64
end
TStat(se, coef, dof=0) = TStat(coef / se)

"""
    struct StdError <: AbstractUnderStatistic
        val::Float64
    end
    StdError(se, coef, dof=0)

The standard error of a coefficient.
"""
struct StdError <: AbstractUnderStatistic
    val::Float64
end
StdError(se, coef, dof=0) = StdError(se)

"""
    struct ConfInt <: AbstractUnderStatistic
        val::Tuple{Float64, Float64}
    end
    ConfInt(se, coef, dof; level=default_confint_level())

The confidence interval of a coefficient. The default confidence
level is 95% (can be changed by setting 
`RegressionTable.default_confint_level() = 0.90` or similar).
"""
struct ConfInt <: AbstractUnderStatistic
    val::Tuple{Float64, Float64}
end
default_confint_level() = 0.95
function ConfInt(se, coef, dof; level=default_confint_level())
    @assert 0 < level < 1 "Confidence level must be between 0 and 1"
    scale = quantile(TDist(dof), 1 - (1-level) / 2)
    ConfInt((coef - scale * se, coef + scale * se))
end

value(x::AbstractUnderStatistic) = x.val


"""
    struct CoefValue
        val::Float64
        pvalue::Float64
    end

The value of a coefficient and its p-value.
"""
struct CoefValue
    val::Float64
    pvalue::Float64
end
value(x::CoefValue) = x.val
value_pvalue(x::CoefValue) = x.pvalue
value_pvalue(x::Missing) = missing
value_pvalue(x::Nothing) = nothing

"""
    struct RegressionType{T}
        val::T
        is_iv::Bool
    end

The type of the regression. `val` should be a distribution from the
[Distributions.jl](https://github.com/JuliaStats/Distributions.jl) package. `is_iv` indicates whether the regression
is an instrumental variable regression.
The default label for the regression type is "Estimator". The labels
for individual regression types (e.g., "OLS", "Poisson") can be set by
running:
```julia
RegressionTables.label_ols(rndr::AbstractRenderType) = \$name
RegressionTables.label_iv(rndr::AbstractRenderType) = \$name
```
Or for individual distributions by running:
```julia
Base.repr(rndr::AbstractRenderType, x::\$Distribution; args...) = \$Name
```
"""
struct RegressionType{T}
    val::T
    is_iv::Bool
    RegressionType(x::T, is_iv::Bool=false) where {T<:UnivariateDistribution} = new{T}(x, is_iv)
    RegressionType(x::T, is_iv::Bool=false) where {T<:AbstractString} = new{T}(x, is_iv)
end
RegressionType(x::Type{D}, is_iv::Bool=false) where {D <: UnivariateDistribution} = RegressionType(Base.typename(D).wrapper(), is_iv)
value(x::RegressionType) = x.val

"""
    label(rndr::AbstractRenderType, x::Type{RegressionType}) = "Estimator"
"""
label(rndr::AbstractRenderType, x::Type{<:RegressionType}) = "Estimator"

"""
    struct HasControls
        val::Bool
    end

Indicates whether the regression has coefficients left out of the table.
`HasControls` is used as a label, which defaults to "Controls". This can
be changed by setting
```julia
RegressionTables.label(rndr::AbstractRenderType, x::Type{RegressionTables.HasControls}) = \$name
```
"""
struct HasControls
    val::Bool
end
value(x::HasControls) = x.val

"""
    label(rndr::AbstractRenderType, x::Type{HasControls}) = "Controls"
"""
label(rndr::AbstractRenderType, x::Type{HasControls}) = "Controls"

"""
    struct RegressionNumbers
        val::Int
    end

Used to define which column number the regression is in.
Primarily, this is used to control how these values are displayed.
The default displays these as `(\$i)`, which can be set by running
```julia
RegressionTables.number_regressions_decoration(rndr::AbstractRenderType, s) = "(\$s)"
```
"""
struct RegressionNumbers
    val::Int
end
value(x::RegressionNumbers) = x.val

"""
    label(rndr::AbstractRenderType, x::Type{RegressionNumbers}) = ""
"""
label(rndr::AbstractRenderType, x::Type{RegressionNumbers}) = ""

value(x) = missing
value(x::String) = x

"""
    struct FixedEffectValue
        val::Bool
    end

A simple store of true/false for whether a fixed effect is used in the regression, used to determine
how to display the value. The default is `"Yes"` and `""`, which can be changed by setting [`fe_value`](@ref).
"""
struct FixedEffectValue
    val::Bool
end

value(x::FixedEffectValue) = x.val

"""
    struct RandomEffectValue
        val::Real
    end

A simple sotre of the random effect value, by default equal to the standard deviation of the random effect.
Typically will then be displayed the same as other `Float64` values.
"""
struct RandomEffectValue
    val::Real# real so it could also be changed to true/false
end

value(x::RandomEffectValue) = x.val