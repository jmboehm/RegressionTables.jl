# this function escapes the ampersand, which is probably the most common use case
function escape_ampersand(s::String)
    repl_dict = Dict("&" => "\\&") 
    for (old, new) in repl_dict
        s = replace.(s, Ref(old => new))
    end
    return s
end
