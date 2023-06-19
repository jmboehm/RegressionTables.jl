module RegressionTablesGLFixedEffectModelsExt

# FixedEffectModels.jl is a dependency for GLFixedEffectModels.jl, so
# most things are already loaded
using GLFixedEffectModels, RegressionTables

function fe_terms(rr::GLRegressionModel)
    out = Symbol[]
    for t in eachterm(rr.formula.rhs)
        if has_fe(t)
            push!(out, fesymbol(t))
        end
    end
    out
end

function regtablesingle(
    rr::GLFixedEffectModels;
    fixedeffects = String[],
    args...
)
    fekeys = string.(fe_terms(rr))
    if length(fixedeffects) > 0
        fekeys = [x for x in fekeys if x in fixedeffects]
    end
    SimpleRegressionTable(
        rr;
        fixedeffects = length(fekeys) > 0 ? fekeys : nothing,
        args...
    )
end

end