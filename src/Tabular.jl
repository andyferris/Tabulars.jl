"""
    AbstractTabular{N}
    AbstractSeries === AbstractTabular{1}
    AbstractTable === AbstractTabular{2}

`AbstractTabular{N}`s are flexible, `N`-dimensional storage wrappers, designed to provide 
a uniform interface for working with data in various (possibly nested) data structures.

Objects of this abstract type can be seen as an extension (or combination) of both
`AbstractArray` and `Associative`. An `AbstractTabular{N}` object behaves as a generic
mapping from `N` indices to it's elements..

Unlike `AbstractArray`, no assumptions about the indices or element type is made - excepting
that the indices for a given dimension must be unique, and amongst dimensions they are
"Cartesian" (e.g. a 2D tabular object must be rectangular in shape, not a generic nested
or ragged array).

The `AbstractTabular{N}` interface requires the following functions (WIP):

 - `indices(tabular)` returns a length-`N` tuple of the indices for each dimension.
 - `getindex(tabular, inds...)` fetches an element given the `N` indices.
 - `setindex!(tabular, value, inds...)` sets an element to `value` given the `N` indices.
"""
abstract type AbstractTabular{N}; end

const AbstractTable = AbstractTabular{2}
const AbstractSeries = AbstractTabular{1}

ndims(t::AbstractTabular{N}) where {N} = N
ndims(t::Type{<:AbstractTabular{N}}) where {N} = N

@inline size(t::AbstractTabular) = map(length, indices(t))
@inline size(t::AbstractTabular, i) = length(indices(t)[i])

function summary(t::AbstractSeries)
    string("s Tabular{$N}")
end

function summary(t::AbstractTable)
    string(join(size(t), "×"), " Table")
end

function summary(t::AbstractTabular{N}) where {N}
    string(join(size(t), "×"), " Tabular{$N}")
end


"""
    Series(data...)
    Table(data...)
    Tabular{N}(data...)
    
Wraps input `data` in a `Tabular` of the specified dimensionality.
Indexing behavior will depend on the data type, and assumes a nested
data access pattern. The immediate data container `data` is indexed by
the final index value, such that (like `Base.Array`) the data "closest"
in memory is represented by the first index, and "furthest" in memory
by the final index. By default, multidimensional arrays will preserve
their index order.

If you wish the indices applied in a different order, see `PermutedDimsTabular`
or consider using `transpose(table)` / `table'`.
"""
struct Tabular{N, D} <: AbstractTabular{N}
    data::D
end

const Table = Tabular{2}
const Series = Tabular{1}

@inline Tabular{N}(x::D) where {N,D} = Tabular{N,D}(x)
@inline Tabular{N}(x...) where {N} = Tabular{N}(x)
@inline Tabular{N}(x::Pair) where {N} = Tabular{N}((x,))

get(t::Tabular) = t.data
