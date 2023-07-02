module RegressionTablesGLFixedEffectModelsExt

# FixedEffectModels.jl is a dependency for GLFixedEffectModels.jl, so
# most things are already loaded
using GLFixedEffectModels, RegressionTables

RegressionTables.default_regression_statistics(rr::GLFixedEffectModel) = [Nobs, R2McFadden]
function RegressionTables.regressiontype(x::GLFixedEffectModel)
    if islinear(x)
        "OLS"
    elseif isa(x.distribution, Binomial)
        "Binomial"
    elseif isa(x.distribution, Poisson)
        "Poisson"
    else
        string(x.distribution)
    end
    islinear(x) ? "OLS" : string(x.distribution)
end

# necessary because GLFixedEffectModels.jl does not have a formula function
function RegressionTables.SimpleRegressionResult(
    rr::GLFixedEffectModel;
    keep::Vector{String} = String[],
    drop::Vector{String} = String[],
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
        regressiontype(rr),
        fe_terms(rr; fixedeffects, fe_suffix),
        labels=labels,
        transform_labels=transform_labels,
        keep=keep,
        drop=drop,
    )
end

end