
escape_latex_dict = Dict("&" => "\\&", "%" => "\\%", "\$" => "\\\$", "#" => "\\#", "_" => "\\_", "{" => "\\{", "}" => "\\}")

function _escape(s::Symbol)
  if s == :ampersand
    Dict("&" => "\\&")
  elseif s == :underscore
    Dict("_" => "\\_")
  elseif s == :underscore2space
    Dict("_" => " ")
  elseif s == :latex
    escape_latex_dict
  else
    @error "Please provide `:ampersand`, `:underscore`, `:underscore2space`, `:latex`, a `::Dict` or a custom function."
  end
end



