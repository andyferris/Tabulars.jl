@testset "ArrayTabular" begin
    @testset "ArraySeries" begin
        t1 = ArraySeries([2,3,4,5])

        @test @inferred(Series([2,3,4,5])) isa ArraySeries

        @test @inferred(indices(t1)) === (Base.OneTo(4),)
        @test @inferred(t1[3]) == 4
        @test_throws DimensionMismatch t1[1,2]

        @test_broken t1[:]::ArraySeries == t1
        @test_broken t1[:]::ArraySeries == t1
    end

    @testset "ArrayTable" begin
        t2 = ArrayTable([[1,2],[3,4]])

        @test indices(t2) === (Base.OneTo(2), Base.OneTo(2))
        @test t2[2,1] == 2
    end
end
