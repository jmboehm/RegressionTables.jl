get_coefname(x::MatrixTerm) = mapreduce(get_coefname, vcat, x.terms)

"""
    abstract type AbstractCoefName end

These names largely mirror their equivalents in [StatsModels.jl](https://github.com/JuliaStats/StatsModels.jl).
The main difference here is that the names are always based on strings (instead of symbols). There are also
several default functions that are resused (e.g., `get` and `replace`) to make relabeling coefficients easier.

AbstractCoefName simply acts as a parent type to the other types. The other types are:
- [`CoefName`](@ref): for `Term`, `ContinuousTerm` and `FunctionTerm`
- [`InteractedCoefName`](@ref): for `InteractionTerm`
- [`CategoricalCoefName`](@ref): for `CategoricalTerm`
- [`InterceptCoefName`](@ref): for `ConstantTerm`

Using the function [`get_coefname`](@ref) will return the appropriate type for the term.
"""
abstract type AbstractCoefName end
(::Type{T})(x::T) where {T<:AbstractCoefName} = x
Base.broadcastable(x::AbstractCoefName) = Ref(x)

"""
    get_coefname(x::AbstractTerm)::CoefName
    get_coefname(x::Term)::CoefName
    get_coefname(x::InteractionTerm)::InteractedCoefName
    get_coefname(x::InterceptTerm{H})::InterceptCoefName
    get_coefname(x::CategoricalTerm)::CategoricalCoefName
"""
function get_coefname end

# for functionterm and continuousterm
#=
It might be nice to add a separate functionterm piece so that the internals could easily
change just like InteractedCoefName, but the internals are not parsed in the same way
which makes that extremely difficult to do
=#
"""
    struct CoefName <: AbstractCoefName
        name::String
    end

Used to store the name of a coefficient. This is used for `Term`, `ContinuousTerm` and `FunctionTerm`.
"""
struct CoefName <: AbstractCoefName
    name::String
    CoefName(name::AbstractString) = new(String(name))
end

value(x::CoefName) = x.name
Base.string(x::CoefName) = value(x)
function Base.get(x::Dict{String, String}, val::CoefName, def::CoefName)
    if haskey(x, value(val))
        return CoefName(x[value(val)])
    else
        def
    end
end
get_coefname(x::AbstractTerm) = CoefName(coefnames(x))
get_coefname(x::Term) = CoefName(string(x.sym))
Base.replace(x::CoefName, r::Pair) = CoefName(replace(value(x), r))

get_coefname(x::AbstractString) = CoefName(String(x))
get_coefname(x::AbstractVector) = CoefName.(String.(x))


"""
    struct InteractedCoefName <: AbstractCoefName
        names::Vector
    end

Used to store the different coefficient names that makes up an InteractionTerm. The internals of the
vector are typically [`CoefName`](@ref), but can also be strings.

In a regression, each element of the vector is typically displayed as "name1 & name2 & ..." (in AsciiTables).
The separator is set by [`interaction_combine`](@ref) function, and the default varies based on [`AbstractRenderType`](@ref):
- For `AbstractAscii`, it defaults to `" & "`
- For `AbstractLaTeX`, it defaults to `" \$\\times\$ "`
- For `AbstractHtml`, it defaults to `" &times; "`


You can change the separator by running:
```julia
RegressionTables.interaction_combine(render::\$RenderType) = " & "
```
where `\$RenderType` is the type of the renderer you want to change. For example, to change the output in `AbstractLaTeX`:
```julia
RegressionTables.interaction_combine(::AbstractLaTeX) = " \\& "
```

You can control how interaction terms are displayed more generally by changing:
```julia
Base.repr(render::AbstractRenderType, x::RegressionTables.InteractedCoefName; args...) =
    join(RegressionTables.value.(x), RegressionTables.interaction_combine(render))
```

See [Customization of Defaults](@ref) for more details.
"""
struct InteractedCoefName <: AbstractCoefName
    names::Vector
    InteractedCoefName(names::Vector) = new(names)
end

value(x::InteractedCoefName) = x.names
Base.string(x::InteractedCoefName) = join(string.(x.names), " & ")
Base.hash(x::InteractedCoefName, h::UInt) = hash(sort(string.(value(x))), h)
Base.:(==)(x::InteractedCoefName, y::InteractedCoefName) = sort(string.(value(x))) == sort(string.(value(y)))
function Base.get(x::Dict{String, String}, val::InteractedCoefName, def::InteractedCoefName)
    # if the interaction exactly matches what would be in StatsModels, just return that
    # otherwise, go through each term in the interactionterm and see if the dict contains those pieces
    if haskey(x, string(val))
        return CoefName(x[string(val)])
    else
        InteractedCoefName(get.(Ref(x), value(val), value(def)))
    end
end
get_coefname(x::InteractionTerm) = 
    StatsModels.kron_insideout(
        (args...) -> InteractedCoefName(collect(args)),
        (StatsModels.vectorize(get_coefname.(x.terms)))...
    )
Base.replace(x::InteractedCoefName, r::Pair) = InteractedCoefName(replace.(value(x), Ref(r)))

"""
    struct CategoricalCoefName <: AbstractCoefName
        name::String
        level::String
    end

Used to store the name of a coefficient for a `CategoricalTerm`. The `level` is the level of the categorical.
In other words, the `name` is the column name, the `level` is the category within that column.

In a regression, the display of categorical terms is typically displayed as "name: level". You can change how the
categorical term is "equal" by changing the [`categorical_equal`](@ref) function. The default is ": ", but you can change:
this by setting:
```julia
RegressionTables.categorical_equal(render::AbstractRenderType) = " = "
RegressionTables.categorical_equal(render::AbstractLatex) = " \$=\$ "
```

You can also change how the categorical term is displayed by changing the [`repr`](@ref) function. The default is:
```julia
Base.repr(render::AbstractRenderType, x::RegressionTables.CategoricalCoefName; args...) =
    "\$(RegressionTables.value(x))\$(RegressionTables.categorical_equal(render)) \$(x.level)"
```
"""
struct CategoricalCoefName <: AbstractCoefName
    name::String
    level::String
    CategoricalCoefName(name::AbstractString, level::AbstractString) = new(String(name), String(level))
end

value(x::CategoricalCoefName) = x.name
Base.string(x::CategoricalCoefName) = "$(value(x)): $(x.level)"
get_coefname(x::CategoricalTerm) = [CategoricalCoefName(string(x.sym), string(n)) for n in x.contrasts.coefnames]
function Base.get(x::Dict{String, String}, val::CategoricalCoefName, def::CategoricalCoefName)
    # similar to interactioncoefname, if the categorical term exactly matches what would be in StatsModels, just return that
    if haskey(x, string(val))
        return CoefName(x[string(val)])
    else
        nm = get(x, value(val), value(def))
        lvl = get(x, val.level, def.level)
        CategoricalCoefName(nm, lvl)
    end
end

function Base.replace(x::CategoricalCoefName, r::Pair)
    CategoricalCoefName(
        replace(value(x), r),
        replace(x.level, r)
    )
end

"""
    struct InterceptCoefName <: AbstractCoefName end

Used as a simple indicator for the existence of an intercept term. This allows relabeling of the intercept
in all cases by setting
```julia
RegressionTables.label(::InterceptCoefName) = "My Intercept"
```
See [Customization of Defaults](@ref) for more details.
"""
struct InterceptCoefName <: AbstractCoefName end

Base.string(x::InterceptCoefName) = "(Intercept)"
get_coefname(x::InterceptTerm{H}) where {H} = H ? InterceptCoefName() : []
Base.get(x::Dict{String, String}, val::InterceptCoefName, def::InterceptCoefName) = get(x, string(val), def)
function Base.replace(x::InterceptCoefName, r::Pair)
    v = string(x)
    out = replace(v, r)
    if out == v
        InterceptCoefName()
    else
        out
    end
end

"""
    struct FixedEffectCoefName <: AbstractCoefName
        name::AbstractCoefName
    end

Used to store the name of a coefficient for a `FixedEffectTerm`.
The `name` is the name of the fixed effect. This allows a suffix to be
applied later.
"""
struct FixedEffectCoefName <: AbstractCoefName
    name::AbstractCoefName
    FixedEffectCoefName(x::AbstractCoefName) = new(x)
end

value(x::FixedEffectCoefName) = x.name
Base.string(x::FixedEffectCoefName) = string(x.name)
Base.get(x::Dict{String, String}, val::FixedEffectCoefName, def::FixedEffectCoefName) =
    FixedEffectCoefName(get(x, val.name, def.name))

Base.replace(x::FixedEffectCoefName, r::Pair) = FixedEffectCoefName(replace(x.name, r))

struct ClusterCoefName <: AbstractCoefName
    name::AbstractCoefName
    ClusterCoefName(x::AbstractCoefName) = new(x)
end

ClusterCoefName(x::String) = ClusterCoefName(CoefName(x))

value(x::ClusterCoefName) = x.name
Base.string(x::ClusterCoefName) = string(x.name)
Base.get(x::Dict{String, String}, val::ClusterCoefName, def::ClusterCoefName) =
    ClusterCoefName(get(x, val.name, def.name))

Base.replace(x::ClusterCoefName, r::Pair) = ClusterCoefName(replace(x.name, r))


"""
    struct RandomEffectCoefName <: AbstractCoefName
        rhs::CoefName
        lhs::AbstractCoefName
        val::Float64
    end

Used to store the name and the standard deviation of a coefficient for a `RandomEffectTerm` from
[MixedModels.jl](https://github.com/JuliaStats/MixedModels.jl). The standard deviation is stored
since that is often the useful information on the relationship between rhs and lhs.
"""
struct RandomEffectCoefName <: AbstractCoefName
    rhs::CoefName
    lhs::AbstractCoefName
    RandomEffectCoefName(rhs::CoefName, lhs::AbstractCoefName) = new(rhs, lhs)
end

value(x::RandomEffectCoefName) = x
Base.string(x::RandomEffectCoefName) = string(x.rhs) * " | " * string(x.lhs)
Base.hash(x::RandomEffectCoefName, h::UInt) = hash(string(x),h)
Base.:(==)(x::RandomEffectCoefName, y::RandomEffectCoefName) = string(x) == string(y)
function Base.get(x::Dict{String, String}, val::RandomEffectCoefName, def::RandomEffectCoefName)
    rhs = get(x, val.rhs, def.rhs)
    lhs = get(x, val.lhs, def.lhs)
    RandomEffectCoefName(rhs, lhs)
end
