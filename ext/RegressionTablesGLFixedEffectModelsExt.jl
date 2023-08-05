module RegressionTablesGLFixedEffectModelsExt

# FixedEffectModels.jl is a dependency for GLFixedEffectModels.jl, so
# most things are already loaded
using GLFixedEffectModels, RegressionTables

RegressionTables.default_regression_statistics(rr::GLFixedEffectModel) = [Nobs, R2McFadden]
function RegressionTables.RegressionType(x::GLFixedEffectModel)
    if islinear(x)
        RegressionType(Normal())
    else
        RegressionType(x.distribution())
    end
end

function RegressionTables.fe_terms(rr::GLFixedEffectModel; fixedeffects=String[], fe_suffix="Fixed Effects")
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

# necessary because GLFixedEffectModels.jl does not have a formula function
function RegressionTables.SimpleRegressionResult(
    rr::GLFixedEffectModel;
    labels::Dict{String, String} = Dict{String, String}(),
    regression_statistics::Vector = default_regression_statistics(rr),
    transform_labels = Dict(),
    fixedeffects=String[],
    fe_suffix="Fixed-Effects",
    args...
)
    coefvalues = coef(rr)
    coefstderrors = stderror(rr)
    tt = coefvalues ./ coefstderrors
    coefpvalues = ccdf.(Ref(FDist(1, dof_residual(rr))), abs2.(tt))
    RegressionTables.SimpleRegressionResult(
        rr,
        rr.formula_schema,
        coefvalues,
        coefstderrors,
        coefpvalues,
        regression_statistics,
        RegressionType(rr),
        fe_terms(rr; fixedeffects, fe_suffix),
        labels=labels,
        transform_labels=transform_labels,
    )
end

end