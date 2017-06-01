@testset "StructTabular" begin
    @testset "StructSeries" begin
        @test @inferred(Series(2+3im)) isa StructSeries

        s = Series(2+3im)
        @test @inferred(s[l"re"]) === 2
        @test @inferred(s[l"im"]) === 3
        @test_throws Exception @inferred(s[l"bla"])

        @test @inferred(s[:]) === s
        @test @inferred(s[(l"re", l"im")]) === Series(l"re" => 2, l"im" => 3)
    end

    @testset "Tables with StructSeries as rows" begin
        @test @inferred(Table([1+2im, 3+4im])) isa ArrayTable

        t = Table([1+2im, 3+4im])

        @test @inferred(t[l"re", 1]) === 1
        @test @inferred(t[l"re", 2]) === 3
        @test @inferred(t[l"im", 1]) === 2
        @test @inferred(t[l"im", 2]) === 4

        @test @inferred(t[:, 1]) === Series(1+2im)
        @test @inferred(t[:, 2]) === Series(3+4im)
        @test @inferred(t[l"re", :]) == Series([1,3])
        @test @inferred(t[l"im", :]) == Series([2,4])

        @test @inferred(t[:, :]) == t
    end
end
