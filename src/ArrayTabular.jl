# ArrayTabular indices are identified as subtypes of AbstractUnitRange

"""
    ArrayTabular(array)
    ArrayTabular{N}(array)

Constructs a `ArrayTabular` data structure. Specifying `N > ndims(array)` will result in a
nested tabular structure where the remain `N - ndims(array)` indices are provided by the
elements (which are themselves `Tabular`).
"""
struct ArrayTabular{N, A <: AbstractArray} <: Tabular{N}
    array::A

    function ArrayTabular{N, A}(a::A) where {N, A <: AbstractArray{<:Any, N}}
        new{N, A}(a)
    end

    function ArrayTabular{N, A}(a::A) where {N, A <: AbstractArray}
        if !same_indices(a)
            error("ArrayTabular{N} expects elements of $(ndims(a))-dimensional array to have matching indices")
        end
        new{N, A}(a)
    end
end

ArrayTabular(a::AbstractArray{N}) where {N} = ArrayTabular{N}(a)
ArrayTabular{N}(a::AbstractArray) where {N} = ArrayTabular{N, typeof(a)}(a)

# Aliases for common shapes
const ArrayTable{A <: AbstractArray} = ArrayTabular{2, A}
const ArraySeries{A <: AbstractArray} = ArrayTabular{1, A}

# non-nested
const FlatArrayTabular{N, A <: AbstractArray{<:Any, N}} = ArrayTabular{N, A}

@inline indices(t::FlatArrayTabular) = indices(t.array)
@inline indices(t::ArrayTabular) = (indices(first(t.array))..., indices(t.array)...)

# ==========
#  getindex
# ==========

# TODO - maybe fancy indexing should return some kind of sort-based associative rather than a hash-based one?

# Series - scalar or not
@propagate_inbounds function getindex(t::ArraySeries{<:AbstractVector}, i::Integer)
    t.array[i]
end

# Unlike `AbstractVector`, fancy indexing always preserves the index keys. If these are not
# a unit range, then we need a more general (non-array) behavior
@propagate_inbounds function getindex(t::ArraySeries{<:AbstractVector}, inds::AbstractVector{<:Integer})
    d = Dict{eltype(inds), eltype(t.array)}()
    for i ∈ inds
        d[i] = t.array[i]
    end
    return Series(d)
end

# Optimization for UnitRange (Base.OneTo)
@propagate_inbounds function getindex(t::ArraySeries{<:Vector}, inds::Base.OneTo{Int})
    return Series(t.array[inds])
end

@propagate_inbounds function getindex(t::ArraySeries{<:AbstractVector}, ::Colon)
    Series(t.array[:])
end

# Table - scalar/non-scalar in several nested patterns
@propagate_inbounds function getindex(t::ArrayTable{<:AbstractVector}, i1, i2::Integer)
    t.array[i2][i1]
end

struct Indexer{I}
    inds::I
end
@propagate_inbounds (i::Indexer)(x) = x[i.inds]

# Unlike `AbstractArray`, gancy indexing always preserves the index keys
@propagate_inbounds function getindex(t::ArrayTable{<:AbstractVector}, i1, i2::AbstractVector{<:Integer})
    data = Dict(map((k,v) -> k => v[i1], enumerate(t.array[i2]))) # TODO optimize?

    if valtype(data) <: Series
        return Table(data)
    else
        return Series(data)
    end
end

@propagate_inbounds function getindex(t::ArrayTable{<:AbstractVector}, i1, ::Colon)
    data = map(Indexer(i1), t.array) # TODO map isn't propagate_inbounds... needs workaround?
    if eltype(data) <: Series
        return Table(data)
    else
        return Series(data)
    end
end

@propagate_inbounds function getindex(t::ArrayTable{<:AbstractMatrix}, i1::Integer, i2::Integer)
    t.array[i1, i2]
end

# TODO fancy indexing

@propagate_inbounds function getindex(t::ArrayTable{<:AbstractMatrix}, i1::Integer, i2::Colon)
    ArraySeries(t.array[i1, i2])
end

@propagate_inbounds function getindex(t::ArrayTable{<:AbstractMatrix}, i1::Colon, i2::Integer)
    ArraySeries(t.array[i1, i2])
end

@propagate_inbounds function getindex(t::ArrayTable{<:AbstractMatrix}, i1::Colon, i2::Colon)
    ArrayTable(t.array[i1, i2])
end

# TODO higher dimensions, or find some generic way of doing this.

# ===========
#  setindex!
# ===========
@propagate_inbounds setindex!(s::ArraySeries, v, i) = s.array[i] = v

@propagate_inbounds setindex!(s::ArrayTable{<:AbstractMatrix}, v, i1, i2) = s.array[i1, i2] = v

@propagate_inbounds setindex!(s::ArrayTable{<:AbstractVector}, v, i1, i2::Integer) = s.array[i2][i1] = v

@propagate_inbounds function setindex!(s::ArrayTable{<:AbstractVector}, v, i1, ::Colon)
    # TODO this one doesn't completely support `v` being an array, or a tabular, or whatever...
    # Array might be hard... I guess we need Table or Series
    for i ∈ indices(s.array)
        s.array[i][i1] = v
    end
end

@propagate_inbounds function setindex!(s::ArrayTable{<:AbstractVector}, v, i1, i2::AbstractVector{<:Integer})
    # TODO this one doesn't completely support `v` being an array, or a tabular, or whatever...
    for i ∈ i2
        s.array[i2][i1] = v
    end
end

# ======
#  view
# ======

# TODO
