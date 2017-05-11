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
@inline get_tuple_element(data::Tuple{Vararg{Pair}}, i) = _get_tuple_element(i, data...)
@inline function _get_tuple_element(i, d::Pair)
    if i == d.first
        return d.second
    else
        error("Can't find index $i")
    end
end
@inline function _get_tuple_element(i, d::Pair, ds::Pair...)
    if i == d.first
        return d.second
    else
        return _get_tuple_element(i, ds...)
    end
end

# scalar getindex
@propagate_inbounds function getindex(t::TupleTabular{1}, i)
    return get_tuple_element(t.data, i)
end

@propagate_inbounds function getindex(t::TupleTabular, inds...)
    (other_inds, this_ind) = pop(inds)
    return get_tuple_element(t.data, this_ind)[other_inds...]
end

# slice getindex
@propagate_inbounds function getindex(t::TupleTabular{1}, ::Colon)
    return t
end

@propagate_inbounds function getindex(t::TupleTabular, ::Colon, other_inds...)
    @propagate_inbounds function getter(x)
        return x[other_inds...]
    end
    x = _map(getter, t.data)

end

# fancy getindex
@propagate_inbounds function getindex(t::TupleTabular{1}, inds::Tuple)
    @propagate_inbounds function fetcher(x)
        return t[x]
    end
    return TupleSeries(_map(fetcher, inds))
end

@propagate_inbounds function getindex(t::TupleTabular, this_inds::Tuple, other_inds...)
    @propagate_inbounds function getter(x)
        return x[other_inds...]
    end
    @propagate_inbounds function fetcher(x)
        return get_tuple_element(t.data, x)
    end
    return _map(getter, _map(fetcher, inds))
end


# setindex!
@propagate_inbounds function setindex!(t::TupleTabular{1}, value, i)
    error("TupleSeries is immutable")
end

@propagate_inbounds function setindex!(t::TupleTabular{N}, value, inds::Vararg{Any, N}) where {N}
    (other_inds, this_ind) = pop(inds)
    t.dict[this_ind][other_inds...] = value
    return t
end
