@testset "ArrayTabular" begin
    @testset "ArraySeries" begin
        @test @inferred(Series([2,3,4,5])) isa Series

        s = Series([2,3,4,5])

        @test @inferred(indices(s)) === (Base.OneTo(4),)

        @test @inferred(s[3]) == 4
        @test_throws Exception s[1,2]
        @test @inferred(s[[3,4]]) == Series(Dict(3=>4, 4=>5))
        @test @inferred(s[:])::Series == s
        
        # @test @inferred(Series((2,3,4,5))) isa ArraySeries
    end

    @testset "ArrayTable" begin
        # Flat ArrayTable
        @test @inferred(Table([1 4; 2 5; 3 6])) isa Table{Matrix{Int}}
        t2 = Table([1 4; 2 5; 3 6])
        @test @inferred(indices(t2)) === (Base.OneTo(3), Base.OneTo(2))
        @test @inferred(t2[2,1]) === 2
        @test @inferred(t2[2,[1,2]]) == Series([2,5])
        @test @inferred(t2[2,:]) == Series([2,5])
        @test @inferred(t2[[1,2,3],1]) == Series([1,2,3])
        @test @inferred(t2[[1,2,3],[1,2]]) == t2
        @test @inferred(t2[[1,2,3],:]) == t2
        @test @inferred(t2[:,1]) == Series([1,2,3])
        @test @inferred(t2[:,[1,2]]) == t2
        @test @inferred(t2[:,:]) == t2

        # Nested ArrayTable
        @test @inferred(Table([[1,2,3],[4,5,6]])) isa Table{<:Vector}
        t3 = Table([[1,2,3],[4,5,6]])
        @test @inferred(indices(t3)) === (Base.OneTo(3), Base.OneTo(2))
        @test @inferred(t3[2,1]) === 2
        @test @inferred(t3[2,[1,2]]) == Series([2,5])
        @test @inferred(t3[:,1]) == Series([1,2,3])
        @test @inferred(t3[2,:]) == Series([2,5])
        @test @inferred(t3[:,[1,2]]) == t3
        @test @inferred(t3[:,:]) == t3

        # With other inner types
        # Dict inner storage
        @test @inferred(Table([Dict(:a=>1, :b=>2, :c=>3), Dict(:a=>4, :b=>5, :c=>6)])) isa Table{<:Vector}
        t4 = Table([Dict(:a=>1, :b=>2, :c=>3), Dict(:a=>4, :b=>5, :c=>6)])
        @test @inferred(indices(t4))[1] isa Base.KeyIterator # do a more specific test?
        @test @inferred(indices(t4))[2] === Base.OneTo(2)
        @test @inferred(t4[:b,1]) === 2
        @test @inferred(t4[:,1]) == Series(Dict(:a=>1, :b=>2, :c=>3))
        @test @inferred(t4[:b,:]) == Series([2,5])
        @test @inferred(t4[:,:]) == t4

        # TupleTabular inner type
        @test @inferred(Table([(l"a"=>1, l"b"=>2.0, l"c"=>3f0), (l"a"=>4, l"b"=>5.0, l"c"=>6f0)])) isa Table{<:Vector}
        t5 = Table([(l"a"=>1, l"b"=>2.0, l"c"=>3f0), (l"a"=>4, l"b"=>5.0, l"c"=>6f0)])
        @test @inferred(indices(t5)) === ((l"a", l"b", l"c"), Base.OneTo(2))
        @test @inferred(t5[l"b",1]) === 2.0
        @test @inferred(t5[:,1]) == Series(l"a"=>1, l"b"=>2.0, l"c"=>3f0)
        @test @inferred(t5[l"b",:]) == Series([2.0,5.0])
        @test @inferred(t5[:,:]) == t5

        # StructTabular inner type
        @test @inferred(Table([1+2im, 3+4im])) isa Table{Vector{Complex{Int}}}
        t6 = Table([1+2im, 3+4im])
        @test @inferred(indices(t6)) === ((l"re", l"im"), Base.OneTo(2))
        @test @inferred(t6[l"im",1]) === 2
        @test @inferred(t6[:,1]) == Series(1+2im)
        if VERSION <= v"0.6.0-rc3.0"
            # Inference works at REPL but not in test
            @test t6[l"im",:] == Series([2, 4])
            #@test_broken @inferred(t6[l"im",:]) == Series([2, 4])
        else
            @test @inferred(t6[l"im",:]) == Series([2, 4])
        end
        
        if VERSION <= v"0.6.0-rc3.0"
            # Inference works at REPL but not in test
            @test t6[:,:] == t6
            #@test_broken @inferred(t6[:,:]) == t6
        else
            @test @inferred(t6[:,:]) == t6
        end

        # # Tuples become arrays...
        # @test @inferred(Table(([1,2,3],[4,5,6]))) isa ArrayTable{<:Vector}
        # @test @inferred(Table(((1,2,3),(4,5,6)))) isa ArrayTable{<:Vector{<:ArraySeries}}
    end
end
