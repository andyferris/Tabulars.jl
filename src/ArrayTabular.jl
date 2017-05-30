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

# Series - scalar or not
@propagate_inbounds function getindex(t::ArraySeries{<:AbstractVector}, i::Integer)
    t.array[i]
end

@propagate_inbounds function getindex(t::ArraySeries{<:AbstractVector}, i::Union{Colon, AbstractVector{<:Integer}})
    ArraySeries(t.array[i])
end

# Table - scalar/non-scalar in several nested patterns
@propagate_inbounds function getindex(t::ArrayTable{<:AbstractVector}, i1::Integer, i2)
    t.array[i1][i2]
end

struct Indexer{I}
    inds::I
end
@propagate_inbounds (i::Indexer)(x) = x[i.inds]

@propagate_inbounds function getindex(t::ArrayTable{<:AbstractVector}, i1::AbstractVector{<:Integer}, i2)
    data = map(Indexer(i2), t.array[ind1]) # TODO map isn't propagate_inbounds... needs workaround
    if eltype(data) <: Series
        return ArrayTable(data)
    else
        return ArraySeries(data)
    end
end

@propagate_inbounds function getindex(t::ArrayTable{<:AbstractVector}, ::Colon, i2)
    data = map(Indexer(i2), t.array)
    if eltype(data) <: Series
        return ArrayTable(data)
    else
        return ArraySeries(data)
    end
end

@propagate_inbounds function getindex(t::ArrayTable{<:AbstractMatrix}, i1::Integer, i2::Integer)
    t.array[i1, i2]
end

@propagate_inbounds function getindex(t::ArrayTable{<:AbstractMatrix}, i1::Integer, i2::Union{AbstractVector{<:Integer},Colon})
    ArraySeries(t.array[i1, i2])
end

@propagate_inbounds function getindex(t::ArrayTable{<:AbstractMatrix}, i1::Union{AbstractVector{<:Integer},Colon}, i2::Integer)
    ArraySeries(t.array[i1, i2])
end

@propagate_inbounds function getindex(t::ArrayTable{<:AbstractMatrix}, i1::Union{AbstractVector{<:Integer},Colon}, i2::Union{AbstractVector{<:Integer},Colon})
    ArrayTable(t.array[i1, i2])
end

# TODO higher dimensions, or find some generic way of doing this.

#=
# Get a single element - this is the implementation of scalar indexing
@propagate_inbounds function getindex(t::FlatArrayTabular{N}, inds::Vararg{Integer, N}) where {N}
    t.array[inds...]
end

@propagate_inbounds function getindex(t::ArrayTabular{N}, inds::Vararg{Any, M}) where {N, M}
    (other_inds, these_inds) = pop(inds, Val{ndims(t.array)})


    t.array[these_inds...][other_inds...]
end

# scalar setindex!
@propagate_inbounds function setelement!(t::FlatArrayTabular{N}, value, inds::Vararg{Integer, N}) where {N}
    t.array[inds...] = value
end

@propagate_inbounds function setelement!(t::ArrayTabular{N}, value, inds::Vararg{Any, M}) where {N, M}
    (other_inds, these_inds) = pop(inds, Val{ndims(t.array)})
    t.array[these_inds...][other_inds...] = value
end
=#
