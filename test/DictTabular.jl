@testset "DictTabular" begin
    @testset "DictSeries" begin
        @test @inferred(Series(:a => 1, :b => 2)) isa DictSeries
        s = Series(:a => 1, :b => 2)
        @test @inferred(indices(s)) == (keys(s.dict),)
        @test @inferred(s[:a]) === 1
        @test @inferred(s[[:a, :b]]) == s
        @test @inferred(s[:]) == s

        @test (s[:a] = 5; s[:a] === 5)
    end

    @testset "DictTable" begin
        # DictTable with inner DictSeries
        @test @inferred(Table(:a => (:x=>1,:y=>2,:z=>3), :b => (:x=>4,:y=>5,:z=>6))) isa DictTable
        t = Table(:a => (:x=>1,:y=>2,:z=>3), :b => (:x=>4,:y=>5,:z=>6))
        @test @inferred(indices(t)) == (keys(t.dict[:a].dict), keys(t.dict))
        @test @inferred(t[:y, :a]) === 2
        @test @inferred(t[:y, :]) == Series(:a => 2, :b => 5)
        @test @inferred(t[:, :a]) == Series(:x => 1, :y => 2, :z => 3)
        @test @inferred(t[:, :]) == t

        @test (t[:y, :a] = 5; t[:y, :a] === 5)

        # DictTable with inner ArraySeries
        @test @inferred(Table(:a => [1,2,3], :b => [4,5,6])) isa DictTable
        t2 = Table(:a => [1,2,3], :b => [4,5,6])
        @test @inferred(indices(t2)) == (Base.OneTo(3), keys(t2.dict))
        @test @inferred(t2[2, :a]) === 2
        @test @inferred(t2[2, :]) == Series(:a => 2, :b => 5)
        @test @inferred(t2[:, :a]) == Series([1,2,3])
        @test @inferred(t2[:, :]) == t2

        @test (t2[2, :a] = 5; t2[2, :a] === 5)
    end
end
