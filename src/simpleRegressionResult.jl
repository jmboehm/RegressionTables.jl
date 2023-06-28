
struct SimpleRegressionResult
    responsename::Union{String, <:AbstractCoefName}
    coefnames::Vector# either string or AbstractCoefName
    coefvalues::Vector{Float64}
    coefstderrors::Vector{Float64}
    coefpvalues::Vector{Float64}
    statistics::Vector
    regressiontype::Symbol
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
    reg_type::Symbol=regressiontype(rr),
    fixedeffects::Union{Nothing, Vector}=nothing;
    labels=Dict{String, String}(),
    transform_labels=Dict{String, String}(),
    keep=String[],
    drop=String[],
)
    if length(keep) > 0 || length(drop) > 0
        to_keep = Int[]
        for i in 1:length(rhs)
            if string(rhs[i]) in keep
                push!(to_keep, i)
            elseif string(rhs[i]) !in drop
                push!(to_keep, i)
            end
        end
        rhs = rhs[keep]
        coefvalues = coefvalues[keep]
        coefstderrors = coefstderrors[keep]
        coefpvalues = coefpvalues[keep]
    end
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
replace_name(s::Nothing, args...) = s

function regressiontype(x::RegressionModel)
    islinear(x) ? :OLS : :NL
end

make_reg_stats(rr, stat::Type{<:AbstractRegressionStatistic}) = stat(rr)
make_reg_stats(rr, stat) = stat
make_reg_stats(rr, stat::Pair{<:Any, <:AbstractString}) = make_reg_stats(rr, first(stat)) => last(stat)

fe_terms(rr::RegressionModel) = nothing

function SimpleRegressionResult(
    rr::RegressionModel;
    keep::Vector{String} = String[],
    drop::Vector{String} = String[],
    labels::Dict{String, String} = Dict{String, String}(),
    regression_statistics::Vector = [Nobs, R2],
    transform_labels = Dict(),
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
        fe_terms(rr);
        labels=labels,
        transform_labels=transform_labels,
        keep=keep,
        drop=drop,
    )
end



function regtablesingle(
    rr::RegressionModel;
    args...
)
    SimpleRegressionResult(rr; args...)
end
