
struct SimpleRegressionResult
    responsename::Union{String, <:AbstractCoefName}
    coefnames::Vector# either string or AbstractCoefName
    coefvalues::Vector{Float64}
    coefstderrors::Vector{Float64}
    coefpvalues::Vector{Float64}
    statistics::Vector
    regressiontype::String
    fixedeffects::Union{Nothing, Vector}
end

StatsAPI.responsename(x::SimpleRegressionResult) = x.responsename
StatsAPI.coefnames(x::SimpleRegressionResult) = x.coefnames
StatsAPI.coef(x::SimpleRegressionResult) = x.coefvalues
StatsAPI.stderror(x::SimpleRegressionResult) = x.coefstderrors

SimpleRegressionResult(rr::RegressionModel, f::FormulaTerm, args...; vargs...) =
    SimpleRegressionResult(rr::RegressionModel, f.lhs, f.rhs, args...; vargs...)

SimpleRegressionResult(rr::RegressionModel, lhs::AbstractTerm, rhs::AbstractTerm, args...; vargs...) =
    SimpleRegressionResult(rr::RegressionModel, get_coefname(lhs), get_coefname(rhs), args...; vargs...)

function SimpleRegressionResult(
    rr::RegressionModel,
    lhs::Union{AbstractString, AbstractCoefName},
    rhs::Vector,
    coefvalues::Vector{Float64},
    coefstderrors::Vector{Float64},
    coefpvalues::Vector{Float64},
    regression_statistics::Vector,
    reg_type::String=regressiontype(rr),
    fixedeffects::Union{Nothing, Vector}=nothing;
    labels=Dict{String, String}(),
    transform_labels=Dict{String, String}(),
    keep=String[],
    drop=String[],
)
    # if length(keep) > 0 
    #     to_keep = Int[]
    #     for k in keep
    #         if k in string.(rhs)
    #             push!(to_keep, findfirst(k .== string.(rhs)))
    #         end
    #     end
    #     println(to_keep)
    #     rhs = rhs[to_keep]
    #     coefvalues = coefvalues[to_keep]
    #     coefstderrors = coefstderrors[to_keep]
    #     coefpvalues = coefpvalues[to_keep]
    # elseif length(drop) > 0
    #     to_keep = Int[]
    #     for i in 1:length(rhs)
    #         if !(string(rhs[i]) in drop)
    #             push!(to_keep, i)
    #         end
    #     end
    #     rhs = rhs[to_keep]
    #     coefvalues = coefvalues[to_keep]
    #     coefstderrors = coefstderrors[to_keep]
    #     coefpvalues = coefpvalues[to_keep]
    # end
    SimpleRegressionResult(
        replace_name(lhs, labels, transform_labels),
        replace_name.(rhs, Ref(labels), Ref(transform_labels)),
        coefvalues,
        coefstderrors,
        coefpvalues,
        make_reg_stats.(Ref(rr), regression_statistics),
        reg_type,
        replace_name.(fixedeffects, Ref(labels), Ref(transform_labels)),
    )
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

function regressiontype(x::RegressionModel)
    islinear(x) ? "OLS" : "NL"
end

make_reg_stats(rr, stat::Type{<:AbstractRegressionStatistic}) = stat(rr)
make_reg_stats(rr, stat) = stat
make_reg_stats(rr, stat::Pair{<:Any, <:AbstractString}) = make_reg_stats(rr, first(stat)) => last(stat)

default_regression_statistics(rr::RegressionModel) = [Nobs, R2]
fe_terms(rr::RegressionModel; args...) = nothing

function SimpleRegressionResult(
    rr::RegressionModel;
    keep::Vector{String} = String[],
    drop::Vector{String} = String[],
    labels::Dict{String, String} = Dict{String, String}(),
    regression_statistics::Vector = default_regression_statistics(rr),
    transform_labels = Dict(),
    fixedeffects=String[],
    fe_suffix="Fixed Effects",
    args...
)
    coefvalues = coef(rr)
    coefstderrors = stderror(rr)
    tt = coefvalues ./ coefstderrors
    coefpvalues = ccdf.(Ref(FDist(1, dof_residual(rr))), abs2.(tt))
    SimpleRegressionResult(
        rr,
        formula(rr),
        coefvalues,
        coefstderrors,
        coefpvalues,
        regression_statistics,
        regressiontype(rr),
        fe_terms(rr; fixedeffects, fe_suffix),
        labels=labels,
        transform_labels=transform_labels,
        keep=keep,
        drop=drop,
    )
end