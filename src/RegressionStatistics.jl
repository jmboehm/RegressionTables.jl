abstract type AbstractRegressionStatistic{T} end

struct Nobs{T<:Union{Int, Nothing}} <: AbstractRegressionStatistic{T}
    val::T
end
Nobs(x::RegressionModel) = try
    Nobs(nobs(x))
catch
    Nobs(nothing)
end
label(rndr::AbstractRenderType, x::Type{<:Nobs}) = "N"

struct R2{T<:Union{Float64, Nothing}} <: AbstractRegressionStatistic{T}
    val::T
end
R2(x::RegressionModel) = try
    R2(r2(x))
catch
    R2(nothing)
end
label(rndr::AbstractRenderType, x::Type{<:R2}) = "R2"

struct R2McFadden{T<:Union{Float64, Nothing}} <: AbstractRegressionStatistic{T}
    val::T
end
R2McFadden(x::RegressionModel) = try
    R2McFadden(r2(x, :McFadden))
catch
    R2McFadden(nothing)
end
label(rndr::AbstractRenderType, x::Type{<:R2McFadden}) = "McFadden " * label(rndr, R2)

struct R2CoxSnell{T<:Union{Float64, Nothing}} <: AbstractRegressionStatistic{T}
    val::T
end
R2CoxSnell(x::RegressionModel) = try
    R2CoxSnell(r2(x, :CoxSnell))
catch
    R2CoxSnell(nothing)
end
label(rndr::AbstractRenderType, x::Type{<:R2CoxSnell}) = "Cox-Snell " * label(rndr, R2)

struct R2Nagelkerke{T<:Union{Float64, Nothing}} <: AbstractRegressionStatistic{T}
    val::T
end
R2Nagelkerke(x::RegressionModel) = try
    R2Nagelkerke(r2(x, :Nagelkerke))
catch
    R2Nagelkerke(nothing)
end
label(rndr::AbstractRenderType, x::Type{<:R2Nagelkerke}) = "Nagelkerke " * label(rndr, R2)

struct R2Deviance{T<:Union{Float64, Nothing}} <: AbstractRegressionStatistic{T}
    val::T
end
R2Deviance(x::RegressionModel) = try
    R2Deviance(r2(x, :devianceratio))
catch
    R2Deviance(nothing)
end
label(rndr::AbstractRenderType, x::Type{<:R2Deviance}) = "Deviance " * label(rndr, R2)

struct AdjR2{T<:Union{Float64, Nothing}} <: AbstractRegressionStatistic{T}
    val::T
end
AdjR2(x::RegressionModel) = try
    AdjR2(adjr2(x))
catch
    AdjR2(nothing)
end
label(rndr::AbstractRenderType, x::Type{<:AdjR2}) = "Adjusted " * label(rndr, R2)

struct AdjR2McFadden{T<:Union{Float64, Nothing}} <: AbstractRegressionStatistic{T}
    val::T
end
AdjR2McFadden(x::RegressionModel) = try
    AdjR2McFadden(adjr2(x, :McFadden))
catch
    AdjR2McFadden(nothing)
end
label(rndr::AbstractRenderType, x::Type{<:AdjR2McFadden}) = "McFadden " * label(rndr, AdjR2)

struct AdjR2Deviance{T<:Union{Float64, Nothing}} <: AbstractRegressionStatistic{T}
    val::T
end
AdjR2Deviance(x::RegressionModel) = try
    AdjR2Deviance(adjr2(x, :devianceratio))
catch
    AdjR2Deviance(nothing)
end
label(rndr::AbstractRenderType, x::Type{<:AdjR2Deviance}) = "Deviance " * label(rndr, AdjR2)

struct DOF{T<:Union{Int, Nothing}} <: AbstractRegressionStatistic{T}
    val::T
end
DOF(x::RegressionModel) = try
    DOF(dof(x))
catch
    DOF(nothing)
end
label(rndr::AbstractRenderType, x::Type{<:DOF}) = "Degrees of Freedom"

struct LogLikelihood{T<:Union{Float64, Nothing}} <: AbstractRegressionStatistic{T}
    val::T
end
LogLikelihood(x::RegressionModel) = try
    LogLikelihood(loglikelihood(x))
catch
    LogLikelihood(nothing)
end
label(rndr::AbstractRenderType, x::Type{<:LogLikelihood}) = "Log Likelihood"

struct AIC{T<:Union{Float64, Nothing}} <: AbstractRegressionStatistic{T}
    val::T
end
AIC(x::RegressionModel) = try
    AIC(aic(x))
catch
    AIC(nothing)
end
label(rndr::AbstractRenderType, x::Type{<:AIC}) = "AIC"

struct AICC{T<:Union{Float64, Nothing}} <: AbstractRegressionStatistic{T}
    val::T
end
AICC(x::RegressionModel) = try
    AICC(aicc(x))
catch
    AICC(nothing)
end
label(rndr::AbstractRenderType, x::Type{<:AICC}) = "AICC"

struct BIC{T<:Union{Float64, Nothing}} <: AbstractRegressionStatistic{T}
    val::T
end
BIC(x::RegressionModel) = try
    BIC(aicc(x))
catch
    BIC(nothing)
end
label(rndr::AbstractRenderType, x::Type{<:BIC}) = "BIC"

struct FStat{T<:Union{Float64, Nothing}} <: RegressionTables.AbstractRegressionStatistic{T}
    val::T
end
FStat(r::RegressionModel) = FStat(nothing)
RegressionTables.label(rndr::AbstractRenderType, x::Type{<:FStat}) = "F"

struct FStatPValue{T<:Union{Float64, Nothing}} <: RegressionTables.AbstractRegressionStatistic{T}
    val::T
end
FStatPValue(r::RegressionModel) = FStatPValue(nothing)
RegressionTables.label(rndr::AbstractRenderType, x::Type{<:FStatPValue}) =
    RegressionTables.label(rndr, FStat) * "-test " * RegressionTables.label_p(rndr) *" value"



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
label(rndr::AbstractRenderType, x::Type{RegressionType}) = "Estimator"

abstract type AbstractCoefName end
(::Type{T})(x::T) where {T<:AbstractCoefName} = x
Base.broadcastable(x::AbstractCoefName) = Ref(x)

# for functionterm and continuousterm
#=
It might be nice to add a separate functionterm piece so that the internals could easily
change just like InteractedCoefName, but the internals are not parsed in the same way
which makes that extremely difficult to do
=#
struct CoefName <: AbstractCoefName
    name::String
    CoefName(name::String) = new(name)
end
value(x::CoefName) = x.name
Base.string(x::CoefName) = value(x)


function Base.get(x::Dict{String, String}, val::CoefName, def::CoefName)
    if haskey(x, value(val))
        return x[value(val)]
    else
        def
    end
end
get_coefname(x::AbstractTerm) = CoefName(coefnames(x))

# for interactionterm
struct InteractedCoefName <: AbstractCoefName
    names::Vector
    InteractedCoefName(names::Vector) = new(names)
end
Base.values(x::InteractedCoefName) = x.names
Base.string(x::InteractedCoefName) = join(x.names, " & ")
Base.:(==)(x::InteractedCoefName, y::InteractedCoefName) = sort(string.(values(x))) == sort(string.(values(y)))
function Base.get(x::Dict{String, String}, val::InteractedCoefName, def::InteractedCoefName)
    # if the interaction exactly matches what would be in StatsModels, just return that
    # otherwise, go through each term in the interactionterm and see if the dict contains those pieces
    if haskey(x, string(val))
        return x[string(val)]
    else
        InteractedCoefName(get.(Ref(x), values(val), values(def)))
    end
end
get_coefname(x::InteractionTerm) = 
    StatsModels.kron_insideout(
        (args...) -> InteractedCoefName(collect(args)),
        (StatsModels.vectorize(get_coefname.(x.terms)))...
    )

# for categoricalterm
struct CategoricalCoefName <: AbstractCoefName
    name::String
    level::String
    CategoricalCoefName(name::String, level::String) = new(name, level)
end
value(x::CategoricalCoefName) = x.name
Base.string(x::CategoricalCoefName) = "$(value(x)): $(x.level)"
get_coefname(x::CategoricalTerm) = [CategoricalCoefName(string(x.sym), string(n)) for n in x.contrasts.termnames]
function Base.get(x::Dict{String, String}, val::CategoricalCoefName, def::CategoricalCoefName)
    # similar to interactioncoefname, if the categorical term exactly matches what would be in StatsModels, just return that
    if haskey(x, string(val))
        return x[string(val)]
    else
        nm = get(x, value(val), value(def))
        lvl = get(x, val.level, def.level)
        CategoricalCoefName(nm, lvl)
    end
end

struct InterceptCoefName <: AbstractCoefName end
Base.string(x::InterceptCoefName) = "(Intercept)"
get_coefname(x::InterceptTerm{H}) where {H} = H ? InterceptCoefName() : []
Base.get(x::Dict{String, String}, val::InterceptCoefName, def::InterceptCoefName) = get(x, string(val), def)


