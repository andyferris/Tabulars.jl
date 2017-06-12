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
        if VERSION <= v"0.6.0-rc3.0"
            # Inference works at REPL but not in test
            @test t[:y, [:a, :b]] == Series(:a => 2, :b => 5)
            @test_broken @inferred(t[:y, [:a, :b]]) == Series(:a => 2, :b => 5)
        else
            @test @inferred(t[:y, [:a, :b]]) == Series(:a => 2, :b => 5)
        end
        @test @inferred(t[:y, :]) == Series(:a => 2, :b => 5)
        @test @inferred(t[:, :a]) == Series(:x => 1, :y => 2, :z => 3)
        if VERSION <= v"0.6.0-rc3.0"
            # Inference works at REPL but not in test
            @test t[:, [:a, :b]] == t
            @test_broken @inferred(t[:, [:a, :b]]) == t
        else
            @test @inferred(t[:, [:a, :b]]) == t
        end
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

        # DictTable with inner TupleSeries
        @test @inferred(Table(:a => (l"x"=>1,l"y"=>2,l"z"=>3), :b => (l"x"=>4,l"y"=>5,l"z"=>6))) isa DictTable
        t3 = Table(:a => (l"x"=>1,l"y"=>2,l"z"=>3), :b => (l"x"=>4,l"y"=>5,l"z"=>6))
        @test @inferred(indices(t3)) == ((l"x", l"y", l"z"), keys(t3.dict))
        @test @inferred(t3[l"y", :a]) === 2
        if VERSION <= v"0.6.0-rc3.0"
            # Inference works at REPL but not in test
            @test t3[l"y", :] == Series(:a => 2, :b => 5)
            @test_broken @inferred(t3[l"y", :]) == Series(:a => 2, :b => 5)
        else
            @test @inferred(t3[l"y", :]) == Series(:a => 2, :b => 5)
        end
        @test @inferred(t3[:, :a]) === Series(l"x" => 1, l"y" => 2, l"z" => 3)
        @test @inferred(t3[:, :]) == t3

        # DictTable with inner StructSeries
        @test @inferred(Table(:a => 1+2im, :b => 3+4im)) isa DictTable
        t4 = Table(:a => 1+2im, :b => 3+4im)
        @test @inferred(indices(t4)) == ((l"re", l"im"), keys(t4.dict))
        @test @inferred(t4[l"im", :a]) === 2
        if VERSION <= v"0.6.0-rc3.0"
            # Inference works at REPL but not in test
            @test t4[l"im", :] == Series(:a => 2, :b => 4)
            @test_broken @inferred(t4[l"im", :]) == Series(:a => 2, :b => 4)
        else
            @test @inferred(t4[l"im", :]) == Series(:a => 2, :b => 4)
        end
        @test @inferred(t4[:, :a]) === Series(1+2im)
        @test @inferred(t4[:, :]) == t4
    end
end
