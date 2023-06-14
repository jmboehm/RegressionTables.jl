
struct RegressionTableSingle
    responsename::String
    coefnames::Vector{String}
    coefvalues::Vector{Float64}
    coefstderrors::Vector{Float64}
    coefpvalues::Vector{Float64}
    fixedeffects::Union{Nothing, Vector{String}}
    regressiontype::Symbol
    statistics::Vector
end

StatsAPI.responsename(x::RegressionTableSingle) = x.responsename
StatsAPI.coefnames(x::RegressionTableSingle) = x.coefnames
StatsAPI.coef(x::RegressionTableSingle) = x.coefvalues
StatsAPI.stderror(x::RegressionTableSingle) = x.coefstderrors

function regressiontype(x::RegressionModel)
    islinear(x) ? :OLS : :NL
end

function regtablesingle(
    rr::RegressionModel;
    args...
)
    RegressionTableSingle(rr; args...)
end

make_reg_stats(rr, stat::Type{<:AbstractRegressionStatistic}) = stat(rr)
make_reg_stats(rr, stat) = stat
make_reg_stats(rr, stat::Pair{<:Any, <:AbstractString}) = make_reg_stats(rr, first(stat)) => last(stat)



function RegressionTableSingle(
    rr::RegressionModel;
    regressors::Vector{String} = String[],
    labels::Dict{String, String} = Dict{String, String}(),
    regression_statistics::Vector = [Nobs, R2],
    fixedeffects=nothing,
    args...
)
    out_names = coefnames(rr)
    out_coefvalues = coef(rr)
    out_coefstderrors = stderror(rr)
    tt = out_coefvalues ./ out_coefstderrors
    out_pvalue = ccdf.(Ref(FDist(1, dof_residual(rr))), abs2.(tt))
    
    if length(regressors) > 0
        keep = Int[]
        for i in 1:length(out_names)
            if out_names in regressors
                push!(keep, i)
            end
        end
        out_names = out_names[keep]
        out_coefvalues = out_coefvalues[keep]
        out_coefstderrors = out_coefstderrors[keep]
        out_pvalue = out_pvalue[keep]
    end
    RegressionTableSingle(
        get(labels, string(responsename(rr)), string(responsename(rr))),
        get.(Ref(labels), out_names, out_names),
        out_coefvalues,
        out_coefstderrors,
        out_pvalue,
        get.(Ref(labels), fixedeffects, fixedeffects),
        regressiontype(rr),
        make_reg_stats.(Ref(rr), regression_statistics)
    )
end

function combine_fe(tables)
    fe = String[]
    for table in tables
        if !isnothing(table.fixedeffects)
            fe = union(fe, table.fixedeffects)
        end
    end
    if length(fe) == 0
        return nothing
    end
    mat = zeros(Bool, length(fe), length(tables))
    for (i, table) in enumerate(tables)
        if table.fixedeffects !== nothing
            for (j, f) in enumerate(fe)
                mat[j, i] = f in table.fixedeffects
            end
        end
    end
    hcat(fe, mat)
end

function combine_statistics(tables)
    types_strings = []
    for t in tables
        for s in t.statistics
            if isa(s, AbstractRegressionStatistic)
                push!(types_strings, typeof(s))
            elseif isa(s, Pair)
                push!(types_strings, last(s))
            end
        end
    end
    types_strings = unique(types_strings)
    mat = Matrix{Any}(missing, length(types_strings), length(tables))
    for (i, t) in enumerate(tables)
        for (j, s) in enumerate(t.statistics)
            if isa(s, AbstractRegressionStatistic)
                mat[j, i] = s
            elseif isa(s, Pair)
                mat[j, i] = first(s)
            end
        end
    end
    hcat(types_strings, mat)
end

function (::Type{T})(
    tables::RegressionTableSingle...;
    below_statistic = STDError,
    stat_below=true,
    number_regressions::Bool = true,
    number_regressions_decoration::Function = i::Int64 -> "($i)",
    groups=[]
) where T <: AbstractRenderType

    hdr = reshape(vcat([""], collect(responsename.(tables))), 1, :)
    if length(groups) > 0
        hdr = vcat(groups, hdr)
    end
    if number_regressions
        hdr = vcat(
            hdr,
            reshape(vcat([""], number_regressions_decoration.(1:length(tables))), 1, :)
        )
    end
    nms = union(coefnames.(tables)...)
    coefvalues = Matrix{Any}(missing, length(nms), length(tables))
    coefbelow = Matrix{Any}(missing, length(nms), length(tables))
    for (i, table) in enumerate(tables)
        for (j, nm) in enumerate(nms)
            if nm in coefnames(table)
                k = findfirst(coefnames(table) .== nm)
                coefvalues[j, i] = CoefValue(coef(table)[k], table.coefpvalues[k])
                coefbelow[j, i] = below_statistic(stderror(table)[k], coef(table)[k])
            end
        end
    end
    if stat_below
        temp1 = hcat(nms, coefvalues)
        temp2 = hcat(fill(missing, length(nms)), coefbelow)
        full_coefs = vcat((zip([temp1[x:x, :] for x in 1:size(temp1, 1)], [temp2[x:x, :] for x in 1:size(temp2, 1)])...)...)
    else
        full_coefs = hcat(nms, [(x, y) for (x, y) in zip(coefvalues, coefbelow)])
    end
    all_fe = combine_fe(tables)
    regressiontype = vcat([RegressionType], [RegressionType(t.regressiontype) for t in tables])
    stats = combine_statistics(tables)
    breaks = [size(full_coefs, 1)]
    if all_fe !== nothing
        full_coefs = vcat(full_coefs, all_fe)
        push!(breaks, size(full_coefs, 1))
    end
    full_coefs = vcat(full_coefs, reshape(regressiontype, 1, :))
    push!(breaks, size(full_coefs, 1))
    full_coefs = vcat(full_coefs, stats)
    push!(breaks, size(full_coefs, 1))
    T(
        hdr,
        full_coefs,
        breaks
    )
end