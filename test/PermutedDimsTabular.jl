@testset "PermutedDimsTabular" begin
    t = DictTable(:a => [1,2,3], :b => [true, false, true])

    @test t.' isa Tabulars.PermutedDimsTabular
    @test (t.')[:b, 2] == false
    @test (t2 = t.'; t2[:b, 2] = true; t[2, :b] == true)

end
