module RegressionTablesGLFixedEffectModelsExt

# FixedEffectModels.jl is a dependency for GLFixedEffectModels.jl, so
# most things are already loaded
using GLFixedEffectModels, RegressionTables, Distributions

RegressionTables.default_regression_statistics(rr::GLFixedEffectModel) = [Nobs, R2McFadden]
function RegressionTables.RegressionType(x::GLFixedEffectModel)
    if islinear(x)
        RegressionType(Normal())
    else
        RegressionType(x.distribution)
    end
end

function RegressionTables.other_stats(rr::GLFixedEffectModel, s::Symbol)
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

# necessary because GLFixedEffectModels.jl does not have a formula function
RegressionTables._formula(x::GLFixedEffectModel) = x.formula_schema

end