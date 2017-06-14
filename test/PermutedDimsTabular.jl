@testset "PermutedDimsTabular" begin
    t = Table(l"a" => [1,2,3], l"b" => [true, false, true])

    @test t.' isa Tabulars.PermutedDimsTabular
    t2 = t.'
    @test @inferred(t2[l"b", 2]) == false
    @test_broken (t2[:b, 2] = true; t[2, :b] == true)
end
