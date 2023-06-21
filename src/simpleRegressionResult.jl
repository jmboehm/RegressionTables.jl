
struct SimpleRegressionResult
    responsename::Union{String, <:AbstractCoefName}
    coefnames::Vector# either string or AbstractCoefName
    coefvalues::Vector{Float64}
    coefstderrors::Vector{Float64}
    coefpvalues::Vector{Float64}
    fixedeffects::Union{Nothing, Vector}
    regressiontype::Symbol
    statistics::Vector
end

StatsAPI.responsename(x::SimpleRegressionResult) = x.responsename
StatsAPI.coefnames(x::SimpleRegressionResult) = x.coefnames
StatsAPI.coef(x::SimpleRegressionResult) = x.coefvalues
StatsAPI.stderror(x::SimpleRegressionResult) = x.coefstderrors

function regressiontype(x::RegressionModel)
    islinear(x) ? :OLS : :NL
end


make_reg_stats(rr, stat::Type{<:AbstractRegressionStatistic}) = stat(rr)
make_reg_stats(rr, stat) = stat
make_reg_stats(rr, stat::Pair{<:Any, <:AbstractString}) = make_reg_stats(rr, first(stat)) => last(stat)

get_coefname(x::MatrixTerm) = mapreduce(get_coefname, vcat, x.terms)


function SimpleRegressionResult(
    rr::RegressionModel;
    regressors::Vector{String} = String[],
    labels::Dict{String, String} = Dict{String, String}(),
    regression_statistics::Vector = [Nobs, R2],
    fixedeffects=nothing,
    transform_labels = identity,
    args...
)
    out_names = get_coefname(formula(rr).rhs)
    #out_names = coefnames(rr)
    out_coefvalues = coef(rr)
    out_coefstderrors = stderror(rr)
    tt = out_coefvalues ./ out_coefstderrors
    out_pvalue = ccdf.(Ref(FDist(1, dof_residual(rr))), abs2.(tt))
    
    if length(regressors) > 0
        keep = Int[]
        for i in 1:length(out_names)
            if string(out_names[i]) in regressors
                push!(keep, i)
            end
        end
        out_names = out_names[keep]
        out_coefvalues = out_coefvalues[keep]
        out_coefstderrors = out_coefstderrors[keep]
        out_pvalue = out_pvalue[keep]
    end
    SimpleRegressionResult(
        get(labels, get_coefname(formula(rr).lhs), transform_labels(get_coefname(formula(rr).lhs))),
        get.(Ref(labels), out_names, transform_labels.(out_names)),
        out_coefvalues,
        out_coefstderrors,
        out_pvalue,
        get.(Ref(labels), fixedeffects, fixedeffects),
        regressiontype(rr),
        make_reg_stats.(Ref(rr), regression_statistics)
    )
end



function regtablesingle(
    rr::RegressionModel;
    args...
)
    SimpleRegressionResult(rr; args...)
end
