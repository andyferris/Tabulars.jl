"""
    ArrayTabular(array)
    ArrayTabular{N}(array)

Constructs a `ArrayTabular` data structure. Specifying `N > ndims(array)` will result in a
nested tabular structure where the remain `N - ndims(array)` indices are provided by the
elements
"""
struct ArrayTabular{N, A <: AbstractArray} <: Tabular{N}
    array::A

    function ArrayTabular{N, A}(a::A) where {N, A <: AbstractArray{N}}
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
const ArrayTable{D <: Associative} = DictTabular{2, D}
const ArraySeries{D <: Associative} = DictTabular{1, D}

# non-nested
const FlatArrayTabular{N, A <: AbstractArray{N}} = ArrayTabular{N, A}

@inline indices(t::FlatArrayTabular) = indices(t)
@inline indices(t::ArrayTabular) = (indices(t)..., indices(first(t))...)

# getindex
@propagate_inbounds function getindex(t::FlatArrayTabular{N}, inds::Vararg{Integer, N}) where {N}
    t.array[inds...]
end

@propagate_inbounds function getindex(t::ArrayTabular{N}, inds::Vararg{Any, N}) where {N, M}
    (other_inds, these_inds) = pop(inds, Val{N})
    t[these_inds...][other_inds...]
end

# setindex!
@propagate_inbounds function setindex!(t::FlatArrayTabular{N}, value, inds::Vararg{Integer, N}) where {N}
    t.array[inds...] = value
end

@propagate_inbounds function setindex!(t::ArrayTabular{N}, value, inds::Vararg{Any, N}) where {N, M}
    (other_inds, these_inds) = pop(inds, Val{N})
    t.array[these_inds...][other_inds...] = value
end
