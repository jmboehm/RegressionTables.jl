abstract type AbstractRegressionStatistic end

abstract type AbstractR2 <: AbstractRegressionStatistic end

struct Nobs <: AbstractRegressionStatistic
    val::Union{Int, Nothing}
end
Nobs(x::RegressionModel) = try
    Nobs(nobs(x))
catch
    Nobs(nothing)
end
label(rndr::AbstractRenderType, x::Type{Nobs}) = "N"

struct R2 <: AbstractR2
    val::Union{Float64, Nothing}
end
R2(x::RegressionModel) = try
    R2(r2(x))
catch
    R2(nothing)
end
label(rndr::AbstractRenderType, x::Type{R2}) = "R2"

struct R2McFadden <: AbstractR2
    val::Union{Float64, Nothing}
end
R2McFadden(x::RegressionModel) = try
    R2McFadden(r2(x, :McFadden))
catch
    R2McFadden(nothing)
end
label(rndr::AbstractRenderType, x::Type{R2McFadden}) = "Pseudo " * label(rndr, R2)

struct R2CoxSnell <: AbstractR2
    val::Union{Float64, Nothing}
end
R2CoxSnell(x::RegressionModel) = try
    R2CoxSnell(r2(x, :CoxSnell))
catch
    R2CoxSnell(nothing)
end
label(rndr::AbstractRenderType, x::Type{R2CoxSnell}) = "Cox-Snell " * label(rndr, R2)

struct R2Nagelkerke <: AbstractR2
    val::Union{Float64, Nothing}
end
R2Nagelkerke(x::RegressionModel) = try
    R2Nagelkerke(r2(x, :Nagelkerke))
catch
    R2Nagelkerke(nothing)
end
label(rndr::AbstractRenderType, x::Type{R2Nagelkerke}) = "Nagelkerke " * label(rndr, R2)

struct R2Deviance <: AbstractR2
    val::Union{Float64, Nothing}
end
R2Deviance(x::RegressionModel) = try
    R2Deviance(r2(x, :devianceratio))
catch
    R2Deviance(nothing)
end
label(rndr::AbstractRenderType, x::Type{R2Deviance}) = "Deviance " * label(rndr, R2)

struct AdjR2 <: AbstractR2
    val::Union{Float64, Nothing}
end
AdjR2(x::RegressionModel) = try
    AdjR2(adjr2(x))
catch
    AdjR2(nothing)
end
label(rndr::AbstractRenderType, x::Type{AdjR2}) = "Adjusted " * label(rndr, R2)

struct AdjR2McFadden <: AbstractR2
    val::Union{Float64, Nothing}
end
AdjR2McFadden(x::RegressionModel) = try
    AdjR2McFadden(adjr2(x, :McFadden))
catch
    AdjR2McFadden(nothing)
end
label(rndr::AbstractRenderType, x::Type{AdjR2McFadden}) = "McFadden " * label(rndr, AdjR2)

struct AdjR2Deviance <: AbstractR2
    val::Union{Float64, Nothing}
end
AdjR2Deviance(x::RegressionModel) = try
    AdjR2Deviance(adjr2(x, :devianceratio))
catch
    AdjR2Deviance(nothing)
end
label(rndr::AbstractRenderType, x::Type{AdjR2Deviance}) = "Deviance " * label(rndr, AdjR2)

struct DOF <: AbstractRegressionStatistic
    val::Union{Int, Nothing}
end
DOF(x::RegressionModel) = try
    DOF(dof_residual(x))
catch
    DOF(nothing)
end
label(rndr::AbstractRenderType, x::Type{DOF}) = "Degrees of Freedom"

struct LogLikelihood <: AbstractRegressionStatistic
    val::Union{Float64, Nothing}
end
LogLikelihood(x::RegressionModel) = try
    LogLikelihood(loglikelihood(x))
catch
    LogLikelihood(nothing)
end
label(rndr::AbstractRenderType, x::Type{LogLikelihood}) = "Log Likelihood"

struct AIC <: AbstractRegressionStatistic
    val::Union{Float64, Nothing}
end
AIC(x::RegressionModel) = try
    AIC(aic(x))
catch
    AIC(nothing)
end
label(rndr::AbstractRenderType, x::Type{AIC}) = "AIC"

struct AICC <: AbstractRegressionStatistic
    val::Union{Float64, Nothing}
end
AICC(x::RegressionModel) = try
    AICC(aicc(x))
catch
    AICC(nothing)
end
label(rndr::AbstractRenderType, x::Type{AICC}) = "AICC"

struct BIC <: AbstractRegressionStatistic
    val::Union{Float64, Nothing}
end
BIC(x::RegressionModel) = try
    BIC(aicc(x))
catch
    BIC(nothing)
end
label(rndr::AbstractRenderType, x::Type{BIC}) = "BIC"

struct FStat <: AbstractRegressionStatistic
    val::Union{Float64, Nothing}
end
FStat(r::RegressionModel) = FStat(nothing)
label(rndr::AbstractRenderType, x::Type{FStat}) = "F"

struct FStatPValue <: AbstractRegressionStatistic
    val::Union{Float64, Nothing}
end
FStatPValue(r::RegressionModel) = FStatPValue(nothing)
label(rndr::AbstractRenderType, x::Type{FStatPValue}) = label(rndr, FStat) * "-test " * label_p(rndr) *" value"

struct FStatIV <: AbstractRegressionStatistic
    val::Union{Float64, Nothing}
end
FStatIV(r::RegressionModel) = FStatIV(nothing)
label(rndr::AbstractRenderType, x::Type{FStatIV}) = "First-stage " * label(rndr, FStat) * " statistic"

struct FStatIVPValue <: AbstractRegressionStatistic
    val::Union{Float64, Nothing}
end
FStatIVPValue(r::RegressionModel) = FStatIVPValue(nothing)
label(rndr::AbstractRenderType, x::Type{FStatIVPValue}) = "First-stage " * label_p(rndr) * " value"

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