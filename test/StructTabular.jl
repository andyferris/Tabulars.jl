@testset "StructTabular" begin
    @testset "StructSeries" begin
        @test @inferred(Series(2+3im)) isa Series{Complex{Int}}
        # TODO @test_throws ErrorException Series(1)

        s = Series(2+3im)
        @test @inferred(s[l"re"]) === 2
        @test @inferred(s[l"im"]) === 3
        @test_throws Exception @inferred(s[l"bla"])

        @test @inferred(s[:]) == s
        @test @inferred(s[(l"re", l"im")]) === Series(l"re" => 2, l"im" => 3)
    end

    # Also covered in ArrayTabular tests...
    @testset "Tables with StructSeries as rows" begin
        @test @inferred(Table([1+2im, 3+4im])) isa Table{Vector{Complex{Int}}}

        t = Table([1+2im, 3+4im])

        @test @inferred(t[l"re", 1]) === 1
        @test @inferred(t[l"re", 2]) === 3
        @test @inferred(t[l"im", 1]) === 2
        @test @inferred(t[l"im", 2]) === 4

        @test @inferred(t[:, 1]) == Series(1+2im)
        @test @inferred(t[:, 2]) == Series(3+4im)
        if VERSION <= v"0.6.0-rc3.0"
            # Inference works at REPL but not in test
            @test t[l"re", :] == Series([1,3])
            #@test_broken @inferred(t[l"re", :]) == Series([1,3])
        else
            @test @inferred(t[l"re", :]) == Series([1,3])
        end
        if VERSION <= v"0.6.0-rc3.0"
            # Inference works at REPL but not in test
            @test t[l"im", :] == Series([2,4])
            #@test_broken @inferred(t[l"im", :]) == Series([2,4])
        else
            @test @inferred(t[l"im", :]) == Series([2,4])
        end

        @test @inferred(t[(l"re", l"im"), 1]) === Series(l"re" => 1, l"im" => 2)
        if VERSION <= v"0.6.0-rc3.0"
            # Inference works at REPL but not in test
            @test t[(l"re", l"im"), :] == t
            #@test_broken @inferred(t[(l"re", l"im"), :]) == t
        else
            @test @inferred(t[(l"re", l"im"), :]) == t
        end

        if VERSION <= v"0.6.0-rc3.0"
            # Inference works at REPL but not in test
            @test t[:, :] == t
            #@test_broken @inferred(t[:, :]) == t
        else
            @test @inferred(t[:, :]) == t
        end
    end

    @testset "StructTables" begin
        # structs of structs
        @eval struct Foo{A,B}
            a::A
            b::B
        end

        data = Foo(1+2im, 3.0+4.0im)
        @test @inferred(Table(data)) isa Table{<:Foo}
        t = Table(data)

        @test @inferred(t[l"re", l"a"]) === 1
        @test @inferred(t[l"im", l"a"]) === 2
        @test @inferred(t[l"re", l"b"]) === 3.0
        @test @inferred(t[l"im", l"b"]) === 4.0

        @test @inferred(t[:, l"b"]) == Series(3.0+4.0im)
        @test @inferred(t[l"re", :]) == Series(l"a" => 1, l"b" => 3.0)
        @test @inferred(t[:, :]) == t
    end
end
