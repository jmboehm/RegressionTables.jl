# functions that classify regression results
isFERegressionResult(r::AbstractRegressionResult) = isa(r,RegressionResultFE) || isa(r,RegressionResultFEIV)
isIVRegressionResult(r::AbstractRegressionResult) = isa(r,RegressionResultIV) || isa(r,RegressionResultFEIV)
isOLSRegressionResult(r::AbstractRegressionResult) = !isIVRegressionResult(r)

# FE and IV regression not supported in GLM.jl
isFERegressionResult(r::TableRegressionModel) = false
isIVRegressionResult(r::TableRegressionModel) = false
isOLSRegressionResult(r::TableRegressionModel) = isa(r.model, LinearModel)
