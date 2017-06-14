@testset "DictTabular" begin
    @testset "DictSeries" begin
        @test @inferred(Series(Dict(:a => 1, :b => 2))) isa Series
        s = Series(Dict(:a => 1, :b => 2))
        @test @inferred(indices(s)) == (keys(get(s)),)
        @test @inferred(s[:a]) === 1
        @test @inferred(s[[:a, :b]]) == s
        @test @inferred(s[:]) == s

        @test_broken (s[:a] = 5; s[:a] === 5)
    end

    @testset "DictTable" begin
        # DictTable with inner DictSeries
        @test @inferred(Table(Dict(:a => Dict(:x=>1,:y=>2,:z=>3), :b => Dict(:x=>4,:y=>5,:z=>6)))) isa Table
        t = Table(Dict(:a => Dict(:x=>1,:y=>2,:z=>3), :b => Dict(:x=>4,:y=>5,:z=>6)))
        @test @inferred(indices(t)) == (keys(get(t)[:a]), keys(get(t)))
        @test @inferred(t[:y, :a]) === 2
        @test @inferred(t[:y, [:a, :b]]) == Series(Dict(:a => 2, :b => 5))
        #if VERSION <= v"0.6.0-rc3.0"
        #    # Inference works at REPL but not in test
        #    @test t[:y, :] == Series(Dict(:a => 2, :b => 5))
        #    @test_broken @inferred(t[:y, :]) == Series(Dict(:a => 2, :b => 5))
        #else
            @test @inferred(t[:y, :]) == Series(Dict(:a => 2, :b => 5))
        #end
        @test @inferred(t[[:x,:y,:z], :a]) == Series(Dict(:x => 1, :y => 2, :z => 3))
        @test @inferred(t[[:x,:y,:z], [:a, :b]]) == t
        if VERSION <= v"0.6.0-rc3.0"
            # Inference works at REPL but not in test
            @test t[[:x,:y,:z], :] == t
            @test_broken @inferred(t[[:x,:y,:z], :]) == t
        else
            @test @inferred(t[[:x,:y,:z], :]) == t
        end
        @test @inferred(t[:, :a]) == Series(Dict(:x => 1, :y => 2, :z => 3))
        @test @inferred(t[:, [:a, :b]]) == t
        #if VERSION <= v"0.6.0-rc3.0"
        #    # Inference works at REPL but not in test
        #    @test t[:, :] == t
        #    @test_broken @inferred(t[:, :]) == t
        #else
            @test @inferred(t[:, :]) == t
        #end
        @test_broken (t[:y, :a] = 5; t[:y, :a] === 5)

        # DictTable with inner ArraySeries
        @test @inferred(Table(Dict(:a => [1,2,3], :b => [4,5,6]))) isa Table
        t2 = Table(Dict(:a => [1,2,3], :b => [4,5,6]))
        @test @inferred(indices(t2)) == (Base.OneTo(3), keys(get(t2)))
        @test @inferred(t2[2, :a]) === 2
        @test @inferred(t2[2, [:a, :b]]) == Series(Dict(:a => 2, :b => 5))
        #if VERSION <= v"0.6.0-rc3.0"
        #    # Inference works at REPL but not in test
        #    @test t2[2, :] == Series(Dict(:a => 2, :b => 5))
        #    @test_broken @inferred(t2[2, :]) == Series(Dict(:a => 2, :b => 5))
        #else
            @test @inferred(t2[2, :]) == Series(Dict(:a => 2, :b => 5))
        #end
        @test @inferred(t2[:, :a]) == Series([1,2,3])
        @test @inferred(t2[:, [:a, :b]]) == t2
        #if VERSION <= v"0.6.0-rc3.0"
        #    # Inference works at REPL but not in test
        #    @test t2[:, :] == t2
        #    @test_broken @inferred(t2[:, :]) == t2
        #else
            @test @inferred(t2[:, :]) == t2
        #end
        @test_broken (t2[2, :a] = 5; t2[2, :a] === 5)

        # DictTable with inner TupleSeries
        @test @inferred(Table(Dict(:a => (l"x"=>1,l"y"=>2,l"z"=>3), :b => (l"x"=>4,l"y"=>5,l"z"=>6)))) isa Table
        t3 = Table(Dict(:a => (l"x"=>1,l"y"=>2,l"z"=>3), :b => (l"x"=>4,l"y"=>5,l"z"=>6)))
        @test @inferred(indices(t3)) == ((l"x", l"y", l"z"), keys(get(t3)))
        @test @inferred(t3[l"y", :a]) === 2
        if VERSION <= v"0.6.0-rc3.0"
            # Inference works at REPL but not in test
            @test t3[l"y", :] == Series(Dict(:a => 2, :b => 5))
            @test_broken @inferred(t3[l"y", :]) == Series(Dict(:a => 2, :b => 5))
        else
            @test @inferred(t3[l"y", :]) == Series(Dict(:a => 2, :b => 5))
        end
        @test @inferred(t3[:, :a]) === Series(l"x" => 1, l"y" => 2, l"z" => 3)
        #if VERSION <= v"0.6.0-rc3.0"
        #    # Inference works at REPL but not in test
        #    @test t3[:, :] == t3
        #    @test_broken @inferred(t3[:, :]) == t3
        #else
            @test @inferred(t3[:, :]) == t3
        #end

        # DictTable with inner StructSeries
        @test @inferred(Table(Dict(:a => 1+2im, :b => 3+4im))) isa Table
        t4 = Table(Dict(:a => 1+2im, :b => 3+4im))
        @test @inferred(indices(t4)) == ((l"re", l"im"), keys(get(t4)))
        @test @inferred(t4[l"im", :a]) === 2
        if VERSION <= v"0.6.0-rc3.0"
            # Inference works at REPL but not in test
            @test t4[l"im", :] == Series(:a => 2, :b => 4)
            @test_broken @inferred(t4[l"im", :]) == Series(:a => 2, :b => 4)
        else
            @test @inferred(t4[l"im", :]) == Series(:a => 2, :b => 4)
        end
        @test @inferred(t4[:, :a]) == Series(1+2im)
        if VERSION <= v"0.6.0-rc3.0"
            # Inference works at REPL but not in test
            @test t4[:, :] == t4
            @test_broken @inferred(t4[:, :]) == t4
        else
            @test @inferred(t4[:, :]) == t4

        end
    end
end
