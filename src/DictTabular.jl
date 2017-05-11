"""
    DictTabular{N}(dict)
    DictTabular{N}(data::Pair...)

Constructs a `Tabular` data structure
"""
struct DictTabular{N, D <: Associative} <: Tabular{N}
    dict::D

    function DictTabular{N, D}(d::D) where {N, D <: Associative}
        if N !== 1
            same_indices(values(d))
        end
        new{N, D}(d)
    end
end

@inline DictTabular{N}(d::Associative) where {N} = DictTabular{N, typeof(d)}(d)
@inline DictTabular{N}(data::Pair...) where {N} = DictTabular{N}(Dict(data...))

# Aliases for common sizes
const DictTable{D <: Associative} = DictTabular{2, D}
const DictSeries{D <: Associative} = DictTabular{1, D}

# indices
# TODO these KeyIterators don't support very robust `==` or anything... will be necessary
#      for concatenation, etc...
@inline indices(t::DictTabular{1}) = (keys(t.dict),)
@inline indices(t::DictTabular) = (indices(first(values(t.dict)))..., keys(t.dict))

# getindex
@propagate_inbounds function getindex(t::DictTabular{1}, i)
    t.dict[i]
end

@propagate_inbounds function getindex(t::DictTabular{N}, inds::Vararg{Any, N}) where {N}
    (other_inds, this_ind) = pop(inds)
    t.dict[this_ind][other_inds...]
end

# setindex!
@propagate_inbounds function setindex!(t::DictTabular{1}, value, i)
    t.dict[i] = value
    return t
end

@propagate_inbounds function setindex!(t::Tabular{N}, value, inds::Vararg{Any, N}) where {N}
    (other_inds, this_ind) = pop(inds)
    t.dict[this_ind][other_inds...] = value
    return t
end
