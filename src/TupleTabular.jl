"""
    TupleTabular{N}(i₁ => data₁, i₂ => data₂, ...)

Constructs an immutable `Tabular` data structure which stores data as a tuple of
`Pair`s between indices and elements (for `N == 1`) or nested containers (for
`N > 1`). Efficient for small numbers of indices (more than 14 is a bad idea).

This type is particularly useful for storing different data types (e.g. a
`Table` with columns of different element types). If the indices have distinct
types, then the compiler can deduce the return type from `getindex`, etc, at
compile-time. To ensure optimial compilation, ensure that `==` is a pure
function for the index values.
"""
struct TupleTabular{N, Data <: Tuple{Vararg{Pair}}} <: Tabular{N}
    data::Data

    function TupleTabular{N, Data}(d::Data) where {N, Data <: Tuple{Vararg{Pair}}}
        if N !== 1
            same_indices(last.(d))
        end
        new{N, Data}(d)
    end
end

@inline TupleTabular{N}(data::Data) where {N, Data <: Tuple{Vararg{Pair}}} = TupleTabular{N, Data}(data)
@inline TupleTabular{N}(data::Pair...) where {N} = TupleTabular{N}(data)

# Aliases for common sizes
const TupleTable{Data <: Tuple{Vararg{Pair}}} = TupleTabular{2, Data}
const TupleSeries{Data <: Tuple{Vararg{Pair}}} = TupleTabular{1, Data}

# indices
@inline indices(t::TupleTabular{1}) = (first.(t.data),)
@inline indices(t::TupleTabular) = (indices(t.data[1].second)..., first.(t.data))

# Get the tuple element
@inline get_tuple_value(data::Tuple{Vararg{Pair}}, i) = _get_tuple_value(i, data...)
@inline function _get_tuple_value(i, d::Pair)
    if i == d.first
        return d.second
    else
        error("Can't find index $i")
    end
end
@inline function _get_tuple_value(i, d::Pair, ds::Pair...)
    if i == d.first
        return d.second
    else
        return _get_tuple_value(i, ds...)
    end
end

# Get the tuple pair
@inline get_tuple_pair(data::Tuple{Vararg{Pair}}, i) = _get_tuple_pair(i, data...)
@inline function _get_tuple_pair(i, d::Pair)
    if i == d.first
        return d
    else
        error("Can't find index $i")
    end
end
@inline function _get_tuple_pair(i, d::Pair, ds::Pair...)
    if i == d.first
        return d
    else
        return _get_tuple_pair(i, ds...)
    end
end

# getindex
@propagate_inbounds function getindex(t::TupleSeries, i)
    get_tuple_value(t.data, i)
end

@propagate_inbounds function getindex(t::TupleSeries, ::Colon)
    t
end

@propagate_inbounds function getindex(t::TupleSeries, inds::Tuple)
    TupleSeries(_map(i -> get_tuple_pair(t.data, i), inds))
end

@propagate_inbounds function getindex(t::TupleTable, other_inds, i)
    get_tuple_value(t.data, i)[other_inds]
end

@propagate_inbounds function getindex(t::TupleTable, other_inds, ::Colon)
    data = _map(kv -> Pair(kv.first, kv.second[other_inds]), t.data)
    if aretype(Series, _map(first, data))
        TupleTable(data)
    else
        TupleSeries(data)
    end
end

@propagate_inbounds function getindex(t::TupleTable, other_inds, this_inds::Tuple)
    data = _map(i -> (kv = get_tuple_pair(t.data, i); Pair(kv.first, kv.second[other_inds])), this_inds)
    if aretype(Series, _map(first, data))
        TupleTable(data)
    else
        TupleSeries(data)
    end
end


#=
@propagate_inbounds function getindex(t::TupleTabular{N}, inds::Vararg{Any, N}) where {N}
    (other_inds, this_ind) = pop(inds)
    get_tuple_element(t.data, this_ind)[other_inds...]
end

# setindex!
@propagate_inbounds function setindex!(t::TupleTabular{1}, value, i)
    error("TupleSeries is immutable")
end

@propagate_inbounds function setindex!(t::TupleTabular{N}, value, inds::Vararg{Any, N}) where {N}
    (other_inds, this_ind) = pop(inds)
    t.dict[this_ind][other_inds...] = value
end
=#
