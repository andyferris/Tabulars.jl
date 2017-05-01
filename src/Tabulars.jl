module Tabulars

import Base: @pure, @propagate_inbounds, @_pure_meta, @_inline_meta, @_propagate_inbounds_meta,
    getindex, setindex!, indices, size, tail, summary, show, length, start, next, done,
    transpose, permutedims

#export AbstractTabular, AbstractTable, AbstractDataSet
export Tabular, Table, DataSet
export DictTabular, DictTable, DictDataSet
export ArrayTabular, ArrayTable, ArrayDataSet
export PermutedDimsTabular, PermutedDimsTable, PermutedDimsDataSet

include("util.jl")
include("Tabular.jl")
include("DictTabular.jl")
include("ArrayTabular.jl")
include("PermutedDimsTabular.jl")



#include("AbstractTabular.jl")
#include("findindex.jl")

end # module
