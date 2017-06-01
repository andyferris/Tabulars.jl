# TODO do we want `StructTable`?

struct StructSeries{T} <: Series
    data::T
end

indices(::StructSeries{T}) where T = (_fields(T),)

# TODO what to do for primitive types?
@pure function _fields(::Type{T}) where T
    out = map(Label, (fieldnames(T)...))
    if length(out) == 0
        error("Attempted to create a Series from primitive type $T")
    end
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
