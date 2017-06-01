# Some convenience constructors, e.g. `Table(l"A" => [1,2], l"B" => [true, false])`

@inline Tabular{N}(x...) where {N} = Tabular{N}(x)

Tabular{N}(x::Tuple) where {N} = error("No method to construct a Tabular from $x")

@inline function Series(x::Tuple{Vararg{Pair}})
    if aresingleton(_map(first, x))
        TupleSeries(x)
    else
        Series(Dict(x...))
    end
end

@inline function Tabular{N}(x::Tuple{Vararg{Pair}}) where {N}
    if aresingleton(_map(first, x))
        if aretype(Tabular{decrement(N)}, _map(last, x))
            TupleTabular{N}(x)
        else
            TupleTabular{N}(_map(kv -> Pair(kv.first, Tabular{decrement(N)}(kv.second)), x))
        end
    else
        Tabular{N}([x...])
    end
end

@inline Series(x::AbstractVector) = ArraySeries(x)
@inline Tabular{N}(x::AbstractArray{<:Any, N}) where {N} = ArrayTabular{N}(x)
@inline function Tabular{N}(x::AbstractArray{T, M}) where {T,N,M}
    if T <: Tabular{decrement(N,M)}
        ArrayTabular{N}(x)
    else
        ArrayTabular{N}(map(Tabular{decrement(N,M)}, x))
    end
end

@inline Series(x::AbstractVector{<:Pair}) = DictSeries(Dict(x))
@inline function Tabular{N}(x::AbstractVector{<:Pair}) where {N}
    if _secondtype(eltype(x)) <: Tabular{decrement(N)}
        DictTabular{N}(Dict(x))
    else
        DictTabular{N}(Dict(map(kv -> Pair(kv.first, Tabular{decrement(N)}(kv.second)), x)))
    end
end

@inline Series(x::Associative) = DictSeries(x)
@inline function Tabular{N}(x::Associative) where {N}
    if valtype(x) <: Tabular{decrement(N)}
        DictTabular{N}(x)
    else
        DictTabular{N}(map(kv -> Pair(kv.first, Tabular{decrement(N)}(kv.second)), x))
    end
end

@inline Series(x) = StructSeries(x)
