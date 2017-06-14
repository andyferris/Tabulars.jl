module Tabulars

import Base: @pure, @propagate_inbounds, @_pure_meta, @_inline_meta, 
    @_propagate_inbounds_meta, get, getindex, setindex!, view, indices, size, length, tail, 
    summary, show, length, start, next, done, transpose, permutedims, ndims, show, print,
    endof

import Base: ==

export IndexError
export AbstractTabular, AbstractTable, AbstractSeries
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
include("indexing.jl")
include("PermutedDimsTabular.jl")
include("iteration.jl")
include("generic.jl")
include("show.jl")

end # module

# endof (endof(series), endof(table, i))
# didn't throw for non-unique indices of tuples
# order of indices is weird
# fancy getindex matrix table

# TODO LIST
#
# Basic indexing interface:
# * slice/fancy setindex!
# * setindex! works when inner type is immutable
# * setindex for immutable types, and related trait?
# * views
# * toindices() (to support views, more generic indexing and setindex!)
#
# New containers
# * StructTable
# * sort-based Associative or Tabular (instead of hash-based Dict everywhere)
# * TupleTabular (move current TupleTabular -> TypedTabular)
# * GroupedTabular - nested indexing (non-Cartesian)
# * SparseTabular - list of indices => values, with default value?
# 
# Features / methods
# * rows(table), cols(table)
# * map (maybe map(series), map(rows(table)), map(cols(table))
# * reduce / reducedim / reducerows / reducecols
# * filter / filterrows / filtercols
# * groupby
# * indexable values (accelerated find/search)
#
# Performance issues
# * Long TupleTabulars (generated functions?)
# * Fast constructors (elide sameindices, maybe use @boundscheck?)
# * Avoid wrapping and reallocating data upon construction, where possible