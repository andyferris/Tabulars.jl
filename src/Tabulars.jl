module Tabulars

import Base: @pure, @propagate_inbounds, @_pure_meta, @_inline_meta, @_propagate_inbounds_meta,
    getindex, setindex!, indices, size, tail, summary, show, length, start, next, done,
    transpose, permutedims, ndims

#export AbstractTabular, AbstractTable, AbstractDataSet
export Tabular, Table, Series
export DictTabular, DictTable, DictSeries
export ArrayTabular, ArrayTable, ArraySeries
export PermutedDimsTabular, PermutedDimsTable, PermutedDimsSeries

include("util.jl")
include("Tabular.jl")
include("DictTabular.jl")
include("ArrayTabular.jl")
include("PermutedDimsTabular.jl")



#include("AbstractTabular.jl")
#include("findindex.jl")

end # module
