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

function RegressionTables.other_stats(rr::GLFixedEffectModel)
    out = []
    if !isdefined(rr, :formula)
        return Dict{Symbol, Vector{Pair}}()
    end
    for t in rr.formula.rhs
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

# necessary because GLFixedEffectModels.jl does not have a formula function
function RegressionTables.SimpleRegressionResult(
    rr::GLFixedEffectModel,
    standardize_coef=false;
    labels::Dict{String, String} = Dict{String, String}(),
    regression_statistics::Vector = default_regression_statistics(rr),
    transform_labels = Dict(),
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
        RegressionTables.fe_terms(rr),
        labels=labels,
        transform_labels=transform_labels,
    )
end

end