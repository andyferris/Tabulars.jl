@inline length(t::AbstractTabular) = prod(size(t))

struct Index{N, I <: NTuple{N, Any}}
    i::I
end

struct Indices{N, I <: NTuple{N, Any}}
    indices::I
end




struct TabularIterator{I,S,Idx}
    indices::I
    states::S
    index::Idx
end

# We need to track the iteration of each index
@inline function start(t::AbstractTabular)
    map(start, indices(tabular))
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

@inline done(t::AbstractTabular) = all(map(done, indices(t), it))
