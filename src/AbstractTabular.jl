"""
    AbstractTabular{N}

`AbstractTabular{N}`s are flexible, `N`-dimensional storage containers.

Objects of this abstract type can be seen as an extension (or combination) of both
`AbstractArray` and `Associative`. An `AbstractTabular{N}` object behaves as a generic
mapping from `N` indices to it's elements, stored in a "Cartesian".

Unlike `AbstractArray`, no assumptions about the indices or element type is made - excepting
that the indices for a given dimension must be unique, and amongst dimensions they are
"Cartesian" (e.g. a 2D tabular object must be rectangular in shape, not a generally nested
or ragged array).

The `AbstractTabular{N}` interface requires the following functions:

 - `indices(tabular)` returns a length-`N` tuple of the indices for each dimension.
 - `getindex(tabular, inds...)` fetches an element given the `N` indices.
 - `setindex!(tabular, value, inds...)` sets an element to `value` given the `N` indices.
"""
abstract type AbstractTabular{N}; end

const AbstractTable = AbstractTabular{2}
const AbstractSeries = AbstractTabular{1}

ndims(t::AbstractTabular{N}) where {N} = N
ndims(t::Type{AbstractTabular{N}}) where {N} = N

@inline size(t::AbstractTabular) = map(length, indices(t))

function summary(t::AbstractTabular)
    string(join(size(t), "×"), " ", typeof(t).name.name)
end
