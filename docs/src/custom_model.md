
# Using RegressionTables with a Custom Model

RegressionTables.jl is designed to be used with any custom model you create. The easiest way for this to work is to copy the [StatsAPI.jl](https://github.com/JuliaStats/StatsAPI.jl) API, if that API is fully implemented then RegressionTables.jl will work out of the box. This page will provide a simple example of this.

## The Model

This will setup a simple linear model:

```@example custom_model
using StatsAPI, RDatasets, RegressionTables, Statistics
df = RDatasets.dataset("plm", "Cigar")
df[!, :intercept] = ones(nrow(df))

struct MyStatsModel <: StatsAPI.RegressionModel
    coef::Vector{Float64}
    vcov::Matrix{Float64}
    dof::Int
    dof_residual::Int
    nobs::Int
    rss::Float64
    tss::Float64
    coefnames::Vector{String}
    responsename::String
end

function MyStatsModel(df::DataFrame, lhs::Symbol, rhs::Vector{Symbol})
# an alternative using StatsAPI.fit would be:
#function StatsAPI.fit(::Type{MyStatsModel}, lhs::Symbol, rhs::Vector{Symbol}, df::DataFrame)
    df = dropmissing(df, vcat([lhs], rhs))

    X = Matrix(select(df, rhs))
    y = df[:, lhs]

    n, p = size(X)
    β = X \ y
    ŷ = X * β
    res = y - ŷ
    rss = sum(abs2, res)
    tss = sum(abs2, y .- mean(y))
    dof = p
    dof_residual = n - p
    vcov = inv(X'X) * rss / dof_residual
    MyStatsModel(β, vcov, dof, dof_residual, n, rss, tss, string.(rhs), string(lhs))
end
```

It is important to link the relevant components from StatsAPI to the model components. This allows RegressionTables to correctly interpret the model. The following is a basic set that allows this package to work, a complete list is available [here](https://github.com/JuliaStats/StatsAPI.jl/blob/main/src/statisticalmodel.jl):

```@example custom_model
StatsAPI.coef(m::MyStatsModel) = m.coef
StatsAPI.coefnames(m::MyStatsModel) = m.coefnames
StatsAPI.responsename(m::MyStatsModel) = m.responsename
StatsAPI.vcov(m::MyStatsModel) = m.vcov
StatsAPI.dof(m::MyStatsModel) = m.dof
StatsAPI.dof_residual(m::MyStatsModel) = m.dof_residual
StatsAPI.nobs(m::MyStatsModel) = m.nobs
StatsAPI.rss(m::MyStatsModel) = m.rss
StatsAPI.nulldeviance(m::MyStatsModel) = m.tss
StatsAPI.islinear(m::MyStatsModel) = true # this will make the label default to "OLS", set RegressionTables.RegressionType(rr::MyStatsModel) = "My Model"
StatsAPI.deviance(m::MyStatsModel) = StatsAPI.rss(m)
StatsAPI.mss(m::MyStatsModel) = StatsAPI.nulldeviance(m) - StatsAPI.rss(m)
StatsAPI.r2(m::MyStatsModel) = StatsAPI.r2(m, :devianceratio);
```

This will now work with RegressionTables:

```@example custom_model
rr1 = MyStatsModel(df, :Sales, [:intercept, :Price, :NDI])
rr2 = MyStatsModel(df, :Sales, [:intercept, :Price])
rr3 = MyStatsModel(df, :Sales, [:intercept, :NDI])
regtable(rr1, rr2, rr3)
```

## Adding a Custom Statistic

One reason to implement a custom regression model is the need for some kind of custom statistic. It is easy to implement these statistics in RegressionTables.

For example, say a custom statistic that is relevant is the sum of all coefficients in a model. First, create a statistic:
```@example custom_model
struct MyStatistic <: RegressionTables.AbstractRegressionStatistic
    val::Union{Float64, Nothing}
end
```

A few extra functions are necessary to make this work. First, if the statistic is called on a different model, it should return a blank line, second, when called on `MyStatsModel`, it should return the correct value:

```@example custom_model
MyStatistic(rr::StatsAPI.RegressionModel) = MyStatistic(nothing)
MyStatistic(rr::MyStatsModel) = MyStatistic(sum(StatsAPI.coef(rr)));
```

It is also useful to provide some label to the statistic:
```@example custom_model
RegressionTables.label(render::AbstractRenderType, x::Type{MyStatistic}) = "My Statistic";
```

Now, when creating the table, add that to the list of regression statistics:
```@example custom_model
regtable(rr1, rr2, rr3; regression_statistics=[Nobs, R2, MyStatistic])
```

It can be inconvenient to constantly define `regression_statistics`, especially if you find yourself switching between models. RegressionTables provides the flexibility to link statistics to a model so that those statistics are always shown when that model is within a table, but not shown otherwise. To do so, set:
```@example custom_model
RegressionTables.default_regression_statistics(rr::MyStatsModel) = [Nobs, MyStatistic]
regtable(rr1, rr2, rr3)
```