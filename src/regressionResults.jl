
#=
These are the necessary functions to create a table from a regression result.
If the regression result does not provide a function by default, then
within an extension, it is possible to define the necessary function.
=#
_formula(x::RegressionModel) = formula(x)
function _responsename(x::RegressionModel)
    x = get_coefname(_formula(x).lhs)
    if isa(x, AbstractVector)
        x = first(x)
    end
    x
end
function _coefnames(x::RegressionModel)
    out = get_coefname(_formula(x).rhs)
    if !isa(out, AbstractVector)
        out = [out]
    end
    out
end
_coef(x::RegressionModel) = coef(x)
_stderror(x::RegressionModel) = stderror(x)
_dof_residual(x::RegressionModel) = dof_residual(x)

function _pvalue(x::RegressionModel)
    tt = _coef(x) ./ _stderror(x)
    ccdf.(Ref(FDist(1, _dof_residual(x))), abs2.(tt))
end

function can_standardize(x::T) where {T<:RegressionModel}
    @warn "standardize_coef is not possible for $T"
    false
end

function standardize_coef_values(std_X, std_Y, val)
    if std_X == 0 # constant has 0 std, so the interpretation is how many Y std away from 0 is the intercept
        val / std_Y
    else
        val * std_X / std_Y
    end
end

transformer(s::Nothing, repl_dict::AbstractDict) = s
function transformer(s, repl_dict::AbstractDict)
    for (old, new) in repl_dict
        s = replace(s, old => new)
    end
    return s
end

replace_name(s::Union{AbstractString, AbstractCoefName}, exact_dict, repl_dict) = get(exact_dict, s, transformer(s, repl_dict))
replace_name(s::Tuple{<:AbstractCoefName, <:AbstractString}, exact_dict, repl_dict) = (replace_name(s[1], exact_dict, repl_dict), s[2])
replace_name(s::Nothing, args...) = s

RegressionType(x::RegressionModel) = islinear(x) ? RegressionType(Normal()) : RegressionType("NL")

make_reg_stats(rr, stat::Type{<:AbstractRegressionStatistic}) = stat(rr)
make_reg_stats(rr, stat) = stat
make_reg_stats(rr, stat::Pair{<:Any, <:AbstractString}) = make_reg_stats(rr, first(stat)) => last(stat)

default_regression_statistics(x::AbstractRenderType, rr::RegressionModel) = default_regression_statistics(rr)
default_regression_statistics(rr::RegressionModel) = [Nobs, R2]


"""
    other_stats(rr::RegressionModel, s::Symbol)

Returns any other statistics to be displayed. This is used (if the appropriate extension is loaded)
to display the fixed effects in a FixedEffectModel (or GLFixedEffectModel),
clusters in those two, or Random Effects in a MixedModel. For other regressions, this
returns `nothing`.
"""
other_stats(x::RegressionModel, s::Symbol) = nothing
