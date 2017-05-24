@testset "ArrayTabular" begin
    @testset "ArraySeries" begin
        t1 = ArraySeries([1,2,3,4])

        @test indices(t1) === (Base.OneTo(4),)
        @test t1[3] == 3
        @test_throws DimensionMismatch t1[1,2]

        @test t1[:]::ArraySeries == t1
        @test t1[:]::ArraySeries == t1
    end

    @testset "ArrayTable" begin
        t2 = ArrayTable([[1,2],[3,4]])

        @test indices(t2) === (Base.OneTo(2), Base.OneTo(2))
        @test t2[2,1] == 2
    end
end
