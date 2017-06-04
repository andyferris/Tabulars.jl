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
        show(io, MIME"text/plain"(), Series(l"a"=>1, l"b"=>2))
        @test String(io) == """
            2-element Series:
             a │ 1
             b │ 2"""

        io = IOBuffer()
        show(io, Series(zeros(100)))
        @test String(io) == """
            100-element Series:
             1  │ 0.0
             2  │ 0.0
             3  │ 0.0
             4  │ 0.0
             5  │ 0.0
             6  │ 0.0
             7  │ 0.0
             8  │ 0.0
             9  │ 0.0
             10 │ 0.0
             11 │ 0.0
             12 │ 0.0
             13 │ 0.0
             14 │ 0.0
             15 │ 0.0
             16 │ 0.0
             17 │ 0.0
             18 │ 0.0
             19 │ 0.0
             ⋮  │  ⋮"""

        io = IOBuffer()
        show(io, Series("This index is really, really long, in fact it's rather too long" => "The value is shorter by far"))
        @test String(io) == """
            1-element Series:
             This index is really, really long, in fact it's … │ The value is shorter by far"""
    end

    @testset "show Table" begin
        io = IOBuffer()
        show(io, MIME"text/plain"(), Table(l"a"=>[1,2,], l"b"=>[3,4]))
        @test String(io) == """
            2×2 Table:
                 a  b
               ┌─────
             1 │ 1  3
             2 │ 2  4"""

        io = IOBuffer()
        show(io, Table(zeros(100,100)))
        @test String(io) == """
            100×100 Table:
                  1    2    3    4    5    6    7    8    9    10   11   12   13   14   ⋯
                ┌────────────────────────────────────────────────────────────────────────
             1  │ 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  ⋯
             2  │ 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  ⋯
             3  │ 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  ⋯
             4  │ 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  ⋯
             5  │ 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  ⋯
             6  │ 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  ⋯
             7  │ 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  ⋯
             8  │ 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  ⋯
             9  │ 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  ⋯
             10 │ 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  ⋯
             11 │ 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  ⋯
             12 │ 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  ⋯
             13 │ 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  ⋯
             14 │ 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  ⋯
             15 │ 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  ⋯
             16 │ 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  ⋯
             17 │ 0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  0.0  ⋯
             ⋮  │  ⋮    ⋮    ⋮    ⋮    ⋮    ⋮    ⋮    ⋮    ⋮    ⋮    ⋮    ⋮    ⋮    ⋮   ⋱"""

        io = IOBuffer()
        show(io, Table(l"Another cute string" => ["Another cute value"], l"This index is really, really long, in fact it's rather too much too long"=>["The value is shorter by far"]))
        @test String(io) == """
            1×2 Table:
                 Another cute string  This index is really, really long, in fact it's rathe…
               ┌────────────────────────────────────────────────────────────────────────────
             1 │ Another cute value   The value is shorter by far"""

    end
end
