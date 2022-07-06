# functions that classify regression results
isFERegressionResult(r::FixedEffectModel) = has_fe(r)
isIVRegressionResult(r::FixedEffectModel) = has_iv(r)
isOLSRegressionResult(r::FixedEffectModel) = !has_iv(r)

# FE and IV regression not supported in GLM.jl
isFERegressionResult(r::TableRegressionModel) = false
isIVRegressionResult(r::TableRegressionModel) = false
isOLSRegressionResult(r::TableRegressionModel) = isa(r.model, LinearModel)

# this is in particular for GLFixedEffectModels
function isFERegressionResult(rr::RegressionModel) 
    # note that until StatsBase supports has_fe, this always returns false...
    try 
        return has_fe(rr)
    catch 
        return false
    end
end
function isIVRegressionResult(rr::RegressionModel) 
    try 
        return has_iv(rr)
    catch 
        return false
    end
end
isOLSRegressionResult(rr::RegressionModel) = islinear(rr)

# get display labels for terms
function name(t::InteractionTerm)
    n = isa(t.terms[1], Term) ? "$(t.terms[1])" : name(t.terms[1])
    for term in t.terms[2:end]
        s = isa(term, Term) ? "$(term)" : name(term)
        n = "$(n) * $(s)"
    end
    n
end
function name(t::FunctionTerm)
    string(t.args_parsed[1].sym)
end
function name(t::FixedEffectTerm)
    string(t.x)
end
