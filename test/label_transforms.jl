using RegressionTables: _escape
using Test
@testset "label transforms" begin
  # ampersand
  @test _escape(:ampersand)("X1 & X2") == "X1 \\& X2"
  
  # underscores
  @test _escape(:underscore2space)("long_var") == "long var"
  @test _escape(:underscore)("long_var") == "long\\_var"
  
  # latex
  @test _escape(:latex)("& % \$ # _ { }") == "\\& \\% \\\$ \\# \\_ \\{ \\}"
  
  # Dictionary
  @test _escape(Dict("bla" => "blaaaa"))("bla bla bla") == "blaaaa blaaaa blaaaa"
end

