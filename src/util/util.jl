# functions that classify regression results
isFERegressionResult(r::FixedEffectModel) = has_fe(r)
isIVRegressionResult(r::FixedEffectModel) = has_iv(r)
isOLSRegressionResult(r::FixedEffectModel) = !has_iv(r)

# FE and IV regression not supported in GLM.jl
isFERegressionResult(r::TableRegressionModel) = false
isIVRegressionResult(r::TableRegressionModel) = false
isOLSRegressionResult(r::TableRegressionModel) = isa(r.model, LinearModel)


# get display labels for terms
function name(t::InteractionTerm)
    n = name(t.terms[1])
    for term in t.terms[2:end]
        n = "$(n) * $(name(term))"
    end
    n
end
function name(t::FunctionTerm)
    string(t.args_parsed[1].sym)
end
