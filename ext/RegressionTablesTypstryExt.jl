module RegressionTablesTypstryExt

using Typstry, RegressionTables

Typstry.show_typst(io::IO, ::TypstContext, rt::RegressionTable{<:AbstractTypst}) = print(io, rt)

end
