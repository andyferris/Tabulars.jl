# TODO do we want `StructTable`?

struct StructSeries{T} <: Series
    data::T
    function StructSeries{T}(x::T) where T
        check_is_struct(T)
        new{T}(x)
    end
end
StructSeries(x::T) where {T} = StructSeries{T}(x)

indices(::StructSeries{T}) where T = (_fields(T),)

# TODO what to do for primitive types?
@pure function check_is_struct(::Type{T}) where T
    if !isleaftype(T)
        error("Expected leaf type, got $T")
    end
    out = map(Label, (fieldnames(T)...))
    if length(out) == 0
        error("Attempted to create a Series from type $T which has no fields")
    end
    return nothing
end

@pure function _fields(::Type{T}) where T
    if !isleaftype(T)
        error("Expected leaf type, got $T")
    end
    out = map(Label, (fieldnames(T)...))
    if length(out) == 0
        error("Attempted to create a Series from type $T which has no fields")
    end
    return out
end

# getindex
@inline function getindex(s::StructSeries, ::Label{L}) where L
    getfield(s.data, L)
end

@inline function getindex(s::StructSeries, ::Colon)
    s
end

@inline function getindex(s::StructSeries, inds::Tuple{Vararg{Label}})
    Series(_map(l -> l => s[l], inds))
end

# setindex!
@inline function setindex!(s::StructSeries, v, ::Label{L}) where L
    setfield!(s.data, L, v)
end
