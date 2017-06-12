
struct IndexError <: Exception
    str::String
end

"""
    pop(x::Tuple)

For an `n`-element tuple, returns a tuple `(all_but_last, last)` where `last` is the
final element of the collection and `all_but_last` is a collection containing the first
`n-1` elements.
"""
@inline pop(x::Tuple) = _pop((), x...)
@inline _pop(out::Tuple{}) = error("Can't `pop` on an empty tuple")
@inline _pop(out::Tuple, x) = (out, x)
@inline _pop(out::Tuple, x, y...) = _pop((out..., x), y...)

"""
    pop(x::Tuple, Val{m})

For an `n`-element tuple, returns a tuple `(all_but_last_m, last_m)` where `last_m` is
the final `m` elements of the collection and `all_but_last_m` is a collection containing the
first `n-m` elements.
"""
@generated function pop(x::Tuple, ::Type{Val{N}}) where {N}
    M = length(x.parameters)
    @assert N::Int >= 0
    @assert N <= M

    exprs1 = [:(x[$i]) for i = 1:(M-N)]
    exprs2 = [:(x[$i]) for i = (M-N+1):M]
    quote
        @_inline_meta
        (tuple($(exprs1...)), tuple($(exprs2...)))
    end
end

@inline function same_indices(iter)
    #=i1 = indices(first(iter))
    for i ∈ iter
        if i1 != indices(i)
            return false
        end
    end
    return true =#

    # Optimize
    s = start(iter)
    if done(iter, s)
        return true
    end
    (x, s) = next(iter, s)
    i1 = indices(x)
    while !done(iter, s)
        (x, s) = next(iter,s)
        if _same_indices(indices(x), i1)
            continue
        else
            return false
        end
    end
    return true
end

@inline _same_indices(inds1::Tuple{Any}, inds2::Tuple{Any}) = _same_index(inds1[1], inds2[1])
@inline function _same_indices(inds1::Tuple{Any, Any}, inds2::Tuple{Any,Any})
    _same_index(inds1[1], inds2[1]) && _same_index(inds1[2], inds2[2])
end

@inline function _same_index(ind1, ind2)
    if ind1 === ind2
        return true
    end

    i1 = collect(ind1)
    i2 = collect(ind2)

    # They are not equal if they have different indices
    if i1 != i2
        if length(i1) != length(i2)
            for i ∈ i1
                if i ∉ i2
                    return false
                end
            end
        end
    end
    return true
end

@generated function _map(f, x::Tuple)
    exprs = [:(f(x[$i])) for i = 1:length(x.parameters)]
    return quote
        @_inline_meta
        tuple($(exprs...))
    end
end

@pure issingleton(::Type{T}) where {T} = (length(T.types) == 0 && !T.mutable)
@inline issingleton(x) = issingleton(typeof(x))

@inline aresingleton(x::Tuple) = _aresingleton(x...)
@inline _aresingleton(x, y...) = issingleton(x) && _aresingleton(y...)
@inline _aresingleton(x) = issingleton(x)

@inline aretype(::Type{T}, x::Tuple) where {T} = _aretype(T, x...)
@inline _aretype(::Type{T}, x, y...) where {T} = isa(x, T) && _aretype(T, y...)
@inline _aretype(::Type{T}, x) where {T} = isa(x, T)

_firsttype(::Type{Pair{A,B}}) where {A,B} = A
_firsttype(::Pair{A,B}) where {A,B} = A
_secondtype(::Type{Pair{A,B}}) where {A,B} = B
_secondtype(::Pair{A,B}) where {A,B} = B

@pure increment(i::Int) = i + 1
@pure increment(i::Int, j::Int) = i + j
@pure decrement(i::Int) = i - 1
@pure decrement(i::Int, j::Int) = i - j
