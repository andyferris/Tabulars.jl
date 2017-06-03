@testset "ArrayTabular" begin
    @testset "ArraySeries" begin
        @test @inferred(Series([2,3,4,5])) isa ArraySeries

        t1 = Series([2,3,4,5])

        @test @inferred(indices(t1)) === (Base.OneTo(4),)
        @test @inferred(t1[3]) == 4
        @test_throws Exception t1[1,2]

        @test @inferred(t1[:])::ArraySeries == t1
        @test @inferred(t1[:])::ArraySeries == t1
    end

    @testset "ArrayTable" begin
        # Flat ArrayTable
        @test @inferred(Table([1 4; 2 5; 3 6])) isa ArrayTable{<:Matrix}

        t2 = Table([1 4; 2 5; 3 6])

        @test @inferred(indices(t2)) === (Base.OneTo(3), Base.OneTo(2))
        @test @inferred(t2[2,1]) === 2
        @test @inferred(t2[:,1]) == Series([1,2,3])
        @test @inferred(t2[2,:]) == Series([2,5])
        @test @inferred(t2[:,:]) == t2

        # Nested ArrayTable
        #@test @inferred(Table([[1,2,3],[4,5,6]])) isa ArrayTable{<:Vector}

        t3 = Table([[1,2,3],[4,5,6]])

        @test @inferred(indices(t3)) === (Base.OneTo(3), Base.OneTo(2))
        @test @inferred(t3[2,1]) === 2
        @test @inferred(t3[:,1]) == Series([1,2,3])
        @test @inferred(t3[2,:]) == Series([2,5])
        @test @inferred(t3[:,:]) == t2

        # With other inner types
        @test_broken @inferred(Table([(:a=>1, :b=>2, :c=>3), (:a=>4, :b=>5, :c=>6)])) isa ArrayTable{<:Vector}
    end
end
