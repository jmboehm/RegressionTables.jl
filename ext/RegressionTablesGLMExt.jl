module RegressionTablesGLMExt

using GLM, RegressionTables, StatsModels, Statistics

RegressionTables.default_regression_statistics(rr::LinearModel) = [Nobs, R2]
RegressionTables.default_regression_statistics(rr::StatsModels.TableRegressionModel{T}) where {T<:GLM.AbstractGLM} = [Nobs, R2McFadden]

RegressionTables.RegressionType(x::StatsModels.TableRegressionModel{T}) where {T<:GLM.AbstractGLM} = RegressionType(x.model)
RegressionTables.RegressionType(x::StatsModels.TableRegressionModel{T}) where {T<:LinearModel} = RegressionType(x.model)
RegressionTables.standardize_coef_values(x::StatsModels.TableRegressionModel, coefvalues, coefstderrors) =
    RegressionTables.standardize_coef_values(std(modelmatrix(x), dims=1)[1, :], std(response(x)), coefvalues, coefstderrors)

RegressionTables.RegressionType(x::LinearModel) = RegressionType(Normal())
RegressionTables.RegressionType(x::GLM.LmResp) = RegressionType(Normal())
RegressionTables.RegressionType(x::GeneralizedLinearModel) = RegressionType(x.rr)
RegressionTables.RegressionType(x::GLM.GlmResp{Y, D, L}) where {Y, D, L} = RegressionType(D)


end