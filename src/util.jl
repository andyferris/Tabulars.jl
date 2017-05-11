
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

# for some reason map from base on tuples wasn't working?
@generated function _map(f, x::Tuple)
    exprs = [:(f(x[$i])) for i = 1:length(x.parameters)]
    quote
        @_inline_meta
        tuple($(exprs...))
    end
end
