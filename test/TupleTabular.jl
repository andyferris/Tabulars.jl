@testset "TupleTabular" begin
    @testset "TupleSeries" begin
        @test @inferred(Series(l"a"=>1)) isa TupleSeries
        @test @inferred(Series(l"a"=>1, l"b"=>true)) isa TupleSeries
        s = Series(l"a"=>1, l"b"=>true)
        @test @inferred(s[l"a"]) === 1
        @test @inferred(s[l"b"]) === true
        @test @inferred(s[(l"a", l"b")]) === s
        @test @inferred(s[:]) === s
    end

    @testset "TupleTable" begin
        # TupleTable with inner DictSeries
        @test @inferred(Table(l"a" => (:x=>1,:y=>2,:z=>3), l"b" => (:x=>4.0,:y=>5.0,:z=>6.0))) isa TupleTable
        t = Table(l"a" => (:x=>1,:y=>2,:z=>3), l"b" => (:x=>4.0,:y=>5.0,:z=>6.0))
        @test @inferred(indices(t)) == (keys(t.data[1].second.dict), (l"a", l"b"))
        @test @inferred(t[:y, l"a"]) === 2
        @test @inferred(t[:y, :]) === Series(l"a" => 2, l"b" => 5.0)
        @test @inferred(t[:, l"a"]) == Series(:x => 1, :y => 2, :z => 3)
        @test @inferred(t[:, :]) == t

        @test (t[:y, l"a"] = 5; t[:y, l"a"] === 5)

        # TupleTable with inner ArraySeries
        @test @inferred(Table(l"a" => [1,2,3], l"b" => [4.0,5.0,6.0])) isa TupleTable
        t2 = Table(l"a" => [1,2,3], l"b" => [4.0,5.0,6.0])
        @test @inferred(indices(t2)) === (Base.OneTo(3), (l"a", l"b"))
        @test @inferred(t2[2, l"a"]) === 2
        @test @inferred(t2[2, :]) == Series(l"a" => 2, l"b" => 5)
        @test @inferred(t2[:, l"a"]) == Series([1,2,3])
        @test @inferred(t2[:, :]) == t2

        @test (t2[2, l"a"] = 5; t2[2, l"a"] === 5)

        # TupleTable with inner TupleSeries
        @test @inferred(Table(l"a" => (l"x"=>true,l"y"=>2,l"z"=>3), l"b" => (l"x"=>4.0,l"y"=>5.0f0,l"z"=>6.0))) isa TupleTable
        t3 = Table(l"a" => (l"x"=>true,l"y"=>2,l"z"=>3), l"b" => (l"x"=>4.0,l"y"=>5.0f0,l"z"=>6.0))
        @test @inferred(indices(t3)) === ((l"x", l"y", l"z"), (l"a", l"b"))
        @test @inferred(t3[l"y", l"a"]) === 2
        @test_broken @inferred(t3[l"y", :]) === Series(l"a" => 2, l"b" => 5.0f0) # Inference works at REPL but not in test
        @test @inferred(t3[:, l"a"]) === Series(l"x" => true, l"y" => 2, l"z" => 3)
        @test @inferred(t3[:, :]) === t3

        # TupleTable with inner StructSeries
        @test @inferred(Table(l"a" => 1+2im, l"b" => 3.0+4.0im)) isa TupleTable
        t4 = Table(l"a" => 1+2im, l"b" => 3.0+4.0im)
        @test @inferred(indices(t4)) === ((l"re", l"im"), (l"a", l"b"))
        @test @inferred(t4[l"im", l"a"]) === 2
        @test @inferred(t4[l"im", :]) === Series(l"a" => 2, l"b" => 4.0) # Inference works at REPL but not in test
        @test @inferred(t4[:, l"a"]) === Series(1+2im)
        @test @inferred(t4[:, :]) === t4
    end
end
