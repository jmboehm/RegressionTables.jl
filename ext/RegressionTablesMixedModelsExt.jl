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

function RegressionTables._coefnames(x::MixedModel)
    r = formula(x).rhs
    out = if isa(r, Tuple)
        RegressionTables.get_coefname(r[1])
    else
        RegressionTables.get_coefname(r)
    end
    if !isa(out, AbstractVector)
        out = [out]
    end
    out
end

RegressionTables.standardize_coef_values(x::MixedModel, coefvalues, coefstderrors) =
    RegressionTables.standardize_coef_values(std(modelmatrix(x), dims=1)[1, :], std(response(x)), coefvalues, coefstderrors)

function RegressionTables.other_stats(x::MixedModel, s::Symbol)
    if s == :randomeffects
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
        out .=> RegressionTables.RandomEffectValue.(out_vals)
    else
        nothing
    end
end
end