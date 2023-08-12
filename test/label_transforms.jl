using RegressionTables: _escape
using Test
@testset "label transforms" begin
  # ampersand
  @test replace("X1 & X2", _escape(:ampersand)...) == "X1 \\& X2"
  
  # underscores
  @test replace("long_var", _escape(:underscore2space)...) == "long var"
  @test replace("long_var", _escape(:underscore)...) == "long\\_var"
  
  # latex
  @test replace("& % \$ # _ { }", _escape(:latex)...) == "\\& \\% \\\$ \\# \\_ \\{ \\}"
  
  # Dictionary
  @test replace("bla bla bla", Dict("bla" => "blaaaa")...) == "blaaaa blaaaa blaaaa"
end

