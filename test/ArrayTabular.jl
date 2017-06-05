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
        @test @inferred(Table([[1,2,3],[4,5,6]])) isa ArrayTable{<:Vector}
        t3 = Table([[1,2,3],[4,5,6]])
        @test @inferred(indices(t3)) === (Base.OneTo(3), Base.OneTo(2))
        @test @inferred(t3[2,1]) === 2
        @test @inferred(t3[:,1]) == Series([1,2,3])
        @test @inferred(t3[2,:]) == Series([2,5])
        @test @inferred(t3[:,:]) == t3

        # With other inner types
        # DictTabular inner type
        @test @inferred(Table([(:a=>1, :b=>2, :c=>3), (:a=>4, :b=>5, :c=>6)])) isa ArrayTable{<:Vector}
        t4 = Table([(:a=>1, :b=>2, :c=>3), (:a=>4, :b=>5, :c=>6)])
        @test @inferred(indices(t4))[1] isa Base.KeyIterator # do a more specific test?
        @test @inferred(indices(t4))[2] === Base.OneTo(2)
        @test @inferred(t4[:b,1]) === 2
        @test @inferred(t4[:,1]) == Series(:a=>1, :b=>2, :c=>3)
        @test @inferred(t4[:b,:]) == Series([2,5])
        @test @inferred(t4[:,:]) == t4

        # TupleTabular inner type
        @test @inferred(Table([(l"a"=>1, l"b"=>2.0, l"c"=>3f0), (l"a"=>4, l"b"=>5.0, l"c"=>6f0)])) isa ArrayTable{<:Vector}
        t5 = Table([(l"a"=>1, l"b"=>2.0, l"c"=>3f0), (l"a"=>4, l"b"=>5.0, l"c"=>6f0)])
        @test @inferred(indices(t5)) === ((l"a", l"b", l"c"), Base.OneTo(2))
        @test @inferred(t5[l"b",1]) === 2.0
        @test @inferred(t5[:,1]) == Series(l"a"=>1, l"b"=>2.0, l"c"=>3f0)
        @test @inferred(t5[l"b",:]) == Series([2.0,5.0])
        @test @inferred(t5[:,:]) == t5

        # StructTabular inner type
        @test @inferred(Table([1+2im, 3+4im])) isa ArrayTable{<:Vector}
        t6 = Table([1+2im, 3+4im])
        @test @inferred(indices(t6)) === ((l"re", l"im"), Base.OneTo(2))
        @test @inferred(t6[l"im",1]) === 2
        @test @inferred(t6[:,1]) === Series(1+2im)
        @test @inferred(t6[l"im",:]) == Series([2, 4])
        @test @inferred(t6[:,:]) == t6
    end
end
