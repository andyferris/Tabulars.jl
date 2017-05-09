"""
    Tabular{N}

`Tabular{N}`s are flexible, `N`-dimensional storage containers.

Objects of this abstract type can be seen as an extension (or combination) of both
`AbstractArray` and `Associative`. An `Tabular{N}` object behaves as a generic
mapping from `N` indices to it's elements, stored in a "Cartesian".

Unlike `AbstractArray`, no assumptions about the indices or element type is made - excepting
that the indices for a given dimension must be unique, and amongst dimensions they are
"Cartesian" (e.g. a 2D tabular object must be rectangular in shape, not a generally nested
or ragged array).

The `Tabular{N}` interface requires the following functions:

 - `indices(tabular)` returns a length-`N` tuple of the indices for each dimension.
 - `getindex(tabular, inds...)` fetches an element given the `N` indices.
 - `setindex!(tabular, value, inds...)` sets an element to `value` given the `N` indices.
"""
abstract type Tabular{N}; end

const Table = Tabular{2}
const Series = Tabular{1}

ndims(t::Tabular{N}) where {N} = N
ndims(t::Type{Tabular{N}}) where {N} = N

@inline size(t::Tabular) = map(length, indices(t))

function summary(t::Tabular)
    string(join(size(t), "×"), " ", typeof(t).name.name)
end

"""
    TabularIndex

An abstract type that represents a collection of indices of a tabular object.
Each subtype of `Tabular` may define a corresponding `TabularIndex`, which will
be used internally to construct new tabular objects during indexing and other
operations.
"""
abstract type TabularIndex; end

#=

"""
    Tabular{N}(index, data)
    Tabular{N}(i1 => data1, i2 => data2, ...)

Constructs a `N`-dimensional `Tabular` object of nested `N-1`-dimensional data elements and
their associated indices.

See `AbstractTabular`, `Table` and `DataSet`.
"""
struct Tabular{N, Index, Data} <: AbstractTabular{N}
    index::Index
    data::Data
end

Tabular{N}(index, data) where {N} = Tabular{N, typeof(index), typeof(data)}(index, data)
Tabular{N}(pairs::Pair...) where {N} = Tabular{N}(map(first, pairs), map(last, pairs))

# Aliases for common sizes
const Table{Columns, Data} = Tabular{2, Columns, Data}
const Series{Index, Data} = Tabular{1, Index, Data}

# indices
@inline indices(t::Tabular{0}) = ()
@inline indices(t::Tabular{1}) = (t.index,)
@inline indices(t::Tabular) = (indices(t.data)..., t.index)

# getindex
@inline getindex(t::Tabular{0}) = t.data[] # data should always be a collection...

@propagate_inbounds function getindex(t::Tabular{1}, i)
    t.data[findindex(t.index, i)]
end

@propagate_inbounds function getindex(t::Tabular{N}, inds::Vararg{Any, N}) where {N}
    (other_inds, this_ind) = pop(inds)
    t.data[findindex(t.index, this_ind)][other_inds...]
end

# setindex!
@inline setindex!(t::Tabular{0}, value) = t.data[] = value

@propagate_inbounds function setindex!(t::Tabular{1}, value, i)
    t.data[findindex(t.index, i)] = value
end

@propagate_inbounds function setindex!(t::Tabular{N}, value, inds::Vararg{Any, N}) where {N}
    (other_inds, this_ind) = pop(inds)
    t.data[findindex(t.index, this_ind)][other_inds...] = value
end

=#
