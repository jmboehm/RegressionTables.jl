default_breaks(rndr::AbstractRenderType) = [0.001, 0.01, 0.05]
default_symbol(rndr::AbstractRenderType) = '*'

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
