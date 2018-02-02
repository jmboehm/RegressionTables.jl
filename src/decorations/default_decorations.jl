# * 5%, ** 1%, *** 0.1%
function default_ascii_estim_decoration(s::String, pval::Float64)
  if pval<0.0
      error("p value needs to be nonnegative.")
  end
  if (pval > 0.1)
      return "$s"
  elseif (pval > 0.05)
      return "$s"
  elseif (pval > 0.01)
      return "$s*"
  elseif (pval > 0.001)
      return "$s**"
  else
      return "$s***"
  end
end
function default_latex_estim_decoration(s::String, pval::Float64)
  if pval<0.0
      error("p value needs to be nonnegative.")
  end
  if (pval > 0.1)
      return "$s"
  elseif (pval > 0.05)
      return "$s"
  elseif (pval > 0.01)
      return "$s\\sym{*}"
  elseif (pval > 0.001)
      return "$s\\sym{**}"
  else
      return "$s\\sym{***}"
  end
end
