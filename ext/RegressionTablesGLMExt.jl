module RegressionTablesGLMExt

using GLM, RegressionTables, StatsModels, Statistics

RegressionTables.default_regression_statistics(rr::LinearModel) = [Nobs, R2]
RegressionTables.default_regression_statistics(rr::StatsModels.TableRegressionModel{T}) where {T<:GLM.AbstractGLM} = [Nobs, R2McFadden]

RegressionTables.RegressionType(x::StatsModels.TableRegressionModel{T}) where {T<:GLM.AbstractGLM} = RegressionType(x.model)
RegressionTables.RegressionType(x::StatsModels.TableRegressionModel{T}) where {T<:LinearModel} = RegressionType(x.model)

# k is which coefficient or standard error to standardize
RegressionTables.standardize_coef_values(x::StatsModels.TableRegressionModel, val, k) =
    RegressionTables.standardize_coef_values(std(modelmatrix(x)[:, k]), std(response(x)), val)

RegressionTables.can_standardize(x::StatsModels.TableRegressionModel) = true

RegressionTables.RegressionType(x::LinearModel) = RegressionType(Normal())
RegressionTables.RegressionType(x::GLM.LmResp) = RegressionType(Normal())
RegressionTables.RegressionType(x::GeneralizedLinearModel) = RegressionType(x.rr)
RegressionTables.RegressionType(x::GLM.GlmResp{Y, D, L}) where {Y, D, L} = RegressionType(D)


end