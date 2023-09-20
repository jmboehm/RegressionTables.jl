module RegressionTablesFixedEffectModelsExt

using FixedEffectModels, RegressionTables, Distributions


RegressionTables.FStat(x::FixedEffectModel) = FStat(x.F)
RegressionTables.FStatPValue(x::FixedEffectModel) = FStatPValue(x.p)

RegressionTables.FStatIV(x::FixedEffectModel) = FStatIV(x.F_kp) # is a value or missing already
RegressionTables.FStatIVPValue(x::FixedEffectModel) = FStatIVPValue(x.p_kp) # is a value or missing already

RegressionTables.R2Within(x::FixedEffectModel) = R2Within(x.r2_within) # is a value or missing already

RegressionTables.RegressionType(x::FixedEffectModel) = RegressionType(Normal(), has_iv(x))

RegressionTables.get_coefname(x::StatsModels.FunctionTerm{typeof(FixedEffectModels.fe)}) = RegressionTables.CoefName(string(x.exorig.args[end]))
RegressionTables.get_coefname(x::FixedEffectModels.FixedEffectTerm) = RegressionTables.CoefName(string(x.x))

"""
    RegressionTables.other_stats(rr::FixedEffectModel; fixedeffects=String[], fe_suffix="Fixed Effects")

Return a vector of fixed effects terms. If `fixedeffects` is not empty, only the fixed effects in `fixedeffects` are returned. If `fe_suffix` is not empty, the fixed effects are returned as a tuple with the suffix.
"""
function RegressionTables.other_stats(rr::FixedEffectModel)
    out = []
    if !isdefined(rr, :formula)
        return Dict{Symbol, Vector{Pair}}()
    end
    rhs_itr = if isa(rr.formula.rhs, StatsModels.Term)
        [rr.formula.rhs]
    else
        rr.formula.rhs
    end
    for t in rhs_itr
        if has_fe(t)
            push!(out, RegressionTables.FixedEffectCoefName(RegressionTables.get_coefname(t)))
        end
    end
    if length(out) > 0 && rr.nclusters === nothing
        out_dict = Dict(:fe => (out .=> RegressionTables.FixedEffectValue(true)))
    elseif length(out) > 0 && rr.nclusters !== nothing
        out_dict = Dict(
            :fe => (out .=> RegressionTables.FixedEffectValue(true)),
            :clusters => collect(RegressionTables.ClusterCoefName.(string.(keys(rr.nclusters))) .=> RegressionTables.ClusterValue.(values(rr.nclusters)))
        )
    elseif length(out) == 0 && rr.nclusters !== nothing
        out_dict = Dict(:clusters => collect(RegressionTables.ClusterCoefName.(string.(keys(rr.nclusters))) .=> RegressionTables.ClusterValue.(values(rr.nclusters))))
    else
        out_dict = Dict{Symbol, Vector{Pair}}()
    end
    out_dict
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