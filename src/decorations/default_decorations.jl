
function estim_decorator(tab::AbstractRenderType, s, pval; breaks=[0.01, 0.05, 0.1], sym='*')
    @assert issorted(breaks)
    (pval >= 0 || isnan(pval)) || @error "p value = $pval, but it needs to be non-negative"

    i0 = findfirst(pval .<= breaks)
    i = isnothing(i0) ? length(breaks) + 1 : i0
      
    deco = sym^(length(breaks) - (i - 1))
    if deco != ""
        deco = wrapper(tab, deco)
    end

    to_string(tab, s)*deco
end
