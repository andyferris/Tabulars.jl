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
        # TODO
    end
end
