# Generic indexing methods. In the long-term, we aim to generalize the APL rules for
# Base.AbstractArray to general sets of indices.

struct Index{N, I <: NTuple{N, Any}}
    i::I
end

struct State{N, S <: NTuple{N, Any}}
    s::S
end

struct Indices{N, I <: NTuple{N, Any}}
    indices::I
end

@inline eachindex(t::AbstractTabular) = Indices(indices(t))

# We need to track the iteration of each index
@inline function start(i::Indices)
    State(map(start, i.i))
end

@inline function next(t::AbstractTabular, it::Tuple)
    it2 = _next((), map(Pair, indices(t), it...)
    return (it2, it2 => t[it2...])
end

@inline _next(out, it) = (out..., next(it))
@inline function _next(out::Tuple, it, its...)
    if done(it.first, it.second)
        return _next((out..., start(it.first)), its...)
    else

        return (out..., next(it), its...)
    end
end

@inline done(i::Indices, s::State) = all(map(done, i.i, s.s))


# To begin with, we support slicing with `:` and scalar indices only.

@propagate_inbounds function getindex(t::AbstractTabular{N}, inds::Union{T, Any}...) where {T <: Colon}
    if length(inds) !== N
        error("Can't index an N dimensional tabular object with $(length(inds)) indices.")
    end
    new_indices = _collect_indices(map(Pair, indices(t), inds)
    similar_type(typeof(t), inds)(i -> t)
end

#_collect_indices()
