module RegressionTablesFixedEffectModelsExt

using FixedEffectModels, RegressionTables, Distributions


RegressionTables.FStat(x::FixedEffectModel) = FStat(x.F)
RegressionTables.FStatPValue(x::FixedEffectModel) = FStatPValue(x.p)

RegressionTables.FStatIV(x::FixedEffectModel) = has_iv(x) ? FStatIV(x.F_kp) : FStatIV(nothing)
RegressionTables.FStatIVPValue(x::FixedEffectModel) = has_iv(x) ? FStatIVPValue(x.p_kp) : FStatIVPValue(nothing)

RegressionTables.R2Within(x::FixedEffectModel) = has_fe(x) ? R2Within(x.r2_within) : R2Within(nothing)

RegressionTables.RegressionType(x::FixedEffectModel) = RegressionType(Normal(), has_iv(x))

RegressionTables.get_coefname(x::StatsModels.FunctionTerm{typeof(FixedEffectModels.fe)}) = RegressionTables.CoefName(string(x.exorig.args[end]))
RegressionTables.get_coefname(x::FixedEffectModels.FixedEffectTerm) = RegressionTables.CoefName(string(x.x))

"""
    RegressionTables.other_stats(rr::FixedEffectModel; fixedeffects=String[], fe_suffix="Fixed Effects")

Return a vector of fixed effects terms. If `fixedeffects` is not empty, only the fixed effects in `fixedeffects` are returned. If `fe_suffix` is not empty, the fixed effects are returned as a tuple with the suffix.
"""
function RegressionTables.other_stats(rr::FixedEffectModel, s::Symbol)
    if s == :fe

        out = []
        if !isdefined(rr, :formula)
            return Dict{Symbol, Vector{Pair}}()
        end
        fe_set = has_fe.(rr.formula.rhs)
        for (i, v) in enumerate(fe_set)
            if v && !isa(fe_set, Bool)
                push!(out, RegressionTables.FixedEffectCoefName(RegressionTables.get_coefname(rr.formula.rhs[i])))
            elseif v
                push!(out, RegressionTables.FixedEffectCoefName(RegressionTables.get_coefname(rr.formula.rhs)))
            end
        end
        if length(out) > 0
            out .=> RegressionTables.FixedEffectValue(true)
        else
            nothing
        end
    elseif s == :clusters && rr.nclusters !== nothing
        collect(RegressionTables.ClusterCoefName.(string.(keys(rr.nclusters))) .=> RegressionTables.ClusterValue.(values(rr.nclusters)))
    else
        nothing
    end
end

function RegressionTables.default_regression_statistics(rr::FixedEffectModel)
    if has_iv(rr)
        [Nobs, R2, R2Within, FStatIV]
    elseif has_fe(rr)
        [Nobs, R2, R2Within]
    else
        [Nobs, R2]
    end
end

end