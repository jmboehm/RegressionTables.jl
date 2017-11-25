# functions that classify regression results
isFERegressionResult(r::AbstractRegressionResult) = isa(r,RegressionResultFE) || isa(r,RegressionResultFEIV)
isIVRegressionResult(r::AbstractRegressionResult) = isa(r,RegressionResultIV) || isa(r,RegressionResultFEIV)
