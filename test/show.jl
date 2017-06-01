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
        widths = [22, 22, 22, 22]
        @test (n = Tabulars.balance_widths!(widths, 4, 100); (n === 4) & (widths == [22, 22, 22, 22]))

        widths = [23, 23, 23, 23]
        @test (n = Tabulars.balance_widths!(widths, 4, 100); (n === 4) & (widths == [23, 23, 23, 23]))

        widths = [24, 24, 24, 24]
        @test (n = Tabulars.balance_widths!(widths, 4, 100); (n === 4) & (widths == [23, 23, 23, 23]))

        widths = [100, 10, 10, 10]
        @test (n = Tabulars.balance_widths!(widths, 4, 80); (n === 4) & (widths == [42, 10, 10, 10]))

        widths = [10, 100, 10, 10]
        @test (n = Tabulars.balance_widths!(widths, 4, 80); (n === 4) & (widths == [10, 42, 10, 10]))

        widths = [10, 10, 100, 10]
        @test (n = Tabulars.balance_widths!(widths, 4, 80); (n === 4) & (widths == [10, 10, 42, 10]))

        widths = [10, 10, 10, 100]
        @test (n = Tabulars.balance_widths!(widths, 4, 80); (n === 4) & (widths == [10, 10, 10, 42]))

        widths = fill(10, 10)
        @test (n = Tabulars.balance_widths!(widths, 10, 80); (n === 6) & (widths == [10, 10, 10, 10, 10, 10, 10, 10, 10, 10]))
    end

    @testset "show Series" begin
        io = IOBuffer()
        show(io, MIME"text/plain"(), Series("a"=>1, "b"=>2))
        @test String(io) == """
            2-element Series:
             b │ 2
             a │ 1"""

        # TODO more tests for truncation...
    end

    @testset "show Table" begin
    io = IOBuffer()
    show(io, MIME"text/plain"(), Table("a"=>[1,2,], "b"=>[3,4]))
    @test String(io) == """
    2×2 Table:
         b  a
       ┌─────
     1 │ 3  1
     2 │ 4  2"""

    # TODO more tests for truncation...
    end
end
