abstract type AbstractRegressionStatistic{T} end

struct Nobs{T<:Union{Int, Nothing}} <: AbstractRegressionStatistic{T}
    val::T
end
Nobs(x::RegressionModel) = Nobs(nobs(x))
label(tab::AbstractRenderType, x::Type{<:Nobs}) = "N"

struct R2{T<:Union{Float64, Nothing}} <: AbstractRegressionStatistic{T}
    val::T
end
R2(x::RegressionModel) = R2(r2(x))
label(tab::AbstractRenderType, x::Type{<:R2}) = "R2"

struct R2McFadden{T<:Union{Float64, Nothing}} <: AbstractRegressionStatistic{T}
    val::T
end
R2McFadden(x::RegressionModel) = R2McFadden(r2(x, :McFadden))
label(tab::AbstractRenderType, x::Type{<:R2McFadden}) = "McFadden " * label(tab, R2)

struct R2CoxSnell{T<:Union{Float64, Nothing}} <: AbstractRegressionStatistic{T}
    val::T
end
R2CoxSnell(x::RegressionModel) = R2CoxSnell(r2(x, :CoxSnell))
label(tab::AbstractRenderType, x::Type{<:R2CoxSnell}) = "Cox-Snell " * label(tab, R2)

struct R2Nagelkerke{T<:Union{Float64, Nothing}} <: AbstractRegressionStatistic{T}
    val::T
end
R2Nagelkerke(x::RegressionModel) = R2Nagelkerke(r2(x, :Nagelkerke))
label(tab::AbstractRenderType, x::Type{<:R2Nagelkerke}) = "Nagelkerke " * label(tab, R2)

struct R2Deviance{T<:Union{Float64, Nothing}} <: AbstractRegressionStatistic{T}
    val::T
end
R2Deviance(x::RegressionModel) = R2Deviance(r2(x, :devianceratio))
label(tab::AbstractRenderType, x::Type{<:R2Deviance}) = "Deviance " * label(tab, R2)

struct AdjR2{T<:Union{Float64, Nothing}} <: AbstractRegressionStatistic{T}
    val::T
end
AdjR2(x::RegressionModel) = AdjR2(adjr2(x))
label(tab::AbstractRenderType, x::Type{<:AdjR2}) = "Adjusted " * label(tab, R2)

struct AdjR2McFadden{T<:Union{Float64, Nothing}} <: AbstractRegressionStatistic{T}
    val::T
end
AdjR2McFadden(x::RegressionModel) = AdjR2McFadden(adjr2(x, :McFadden))
label(tab::AbstractRenderType, x::Type{<:AdjR2McFadden}) = "McFadden " * label(tab, AdjR2)

struct AdjR2Deviance{T<:Union{Float64, Nothing}} <: AbstractRegressionStatistic{T}
    val::T
end
AdjR2Deviance(x::RegressionModel) = AdjR2Deviance(adjr2(x, :devianceratio))
label(tab::AbstractRenderType, x::Type{<:AdjR2Deviance}) = "Deviance " * label(tab, AdjR2)

struct DOF{T<:Union{Int, Nothing}} <: AbstractRegressionStatistic{T}
    val::T
end
DOF(x::RegressionModel) = DOF(dof(x))
label(tab::AbstractRenderType, x::Type{<:DOF}) = "Degrees of Freedom"

struct LogLikelihood{T<:Union{Float64, Nothing}} <: AbstractRegressionStatistic{T}
    val::T
end
LogLikelihood(x::RegressionModel) = LogLikelihood(loglikelihood(x))
label(tab::AbstractRenderType, x::Type{<:LogLikelihood}) = "Log Likelihood"

struct AIC{T<:Union{Float64, Nothing}} <: AbstractRegressionStatistic{T}
    val::T
end
AIC(x::RegressionModel) = AIC(aic(x))
label(tab::AbstractRenderType, x::Type{<:AIC}) = "AIC"

struct AICC{T<:Union{Float64, Nothing}} <: AbstractRegressionStatistic{T}
    val::T
end
AICC(x::RegressionModel) = AICC(aicc(x))
label(tab::AbstractRenderType, x::Type{<:AICC}) = "AICC"

struct BIC{T<:Union{Float64, Nothing}} <: AbstractRegressionStatistic{T}
    val::T
end
BIC(x::RegressionModel) = BIC(aicc(x))
label(tab::AbstractRenderType, x::Type{<:BIC}) = "BIC"



value(s::AbstractRegressionStatistic) = s.val

Base.show(io::IO, s::AbstractRegressionStatistic{Nothing}) = show(io, "")
Base.show(io::IO, s::AbstractRegressionStatistic) = show(io, value(s))
Base.print(io::IO, s::AbstractRegressionStatistic{Nothing}) = print(io, "")
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

struct RegressionType
    val::Symbol
end
value(x::RegressionType) = x.val
label(tab::AbstractRenderType, x::Type{RegressionType}) = "Estimator"
