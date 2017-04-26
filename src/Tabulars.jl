module Tabulars

import Base: @pure, @propagate_inbounds, @_pure_meta, @_inline_meta, @_propagate_inbounds_meta,
    getindex, setindex!, indices, size, tail, summary, show

include("util.jl")
include("AbstractTabular.jl")
include("Tabular.jl")
include("findindex.jl")

end # module
