module RegressionTablesFixedEffectModelsExt

using FixedEffectModels, RegressionTables


RegressionTables.FStat(x::FixedEffectModel) = FStat(x.F)
RegressionTables.FStatPValue(x::FixedEffectModel) = FStatPvalue(x.p)

RegressionTables.FStatIV(x::FixedEffectModel) = FStatIV(x.F_kp) # is a value or missing already
RegressionTables.FStatIVPValue(x::FixedEffectModel) = FStatIVPvalue(x.p_kp) # is a value or missing already

RegressionTables.R2Within(x::FixedEffectModel) = R2Within(x.r2_within) # is a value or missing already

RegressionTables.regressiontype(x::FixedEffectModel) = has_iv(x) ? :IV : :OLS

RegressionTables.get_coefname(x::StatsModels.FunctionTerm{typeof(FixedEffectModels.fe)}) = string(x.exorig.args[end])

function RegressionTables.fe_terms(rr::RegressionModel; fixedeffects=String[], fe_suffix="Fixed-Effects", args...)
    out = []
    if !isdefined(rr, :formula)
        return nothing
    end
    for t in rr.formula.rhs
        if has_fe(t)
            push!(out, RegressionTables.get_coefname(t))
        end
    end
    if length(fixedeffects) > 0
        out = [x for x in out if string(x) in fixedeffects]
    end
    if length(fe_suffix) > 0
        out = [(x, fe_suffix) for x in out]
    end
    if length(out) > 0
        out
    else
        nothing
    end
end

end