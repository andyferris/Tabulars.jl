@testset "show" begin
    @testset "balance_widths" begin
        @test Tabulars.balance_widths(10, 10, 40) === (10, 10)
        @test Tabulars.balance_widths(20, 20, 40) === (20, 20)
        @test Tabulars.balance_widths(30, 20, 40) === (20, 20)
        @test Tabulars.balance_widths(30, 30, 40) === (20, 20)
        @test Tabulars.balance_widths(30, 30, 40) === (20, 20)
        @test Tabulars.balance_widths(10, 30, 40) === (10, 30)
        @test Tabulars.balance_widths(30, 10, 40) === (30, 10)
    end

    @testset "balance_widths!" begin
        widths = [10, 10, 10, 10]
        @test (n = Tabulars.balance_widths!(widths, 4, 80); (n === 4) & (widths == [10, 10, 10, 10]))

        widths = [18, 18, 18, 18]
        @test (n = Tabulars.balance_widths!(widths, 4, 80); (n === 4) & (widths == [18, 18, 18, 18]))

        widths = [30, 30, 30, 30]
        @test (n = Tabulars.balance_widths!(widths, 4, 80); (n === 4) & (widths == [18, 18, 18, 18]))

        widths = [100, 10, 10, 10]
        @test (n = Tabulars.balance_widths!(widths, 4, 80); (n === 4) & (widths == [42, 10, 10, 10]))

        widths = [10, 100, 10, 10]
        @test (n = Tabulars.balance_widths!(widths, 4, 80); (n === 4) & (widths == [10, 42, 10, 10]))

        widths = [10, 10, 100, 10]
        @test (n = Tabulars.balance_widths!(widths, 4, 80); (n === 4) & (widths == [10, 10, 42, 10]))

        widths = [10, 10, 10, 100]
        @test (n = Tabulars.balance_widths!(widths, 4, 80); (n === 4) & (widths == [10, 10, 10, 42]))

        widths = fill(10, 10)
        @test (n = Tabulars.balance_widths!(widths, 10, 80); (n === 7) & (widths == [10, 10, 10, 10, 10, 10, 10, 10, 10, 10]))


    end
end
