@testset "DictTabular" begin
    t = DictTable(Dict(:a => [1,2,3], :b => [true, false, true]))

    @test t isa DictTable
    @test_broken DictTable(:a => [1,2,3], :b => [true, false, true]) == t

    @test indices(t) == (Base.OneTo(3), keys(t.dict))

    @test t[2, :a] == 2
    @test (t[2, :a] = 5; t[2, :a] == 5)
end
