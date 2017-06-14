@testset "TupleTabular" begin
    @testset "TupleSeries" begin
        @test @inferred(Series(l"a"=>1)) isa Series{<:Tuple{Vararg{Pair}}}
        @test @inferred(Series(l"a"=>1, l"b"=>true)) isa Series{<:Tuple{Vararg{Pair}}}
        s = Series(l"a"=>1, l"b"=>true)
        @test @inferred(s[l"a"]) === 1
        @test @inferred(s[l"b"]) === true
        @test_throws IndexError s[l"c"]
        @test @inferred(s[(l"a", l"b")]) === s
        @test_throws IndexError s[(l"a",l"c")]
        @test @inferred(s[:]) === s
    end

    @testset "TupleTable" begin
        # TupleTable with inner DictSeries
        @test @inferred(Table(l"a" => Dict(:x=>1,:y=>2,:z=>3), l"b" => Dict(:x=>4.0,:y=>5.0,:z=>6.0))) isa Table{<:Tuple{Vararg{Pair}}}
        t = Table(l"a" => Dict(:x=>1,:y=>2,:z=>3), l"b" => Dict(:x=>4.0,:y=>5.0,:z=>6.0))
        @test @inferred(indices(t)) == (keys(get(t)[1].second), (l"a", l"b"))
        @test @inferred(t[:y, l"a"]) === 2
        @test @inferred(t[:y, (l"a",l"b")]) === Series(l"a" => 2, l"b" => 5.0)
        @test_throws IndexError t[:y, l"c"]
        @test @inferred(t[:y, :]) === Series(l"a" => 2, l"b" => 5.0)
        @test @inferred(t[:, l"a"]) == Series(Dict(:x => 1, :y => 2, :z => 3))
        @test @inferred(t[:, (l"a",l"b")]) == t
        @test @inferred(t[:, :]) == t

        @test_broken (t[:y, l"a"] = 5; t[:y, l"a"] === 5)

        # TupleTable with inner ArraySeries
        @test @inferred(Table(l"a" => [1,2,3], l"b" => [4.0,5.0,6.0])) isa Table{<:Tuple{Vararg{Pair}}}
        t2 = Table(l"a" => [1,2,3], l"b" => [4.0,5.0,6.0])
        @test @inferred(indices(t2)) === (Base.OneTo(3), (l"a", l"b"))
        @test @inferred(t2[2, l"a"]) === 2
        @test_throws IndexError t[2, l"c"]
        @test @inferred(t2[2, :]) == Series(l"a" => 2, l"b" => 5)
        @test @inferred(t2[:, l"a"]) == Series([1,2,3])
        @test @inferred(t2[:, :]) == t2

        @test_broken (t2[2, l"a"] = 5; t2[2, l"a"] === 5)

        # TupleTable with inner TupleSeries
        @test @inferred(Table(l"a" => (l"x"=>true,l"y"=>2,l"z"=>3), l"b" => (l"x"=>4.0,l"y"=>5.0f0,l"z"=>6.0))) isa Table{<:Tuple{Vararg{Pair}}}
        t3 = Table(l"a" => (l"x"=>true,l"y"=>2,l"z"=>3), l"b" => (l"x"=>4.0,l"y"=>5.0f0,l"z"=>6.0))
        @test @inferred(indices(t3)) === ((l"x", l"y", l"z"), (l"a", l"b"))
        @test @inferred(t3[l"y", l"a"]) === 2
        @test_throws IndexError t[l"y", l"c"]
        if VERSION <= v"0.6.0-rc3.0"
            # Inference works at REPL but not in test
            @test t3[l"y", :] === Series(l"a" => 2, l"b" => 5.0f0)
            @test_broken @inferred(t3[l"y", :]) === Series(l"a" => 2, l"b" => 5.0f0)
        else
            @test @inferred(t3[l"y", :]) === Series(l"a" => 2, l"b" => 5.0f0)
        end
        @test @inferred(t3[:, l"a"]) === Series(l"x" => true, l"y" => 2, l"z" => 3)
        @test @inferred(t3[:, :]) === t3

        # TupleTable with inner StructSeries
        @test @inferred(Table(l"a" => 1+2im, l"b" => 3.0+4.0im)) isa Table{<:Tuple{Vararg{Pair}}}
        t4 = Table(l"a" => 1+2im, l"b" => 3.0+4.0im)
        @test @inferred(indices(t4)) === ((l"re", l"im"), (l"a", l"b"))
        @test @inferred(t4[l"im", l"a"]) === 2
        @test_throws IndexError t[l"im", l"c"]
        @test @inferred(t4[l"im", :]) === Series(l"a" => 2, l"b" => 4.0) # Inference works at REPL but not in test
        @test @inferred(t4[:, l"a"]) == Series(1+2im)
        
        if VERSION <= v"0.6.0-rc3.0"
            @test @inferred(t4[:, :]) == t4
        else 
            # TODO - check inference of this on Julia v0.7, which is uninferred at REPL
            # (at least it's consistent...)
            @test t4[:, :] == t4
            @test_broken @inferred(t4[:, :]) == t4
        end
    end
end
