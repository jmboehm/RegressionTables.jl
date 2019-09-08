# functions that classify regression results
isFERegressionResult(r::FixedEffectModel) = has_fe(r)
isIVRegressionResult(r::FixedEffectModel) = has_iv(r)
isOLSRegressionResult(r::FixedEffectModel) = !has_iv(r)

# FE and IV regression not supported in GLM.jl
isFERegressionResult(r::TableRegressionModel) = false
isIVRegressionResult(r::TableRegressionModel) = false
isOLSRegressionResult(r::TableRegressionModel) = isa(r.model, LinearModel)
