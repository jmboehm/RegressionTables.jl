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
    CoefName(name::String) = new(name)
end

value(x::CoefName) = x.name
Base.string(x::CoefName) = value(x)
function Base.get(x::Dict{String, String}, val::CoefName, def::CoefName)
    if haskey(x, value(val))
        return x[value(val)]
    else
        def
    end
end
get_coefname(x::AbstractTerm) = CoefName(coefnames(x))
get_coefname(x::Term) = CoefName(string(x.sym))
Base.replace(x::CoefName, r::Pair) = CoefName(replace(value(x), r))

"""
    struct InteractedCoefName <: AbstractCoefName
        names::Vector
    end

Used to store the different coefficient names that makes up an InteractionTerm. The internals of the
vector are typically [`CoefName`](@ref), but can also be strings.

In a regression, each element of the vector is typically displayed as "name1 & name2 & ..." (in AsciiTables).
You can change this by setting:
```julia
(::Type{T})(x::RegressionTables.InteractedCoefName; args...) where {T <: RegressionTables.AbstractRenderType} =
    join(RegressionTables.value.(x), RegressionTables.interaction_equal(T()))
```
where `interaction_equal` is another function that is settable and varies based on [`AbstractRenderType`](@ref).
- For `AbstractAscii`, it defaults to `" & "`
- For `AbstractLaTeX`, it defaults to `" \$\\times\$ "`
- For `AbstractHTML`, it defaults to `" &times; "`

See [Customization](@ref) for more details.
"""
struct InteractedCoefName <: AbstractCoefName
    names::Vector
    InteractedCoefName(names::Vector) = new(names)
end

Base.values(x::InteractedCoefName) = x.names
Base.string(x::InteractedCoefName) = join(string.(x.names), " & ")
Base.hash(x::InteractedCoefName, h::UInt) = hash(sort(string.(values(x))), h)
Base.:(==)(x::InteractedCoefName, y::InteractedCoefName) = sort(string.(values(x))) == sort(string.(values(y)))
function Base.get(x::Dict{String, String}, val::InteractedCoefName, def::InteractedCoefName)
    # if the interaction exactly matches what would be in StatsModels, just return that
    # otherwise, go through each term in the interactionterm and see if the dict contains those pieces
    if haskey(x, string(val))
        return x[string(val)]
    else
        InteractedCoefName(get.(Ref(x), values(val), values(def)))
    end
end
get_coefname(x::InteractionTerm) = 
    StatsModels.kron_insideout(
        (args...) -> InteractedCoefName(collect(args)),
        (StatsModels.vectorize(get_coefname.(x.terms)))...
    )
Base.replace(x::InteractedCoefName, r::Pair) = InteractedCoefName(replace.(values(x), Ref(r)))

"""
    struct CategoricalCoefName <: AbstractCoefName
        name::String
        level::String
    end

Used to store the name of a coefficient for a `CategoricalTerm`. The `level` is the level of the categorical.
In other words, the `name` is the column name, the `level` is the category within that column.

In a regression, the display of categorical terms is typically displayed as "name: level". You can change
this by setting:
```julia
(::Type{T})(x::RegressionTables.CategoricalCoefName; args...) where {T <: RegressionTables.AbstractRenderType} =
    "\$(RegressionTables.value(x))\$(RegressionTables.categorical_equal(T())) \$(x.level)"
```
where `categorical_equal` is another function that defaults to ": ", so that is also settable.
"""
struct CategoricalCoefName <: AbstractCoefName
    name::String
    level::String
    CategoricalCoefName(name::String, level::String) = new(name, level)
end

value(x::CategoricalCoefName) = x.name
Base.string(x::CategoricalCoefName) = "$(value(x)): $(x.level)"
get_coefname(x::CategoricalTerm) = [CategoricalCoefName(string(x.sym), string(n)) for n in x.contrasts.termnames]
function Base.get(x::Dict{String, String}, val::CategoricalCoefName, def::CategoricalCoefName)
    # similar to interactioncoefname, if the categorical term exactly matches what would be in StatsModels, just return that
    if haskey(x, string(val))
        return x[string(val)]
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
See [Customization](@ref) for more details.
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


function Base.intersect(x::Vector{String}, y::Vector{<:AbstractCoefName})
    # intersect the string names of x with the values of y
    # return the values of y
    #=
    This is used to get the correct order of the coefficients
    =#
    all_names = string.(y)
    [y[findfirst(a .== all_names)] for a in x]
end
function Base.setdiff(x::Vector{<:AbstractCoefName}, y::Vector{String})
    # setdiff the string names of x with y
    # return the values of x
    #=
    This is used to get the correct order of the coefficients
    =#
    [a for a in x if string(x) ∉ y]
end

