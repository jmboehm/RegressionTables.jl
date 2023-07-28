get_coefname(x::MatrixTerm) = mapreduce(get_coefname, vcat, x.terms)

abstract type AbstractCoefName end
(::Type{T})(x::T) where {T<:AbstractCoefName} = x
Base.broadcastable(x::AbstractCoefName) = Ref(x)

# for functionterm and continuousterm
#=
It might be nice to add a separate functionterm piece so that the internals could easily
change just like InteractedCoefName, but the internals are not parsed in the same way
which makes that extremely difficult to do
=#
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
Base.replace(x::CoefName, r::Pair) = CoefName(replace(value(x), r))

# for interactionterm
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

# for categoricalterm
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

struct InterceptCoefName <: AbstractCoefName end
Base.string(x::InterceptCoefName) = "(Intercept)"
get_coefname(x::InterceptTerm{H}) where {H} = H ? InterceptCoefName() : []
Base.get(x::Dict{String, String}, val::InterceptCoefName, def::InterceptCoefName) = get(x, string(val), def)
Base.replace(x::InterceptCoefName, r::Pair) = InterceptCoefName()


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

