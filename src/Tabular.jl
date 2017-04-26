"""
    Tabular{N}(index, data)
    Tabular{N}(i1 => data1, i2 => data2, ...)

Constructs a `N`-dimensional `Tabular` object of nested `N-1`-dimensional data elements and
their associated indices.

See `AbstractTabular`, `Table` and `DataSet`.
"""
struct Tabular{N, Index, Data}
    index::Index
    data::Data
end

Tabular{N}(index, data) = Tabular{N, typeof(index), typeof(data)}(index, data)
Tabular{N}(pairs::Pair...) = Tabular{N}(map(first, pairs), map(last, pairs))

# Aliases for common sizes
const Table{Columns, Data} = Tabular{2, Columns, Data}
const DataSet{Index, Data} = Tabular{1, Index, Data}

# indices
@inline indices(t::Tabular{0}) = ()
@inline indices(t::Tabular{1}) = (t.index)
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

@propagate_inbounds function getindex(t::Tabular{1}, value, i)
    t.data[findindex(t.index, i)] = value
end

@propagate_inbounds function getindex(t::Tabular{N}, value, inds::Vararg{Any, N}) where {N}
    (other_inds, this_ind) = pop(inds)
    t.data[findindex(t.index, this_ind)][other_inds...] = value
end
