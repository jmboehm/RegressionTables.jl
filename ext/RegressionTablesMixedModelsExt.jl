module RegressionTablesMixedModelsExt


using MixedModels, RegressionTables, StatsModels, Statistics, Distributions

RegressionTables.default_regression_statistics(rr::MixedModel) = [Nobs, LogLikelihood]

function RegressionTables.RegressionType(x::MixedModel)
    if islinear(x)
        RegressionType(Normal())
    else
        RegressionType(x.resp) # uses the GLM extension
    end
end

function RegressionTables.SimpleRegressionResult(rr::MixedModel, lhs::StatsModels.AbstractTerm, rhs::Tuple, args...; vargs...)
    RegressionTables.SimpleRegressionResult(rr, lhs, rhs[1], args...; vargs...)
end

RegressionTables.standardize_coef_values(x::MixedModel, coefvalues, coefstderrors) =
    RegressionTables.standardize_coef_values(std(modelmatrix(x), dims=1)[1, :], std(response(x)), coefvalues, coefstderrors)

#=
Technically not a fixed effect term, but this allows it to fit into
the current setup
=#
function RegressionTables.other_stats(x::MixedModel; args...)
    f = formula(x)
    if length(f.rhs) == 1
        return Dict{Symbol, Vector{Pair}}()
    end
    out = RegressionTables.RandomEffectCoefName[]
    vals = x.σs
    out_vals = Float64[]
    for re in f.rhs[2:end]
        rhs_sym = re.rhs |> Symbol
        rhs_name = RegressionTables.CoefName(String(rhs_sym))
        lhs_sym = Symbol.(coefnames(re.lhs))
        lhs_names = RegressionTables.get_coefname(re.lhs)
        if isa(lhs_sym, AbstractVector)
            for (ls, ln) in zip(lhs_sym, lhs_names)
                val = vals[rhs_sym][ls]
                push!(out, RegressionTables.RandomEffectCoefName(rhs_name, ln))
                push!(out_vals, val)
            end
        else# just one term
            push!(out, RegressionTables.RandomEffectCoefName(rhs_name, lhs_names))
            push!(out_vals, vals[rhs_sym][lhs_sym])
        end
    end
    Dict(:randomeffects => (out .=> RegressionTables.RandomEffectValue.(out_vals)))
end
end