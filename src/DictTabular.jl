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

#TODO These don't auto-wrap inner series like the standard constructors do...

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

# ==========
#  Indexing
# ==========

# Series
@propagate_inbounds function getindex(t::DictSeries{<:Associative{K}}, i::K) where {K}
    return t.dict[i]
end

@propagate_inbounds function getindex(t::DictSeries{<:Associative{K}}, ::Colon) where {K}
    return DictSeries(copy(t.dict))
end

@propagate_inbounds function getindex(t::DictSeries{<:Associative{K}}, inds::AbstractVector{K}) where {K}
    return DictSeries(Dict(map(k -> Pair(k, t.dict[k]), inds)))
end

# Table
@propagate_inbounds function getindex(t::DictTable{<:Associative{K}}, other_inds, this_ind::K) where {K}
    return t.dict[this_ind][other_inds]
end

@propagate_inbounds function getindex(t::DictTable{<:Associative{K}}, other_inds, ::Colon) where {K}
    dict = map(kv -> Pair(kv.first, kv.second[other_inds]), t.dict)
    if valtype(dict) <: Series
        return DictTable(dict)
    else
        return DictSeries(dict)
    end
end

@propagate_inbounds function getindex(t::DictTable{<:Associative{K}}, other_inds, this_inds::AbstractVector{K}) where {K}
    dict = Dict(map(k -> Pair(k, t.dict[k][other_inds]), this_inds))
    if valtype(dict) <: Series
        return DictTable(dict)
    else
        return DictSeries(dict)
    end
end

# ===========
#  setindex!
# ===========

@propagate_inbounds function setindex!(s::DictSeries{<:Associative{K}}, v, i::K) where {K}
    s.dict[i] = v
end

@propagate_inbounds function setindex!(t::DictTable{<:Associative{K}}, v, i1, i2::K) where {K}
    t.dict[i2][i1] = v
end

@propagate_inbounds function setindex!(t::DictTable{<:Associative{K}}, v, i1, ::Colon) where {K}
    # TODO Support v being table or series
    for x ∈ values(s.dict)
        x[i1] = v
    end
end

@propagate_inbounds function setindex!(t::DictTable{<:Associative{K}}, v, i1, i2::AbstractVector{K}) where {K}
    # TODO Support v being table or series
    for k ∈ i2
        s.dict[k][i1] = v
    end
end
