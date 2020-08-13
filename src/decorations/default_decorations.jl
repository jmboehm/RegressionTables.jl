function make_estim_decorator(breaks=[0.01, 0.05, 0.1], sym='*'; wrapper=identity)
  @assert issorted(breaks)
    
  function estim_decorator(s, pval)
    pval >= 0 || @error "p value = $pval, but it needs to be non-negative"

    i0 = findfirst(pval .<= breaks)
    i = isnothing(i0) ? length(breaks) + 1 : i0
      
    deco = sym^(length(breaks) - (i - 1))
    if deco != ""
      deco = wrapper(deco)
    end
    
    "$s"*deco
  end
end
