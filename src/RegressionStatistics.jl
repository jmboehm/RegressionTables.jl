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
    YMean(mean(x.rr.Y))
catch
    YMean(nothing)
end
RegressionTable.label(rndr::AbstractRenderType, x::Type{YMean}) = "Mean of Y"
```
```
"""
abstract type AbstractRegressionStatistic end

abstract type AbstractR2 <: AbstractRegressionStatistic end

"""
`Nobs` is the number of observations in the regression. Labels default to:
- "N" for `AbstractAscii`
- "\$N\$" for `AbstractLatex`
- "<i>N</i>" for `AbstractHTML`
"""
struct Nobs <: AbstractRegressionStatistic
    val::Union{Int, Nothing}
end
Nobs(x::RegressionModel) = try
    Nobs(nobs(x))
catch
    Nobs(nothing)
end
label(rndr::AbstractRenderType, x::Type{Nobs}) = "N"

"""
`R2` is the ``R^2`` of the regression. Labels default to:
- "R2" for `AbstractAscii`
- "\$R^2\$" for `AbstractLatex`
- "<i>R</i><sup>2</sup>" for `AbstractHTML`

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
label(rndr::AbstractRenderType, x::Type{R2}) = "R2"

"""
`R2McFadden` is the McFadden ``R^2`` of the regression (often referred to as the Pseudo-``R^2``).
Labels default to:
- "Pseudo R2" for `AbstractAscii`
- "Pseudo \$R^2\$" for `AbstractLatex`
- "Pseudo <i>R</i><sup>2</sup>" for `AbstractHTML`
"""
struct R2McFadden <: AbstractR2
    val::Union{Float64, Nothing}
end
R2McFadden(x::RegressionModel) = try
    R2McFadden(r2(x, :McFadden))
catch
    R2McFadden(nothing)
end
label(rndr::AbstractRenderType, x::Type{R2McFadden}) = "Pseudo " * label(rndr, R2)

"""
See [`R2McFadden`](@ref) for details.
"""
const PseudoR2 = R2McFadden

"""
`R2CoxSnell` is the Cox-Snell ``R^2`` of the regression. Labels default to:
- "Cox-Snell R2" for `AbstractAscii`
- "Cox-Snell \$R^2\$" for `AbstractLatex`
- "Cox-Snell <i>R</i><sup>2</sup>" for `AbstractHTML`
"""
struct R2CoxSnell <: AbstractR2
    val::Union{Float64, Nothing}
end
R2CoxSnell(x::RegressionModel) = try
    R2CoxSnell(r2(x, :CoxSnell))
catch
    R2CoxSnell(nothing)
end
label(rndr::AbstractRenderType, x::Type{R2CoxSnell}) = "Cox-Snell " * label(rndr, R2)

"""
`R2Nagelkerke` is the Nagelkerke ``R^2`` of the regression. Labels default to:
- "Nagelkerke R2" for `AbstractAscii`
- "Nagelkerke \$R^2\$" for `AbstractLatex`
- "Nagelkerke <i>R</i><sup>2</sup>" for `AbstractHTML`
"""
struct R2Nagelkerke <: AbstractR2
    val::Union{Float64, Nothing}
end
R2Nagelkerke(x::RegressionModel) = try
    R2Nagelkerke(r2(x, :Nagelkerke))
catch
    R2Nagelkerke(nothing)
end
label(rndr::AbstractRenderType, x::Type{R2Nagelkerke}) = "Nagelkerke " * label(rndr, R2)

"""
`R2Deviance` is the Deviance ``R^2`` of the regression. Labels default to:
- "Deviance R2" for `AbstractAscii`
- "Deviance \$R^2\$" for `AbstractLatex`
- "Deviance <i>R</i><sup>2</sup>" for `AbstractHTML`
"""
struct R2Deviance <: AbstractR2
    val::Union{Float64, Nothing}
end
R2Deviance(x::RegressionModel) = try
    R2Deviance(r2(x, :devianceratio))
catch
    R2Deviance(nothing)
end
label(rndr::AbstractRenderType, x::Type{R2Deviance}) = "Deviance " * label(rndr, R2)

"""
`AdjR2` is the Adjusted ``R^2`` of the regression. Labels default to:
- "Adjusted R2" for `AbstractAscii`
- "Adjusted \$R^2\$" for `AbstractLatex`
- "Adjusted <i>R</i><sup>2</sup>" for `AbstractHTML`
"""
struct AdjR2 <: AbstractR2
    val::Union{Float64, Nothing}
end
AdjR2(x::RegressionModel) = try
    AdjR2(adjr2(x))
catch
    AdjR2(nothing)
end
label(rndr::AbstractRenderType, x::Type{AdjR2}) = "Adjusted " * label(rndr, R2)

"""
`AdjR2McFadden` is the McFadden Adjusted ``R^2`` of the regression (often referred
to as the Pseudo Adjusted ``R^2``). Labels default to:
- "Pseudo Adjusted R2" for `AbstractAscii`
- "Pseudo Adjusted \$R^2\$" for `AbstractLatex`
- "Pseudo Adjusted <i>R</i><sup>2</sup>" for `AbstractHTML`
"""
struct AdjR2McFadden <: AbstractR2
    val::Union{Float64, Nothing}
end
AdjR2McFadden(x::RegressionModel) = try
    AdjR2McFadden(adjr2(x, :McFadden))
catch
    AdjR2McFadden(nothing)
end
label(rndr::AbstractRenderType, x::Type{AdjR2McFadden}) = "Pseudo " * label(rndr, AdjR2)

"""
See [`AdjR2McFadden`](@ref) for details.
"""
const AdjPsuedoR2 = AdjR2McFadden

"""
`AdjR2Deviance` is the Deviance Adjusted ``R^2`` of the regression. Labels default to:
- "Deviance Adjusted R2" for `AbstractAscii`
- "Deviance Adjusted \$R^2\$" for `AbstractLatex`
- "Deviance Adjusted <i>R</i><sup>2</sup>" for `AbstractHTML`
"""
struct AdjR2Deviance <: AbstractR2
    val::Union{Float64, Nothing}
end
AdjR2Deviance(x::RegressionModel) = try
    AdjR2Deviance(adjr2(x, :devianceratio))
catch
    AdjR2Deviance(nothing)
end
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
label(rndr::AbstractRenderType, x::Type{BIC}) = "BIC"

"""
`FStat` is the F-statistic of the regression. Since the StatsAPI.jl package
does not provide a function for this, it is up to each package
extension to provide the relevant information. Labels default to:
- "F" for `AbstractAscii`
- "\$F\$" for `AbstractLatex`
- "<i>F</i>" for `AbstractHTML`
!!! note
    the `FStat` label is used in other labels, so changing it will change those labels as well.
"""
struct FStat <: AbstractRegressionStatistic
    val::Union{Float64, Nothing}
end
FStat(r::RegressionModel) = FStat(nothing)
label(rndr::AbstractRenderType, x::Type{FStat}) = "F"

"""
`FStatPValue` is the p-value of the F-statistic of the regression. Since the StatsAPI.jl package
does not provide a function for this, it is up to each package
extension to provide the relevant information. Labels default to:
- "F p value" for `AbstractAscii`
- "\$F\$ \$p\$ value" for `AbstractLatex`
- "<i>F</i> <i>p</i> value" for `AbstractHTML`
"""
struct FStatPValue <: AbstractRegressionStatistic
    val::Union{Float64, Nothing}
end
FStatPValue(r::RegressionModel) = FStatPValue(nothing)
label(rndr::AbstractRenderType, x::Type{FStatPValue}) = label(rndr, FStat) * "-test " * label_p(rndr) *" value"

"""
`FStatIV` is the first-stage F-statistic of an IV regression. Since the StatsAPI.jl
package does not provide a function for this, it is up to each package
extension to provide the relevant information. Labels default to:
- "First-stage F statistic" for `AbstractAscii`
- "First-stage \$F\$ statistic" for `AbstractLatex`
- "First-stage <i>F</i> statistic" for `AbstractHTML`
"""
struct FStatIV <: AbstractRegressionStatistic
    val::Union{Float64, Nothing}
end
FStatIV(r::RegressionModel) = FStatIV(nothing)
label(rndr::AbstractRenderType, x::Type{FStatIV}) = "First-stage " * label(rndr, FStat) * " statistic"

"""
`FStatIVPValue` is the p-value of the first-stage F-statistic of an IV regression. Since the StatsAPI.jl
package does not provide a function for this, it is up to each package
extension to provide the relevant information. Labels default to:
- "First-stage p value" for `AbstractAscii`
- "First-stage \$p\$ value" for `AbstractLatex`
- "First-stage <i>p</i> value" for `AbstractHTML`
"""
struct FStatIVPValue <: AbstractRegressionStatistic
    val::Union{Float64, Nothing}
end
FStatIVPValue(r::RegressionModel) = FStatIVPValue(nothing)
label(rndr::AbstractRenderType, x::Type{FStatIVPValue}) = "First-stage " * label_p(rndr) * " value"

"""
`R2Within` is the within R-squared of a fixed effects regression. Since the StatsAPI.jl
package does not provide a function for this, it is up to each package
extension to provide the relevant information. Labels default to:
- "Within R2" for `AbstractAscii`
- "Within \$R^2\$" for `AbstractLatex`
- "Within <i>R</i><sup>2</sup>" for `AbstractHTML`
"""
struct R2Within <: AbstractR2
    val::Union{Float64, Nothing}
end
R2Within(r::RegressionModel) = R2Within(nothing)
label(rndr::AbstractRenderType, x::Type{R2Within}) = "Within-" * label(rndr, R2)




value(s::AbstractRegressionStatistic) = s.val

Base.show(io::IO, s::AbstractRegressionStatistic) = show(io, value(s))
Base.print(io::IO, s::AbstractRegressionStatistic) = print(io, value(s))


abstract type AbstractUnderStatistic end

struct TStat <: AbstractUnderStatistic
    val::Float64
end
TStat(stderror, coef) = TStat(coef / stderror)

struct STDError <: AbstractUnderStatistic
    val::Float64
end
STDError(stderror, coef) = STDError(stderror)

value(x::AbstractUnderStatistic) = x.val

struct CoefValue
    val::Float64
    pvalue::Float64
end
value(x::CoefValue) = x.val
value_pvalue(x::CoefValue) = x.pvalue
value_pvalue(x::Missing) = missing
value_pvalue(x::Nothing) = nothing

struct RegressionType{T}
    val::T
    is_iv::Bool
    RegressionType(x::T, is_iv::Bool=false) where {T<:UnivariateDistribution} = new{T}(x, is_iv)
    RegressionType(x::T, is_iv::Bool=false) where {T<:AbstractString} = new{T}(x, is_iv)
end
RegressionType(x::Type{D}, is_iv::Bool=false) where {D <: UnivariateDistribution} = RegressionType(Base.typename(D).wrapper(), is_iv)
value(x::RegressionType) = x.val
label(rndr::AbstractRenderType, x::Type{<:RegressionType}) = "Estimator"

struct HasControls
    val::Bool
end
value(x::HasControls) = x.val
label(rndr::AbstractRenderType, x::Type{HasControls}) = "Controls"

struct RegressionNumbers
    val::Int
end
value(x::RegressionNumbers) = x.val
label(rndr::AbstractRenderType, x::Type{RegressionNumbers}) = ""

value(x) = missing