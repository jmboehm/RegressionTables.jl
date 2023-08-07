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

function RegressionTables.SimpleRegressionResult(rr::MixedModel, lhs::StatsModels.AbstractTerm, rhs::Tuple{<:StatsModels.AbstractTerm, RandomEffectsTerm}, args...; vargs...)
    RegressionTables.SimpleRegressionResult(rr, lhs, rhs[1], args...; vargs...)
end

RegressionTables.standardize_coef_values(x::MixedModel, coefvalues, coefstderrors) =
    RegressionTables.standardize_coef_values(std(modelmatrix(x), dims=1)[1, :], std(response(x)), coefvalues, coefstderrors)

end