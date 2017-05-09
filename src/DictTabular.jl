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

# internal type to manage indexing, slicing, similar, etc.
struct DictTabularIndex{V <: AbstractVector} <: TabularIndex
    v::V
end
@propagate_inbounds getindex(dti::DictTabularIndex, i) = dti.v[i]

@inline to_index(t::DictTabular, i) = i
@inline to_index(t::DictTabular, ::Colon) = DictTabularIndex(collect(keys(t)))
@inline to_index(t::DictTabular, v::AbstractVector) = DictTabularIndex(v)

#@inline function to_index(t::DictTabular, inds...)
#    return _map(i -> to_index, inds)
#end

@inline to_indices(t::DictSeries, ind) = to_index(t, ind)
@inline function to_indices(t::DictTabular, inds...)
    (other_inds, this_ind) = pop(inds)
    return (to_indices(first(t).second, other_inds...), to_index(t, this_ind))
end

# scalar getindex
@propagate_inbounds function getindex(t::DictSeries{<:Associative{K}}, i::K) where {K}
    return t.dict[i]
end

@propagate_inbounds function getindex(t::DictTabular, inds...)
    (other_inds, this_ind) = pop(inds)
    return t.dict[this_ind][other_inds...]
end

# slice getindex
@propagate_inbounds function getindex(t::DictSeries, ::Colon)
    return t
end

@propagate_inbounds function getindex(t::DictTabular, ::Colon, other_inds...)
    d = similar(t.dict)
    for k ∈ keys(t.dict)
        d[k] = t.dict[k][other_inds...]
    end
    return DictSeries(d)
    (other_inds, this_ind) = pop(inds)
    DictTabular{N}(t.dict[this_ind][other_inds...]) # Not correct... dimensionality depends on N
end

# fancy getindex
@propagate_inbounds function getindex(t::DictSeries{<:Associative{K}}, inds::AbstractVector{K}) where {K}
    d = similar(t.dict)
    for k ∈ inds
        d[k] = t.dict[k]
    end
    return DictSeries(d)
end

# TODO

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
