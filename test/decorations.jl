deco_tight    = make_estim_decorator([0.001, 0.01, 0.05]) # the default
deco_standard = make_estim_decorator([0.01, 0.05, 0.1])
deco_latex    = make_estim_decorator([0.01, 0.05, 0.1],
                                     wrapper=s -> "^\\sym{$s}")
deco_1pc      = make_estim_decorator([0.01])

@testset "decorations" begin
    @testset "deco_tight" begin
        @test deco_tight(123, 0.0) == "123***"
        @test deco_tight(123, 0.001) == "123***"
        @test deco_tight(123, 0.01) == "123**"
        @test deco_tight(123, 0.02) == "123*"
        @test deco_tight(123, 0.1) == "123"
    end

    @testset "deco_standard" begin
        @test deco_standard(123, 0.0) == "123***"
        @test deco_standard(123, 0.01) == "123***"
        @test deco_standard(123, 0.02) == "123**"
        @test deco_standard(123, 0.1) == "123*"
        @test deco_standard(123, 0.2) == "123"
    end

    @testset "deco_latex" begin
        @test deco_latex(123, 0.0) == "123^\\sym{***}"
        @test deco_latex(123, 0.01) == "123^\\sym{***}"
        @test deco_latex(123, 0.02) == "123^\\sym{**}"
        @test deco_latex(123, 0.1) == "123^\\sym{*}"
        @test deco_latex(123, 0.2) == "123"
    end

    @testset "deco_1pc" begin
        @test deco_1pc(123, 0.0) == "123*"
        @test deco_1pc(123, 0.01) == "123*"
        @test deco_1pc(123, 0.02) == "123"
    end
end
