@testset "SubTabular" begin
    @testset "Views of Series" begin
        s = Series([1,2,3])
        
        @test @inferred(view(s, 2:3))::SubSeries == Series(2=>2,3=>3)
        s2 = view(s, 2:3)
        @test @inferred(s2[2]) === 2
        @test @inferred(s2[2:3]) == s2
        @test @inferred(s2[:]) == s2

        @test @inferred(view(s, :))::SubSeries == s
        s3 = view(s, :)
        @test @inferred(s3[2]) === 2
        @test @inferred(s3[2:3]) == s2
        @test @inferred(s3[:]) == s

        # Views of SubSeries
        @test @inferred(view(view(s, :), :)) == s
        @test @inferred(view(view(s, 2:3), :)) == Series(2=>2,3=>3)
        @test @inferred(view(view(s, :), 2:3)) == Series(2=>2,3=>3)
        @test @inferred(view(view(s, 2:3), 2:3)) == Series(2=>2,3=>3)
    end

    @testset "Views of Table" begin
        t = Table([1 2 3; 4 5 6; 7 8 9; 10 11 12])
        
        @test @inferred(view(t, 2:4, 3))::SubSeries == Series(2=>6,3=>9,4=>12)
        s2 = view(t, 2:4, 3)
        @test @inferred(s2[2]) === 6
        @test @inferred(s2[2:4]) == s2
        @test @inferred(s2[:]) == s2

        @test @inferred(view(t, 4, 2:3))::SubSeries == Series(2=>11,3=>12)
        s3 = view(t, 4, 2:3)
        @test @inferred(s3[2]) === 11
        @test @inferred(s3[2:3]) == s3
        @test @inferred(s3[:]) == s3

        @test @inferred(view(t, :, 3))::SubSeries == Series(1=>3,2=>6,3=>9,4=>12)
        s4 = view(t, :, 3)
        @test @inferred(s4[2]) === 6
        @test @inferred(s4[2:4]) == s2
        @test @inferred(s4[:]) == s4

        @test @inferred(view(t, 4, :))::SubSeries == Series(1=>10,2=>11,3=>12)
        s5 = view(t, 4, :)
        @test @inferred(s5[2]) === 11
        @test @inferred(s5[2:3]) == s3
        @test @inferred(s5[:]) == s5

        @test @inferred(view(t, 2:4, :))::SubTable == Table([(2=>4, 3=>7, 4=>10), (2=>5, 3=>8, 4=>11), (2=>6, 3=>9, 4=>12)])
        t2 = view(t, 2:4, :)
        @test @inferred(t2[4,3]) === 12
        @test @inferred(t2[:,3]) == s2
        @test @inferred(t2[2:4,3]) == s2
        @test @inferred(t2[4,:]) == t[4,:]
        @test @inferred(t2[4,2:3]) == s3
        @test @inferred(t2[:,1:3]) == t2
        @test @inferred(t2[2:4,1:3]) == t2
        @test @inferred(t2[2:4,:]) == t2
        @test @inferred(t2[:,:]) == t2
        
        @test @inferred(view(t, :, 2:3))::SubTable == Table(2=>[2,5,8,11], 3=>[3,6,9,12])
        @test @inferred(view(t, 2:4, 2:3))::SubTable == Table(2=>(2=>5, 3=>8, 4=>11), 3=>(2=>6, 3=>9, 4=>12))
        @test @inferred(view(t, :, :))::SubTable == t
        
        # views of SubTabulars
        @test @inferred(view(view(t, 2:4, 3), 2:4))::SubSeries == Series(2=>6,3=>9,4=>12)
        @test @inferred(view(view(t, :, 3), 2:4))::SubSeries == Series(2=>6,3=>9,4=>12)
        @test @inferred(view(view(t, 2:4, 3), :))::SubSeries == Series(2=>6,3=>9,4=>12)
        @test @inferred(view(view(t, :, 3), :))::SubSeries == Series(1=>3,2=>6,3=>9,4=>12)
        
        @test @inferred(view(view(t, 4, 2:3), 2:3))::SubSeries == Series(2=>11,3=>12)
        @test @inferred(view(view(t, 4, :), 2:3))::SubSeries == Series(2=>11,3=>12)
        @test @inferred(view(view(t, 4, 2:3), :))::SubSeries == Series(2=>11,3=>12)
        @test @inferred(view(view(t, 4, :), :))::SubSeries == Series(1=>10,2=>11,3=>12)

        @test @inferred(view(view(t, 2:4, :), 2:4, 3))::SubSeries == Series(2=>6,3=>9,4=>12)
        @test @inferred(view(view(t, :, 2:3), 4, 2:3))::SubSeries == Series(2=>11,3=>12)
        @test @inferred(view(view(t, 2:4, :), 2:4, :))::SubTable == Table([(2=>4, 3=>7, 4=>10), (2=>5, 3=>8, 4=>11), (2=>6, 3=>9, 4=>12)])
        @test @inferred(view(view(t, :, 2:3), :, 2:3))::SubTable == Table(2=>[2,5,8,11], 3=>[3,6,9,12])
        @test @inferred(view(view(t, 2:4, 2:3), 2:4, 2:3))::SubTable == Table(2=>(2=>5, 3=>8, 4=>11), 3=>(2=>6, 3=>9, 4=>12))
        
        @test @inferred(view(view(t, 2:4, :), :, 3))::SubSeries == Series(2=>6,3=>9,4=>12)
        @test @inferred(view(view(t, :, 2:3), 4, :))::SubSeries == Series(2=>11,3=>12)
        @test @inferred(view(view(t, 2:4, :), :, :))::SubTable == Table([(2=>4, 3=>7, 4=>10), (2=>5, 3=>8, 4=>11), (2=>6, 3=>9, 4=>12)])
        @test @inferred(view(view(t, :, 2:3), :, :))::SubTable == Table(2=>[2,5,8,11], 3=>[3,6,9,12])
        @test @inferred(view(view(t, 2:4, 2:3), :, :))::SubTable == Table(2=>(2=>5, 3=>8, 4=>11), 3=>(2=>6, 3=>9, 4=>12))
        
        @test @inferred(view(view(t, :, :), 2:4, 3))::SubSeries == Series(2=>6,3=>9,4=>12)
        @test @inferred(view(view(t, :, :), 4, 2:3))::SubSeries == Series(2=>11,3=>12)
        @test @inferred(view(view(t, :, :), :, 3))::SubSeries == Series(1=>3,2=>6,3=>9,4=>12)
        @test @inferred(view(view(t, :, :), 4, :))::SubSeries == Series(1=>10,2=>11,3=>12)
        @test @inferred(view(view(t, :, :), 2:4, :))::SubTable == Table([(2=>4, 3=>7, 4=>10), (2=>5, 3=>8, 4=>11), (2=>6, 3=>9, 4=>12)])
        @test @inferred(view(view(t, :, :), :, 2:3))::SubTable == Table(2=>[2,5,8,11], 3=>[3,6,9,12])
        @test @inferred(view(view(t, :, :), 2:4, 2:3))::SubTable == Table(2=>(2=>5, 3=>8, 4=>11), 3=>(2=>6, 3=>9, 4=>12))
        @test @inferred(view(view(t, :, :), :, :))::SubTable == t
    end
end