default_breaks(rndr::AbstractRenderType) = [0.001, 0.01, 0.05]
default_symbol(rndr::AbstractRenderType) = '*'

"""
    estim_decorator(rndr::T, s, pval; breaks=default_breaks(T()), sym=default_symbol(T())) where {T<:AbstractRenderType}

Decorates a value with a symbol based on p-value. In many journals, the symbol is a * and the p-value has three cutoffs, either
0.001, 0.01, and 0.05 or 0.01, 0.05, and 0.10.

It is possible to wrap the symbols in an additional element, for example, in Latex it is common to wrap the symbol as a superscript.
To do so in all tables, run
```julia
RegressionTables.wrapper(::AbstractLatex, deco) = "\$^{\$deco}\$"
```

It is also possible to change the cutoffs or symbols. To change the cutoffs, run
```julia
RegressionTables.default_breaks(::AbstractLatex) = [0.01, 0.05, 0.10] # make sure these are in order
```
And to change the cutoffs run
```julia
RegressionTables.default_symbol(::AbstractLatex) = "x" # or whatever you want
```
"""
function estim_decorator(rndr::T, s, pval; breaks=default_breaks(T()), sym=default_symbol(T())) where {T<:AbstractRenderType}
    @assert issorted(breaks)
    (pval >= 0 || isnan(pval)) || @error "p value = $pval, but it needs to be non-negative"

    i0 = findfirst(pval .<= breaks)
    i = isnothing(i0) ? length(breaks) + 1 : i0
      
    deco = sym^(length(breaks) - (i - 1))
    if deco != ""
        deco = wrapper(rndr, deco)
    end

    T(s)*deco
end

function make_estim_decorator(breaks=[0.01, 0.05, 0.1], sym='*'; wrapper=identity)
    @assert issorted(breaks)
    @warn("`make_estim_decorator` is deprecated, set breaks by running `RegressionTables.default_breaks(::AbstractRenderType) = $breaks`,")
    @warn("set symbol by running `RegressionTables.default_symbol(::AbstractRenderType) = $sym`,")
    @warn("and set wrapper by running `RegressionTables.wrapper(::AbstractRenderType, deco) = $wrapper(deco)`")
    function estim_decorator(s, pval)
        (pval >= 0 || isnan(pval)) || @error "p value = $pval, but it needs to be non-negative"

        i0 = findfirst(pval .<= breaks)
        i = isnothing(i0) ? length(breaks) + 1 : i0

        deco = sym^(length(breaks) - (i - 1))
        if deco != ""
            deco = wrapper(deco)
        end

        "$s"*deco
    end
end