
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

function same_indices(iter)
    i1 = indices(first(iter))
    for i ∈ iter
        if i1 != indices(i)
            return false
        end
    end
    return true

    #= # Optimize
    s = start(iter)
    if done(iter, s)
        return true
    end
    (i1, s) = next(iter, s)
    ...
    =#
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
