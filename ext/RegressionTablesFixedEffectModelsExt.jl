module RegressionTablesFixedEffectModelsExt

using FixedEffectModels, RegressionTables

export FStat, FStatPvalue, FStatIV, FStatIVPvalue, R2Within

struct FStat{T<:Union{Float64, Nothing}} <: RegressionTables.AbstractRegressionStatistic{T}
    val::T
end
FStat(r::RegressionModel) = FStat(nothing)
RegressionTables.label(tab::AbstractRenderType, x::Type{<:FStat}) = "F"

struct FStatPvalue{T<:Union{Float64, Nothing}} <: RegressionTables.AbstractRegressionStatistic{T}
    val::T
end
FStatPValue(r::RegressionModel) = FStatPvalue(nothing)
RegressionTables.label(tab::AbstractRenderType, x::Type{<:FStatPvalue}) =
    RegressionTables.label(tab, FStat) * "-test " * RegressionTables.label_p(tab) *" value"

struct FStatIV{T<:Union{Float64, Nothing}} <: RegressionTables.AbstractRegressionStatistic{T}
    val::T
end
FStatIV(r::RegressionModel) = FStatIV(nothing)
RegressionTables.label(tab::AbstractRenderType, x::Type{<:FStatIV}) = "First-stage " * RegressionTables.label(tab, FStat) * " statistic"

struct FStatIVPvalue{T<:Union{Float64, Nothing}} <: RegressionTables.AbstractRegressionStatistic{T}
    val::T
end
FStatIVPValue(r::RegressionModel) = FStatIVPvalue(nothing)
RegressionTables.label(tab::AbstractRenderType, x::Type{<:FStatIVPvalue}) = "First-stage " * RegressionTables.label_p(tab) * " value"

struct R2Within{T<:Union{Float64, Nothing}} <: RegressionTables.AbstractRegressionStatistic{T}
    val::T
end
R2Within(r::RegressionModel) = R2Within(nothing)
RegressionTables.label(tab::AbstractRenderType, x::Type{<:R2Within}) = "Within-" * RegressionTables.label(tab, R2)

RegressionTables.FStat(x::FixedEffectModel) = FStat(x.F)
RegressionTables.FStatPValue(x::FixedEffectModel) = FStatPvalue(x.p)

RegressionTables.FStatIV(x::FixedEffectModel) = FStatIV(x.F_kp) # is a value or missing already
RegressionTables.FStatIVPValue(x::FixedEffectModel) = FStatIVPvalue(x.p_kp) # is a value or missing already

RegressionTables.R2Within(x::FixedEffectModel) = R2Within(x.r2_within) # is a value or missing already

RegressionTables.regressiontype(x::FixedEffectModel) = has_iv(x) ? :IV : :OLS

function fe_terms(rr::RegressionModel)
    out = Symbol[]
    if !isdefined(rr, :formula)
        return out
    end
    for t in eachterm(rr.formula.rhs)
        if has_fe(t)
            push!(out, fesymbol(t))
        end
    end
    out
end

function RegressionTables.regtablesingle(
    rr::FixedEffectModel;
    fixedeffects = String[],
    args...
)
    fekeys = string.(rr.fekeys)
    if length(fixedeffects) > 0
        fekeys = [x for x in fekeys if x in fixedeffects]
    end
    RegressionTables.RegressionTableSingle(
        rr;
        fixedeffects = length(fekeys) > 0 ? fekeys : nothing,
        args...
    )
end

end