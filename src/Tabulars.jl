module Tabulars

import Base: @pure, @propagate_inbounds, @_pure_meta, @_inline_meta, @_propagate_inbounds_meta,
    getindex, setindex!, indices, size, tail, summary, show, length, start, next, done,
    transpose, permutedims, ndims, show, print

import Base: ==

export IndexError
#export AbstractTabular, AbstractTable, AbstractDataSet
export Tabular, Table, Series
export DictTabular, DictTable, DictSeries
export ArrayTabular, ArrayTable, ArraySeries
export TupleTabular, TupleTable, TupleSeries
export StructSeries
export PermutedDimsTabular, PermutedDimsTable, PermutedDimsSeries

export Label, @l_str

include("util.jl")
include("Label.jl")

include("Tabular.jl")
include("DictTabular.jl")
include("ArrayTabular.jl")
include("TupleTabular.jl")
include("StructTabular.jl")
include("PermutedDimsTabular.jl")

include("constructors.jl")
include("generic.jl")

#include("AbstractTabular.jl")
#include("findindex.jl")

include("show.jl")

end # module
