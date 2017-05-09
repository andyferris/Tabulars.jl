# Some convenience constructors, e.g. `Table(l"A" => [1,2], l"B" => [true, false])`

@inline Tabular{N}(x...) where {N} = Tabular{N}(x)

Tabular{N}(x::Tuple) where {N} = error("No method to construct a Tabular from $x")
@inline function Tabular{N}(x::Tuple{Vararg{Pair}}) where {N}
    if aresingleton(_map(first, x))
        TupleTabular{N}(x)
    else
        DictTabular{N}(Dict(x...))
    end
end

@inline Tabular{N}(x::AbstractArray) where {N} = ArrayTabular{N}(x)
@inline Tabular{N}(x::AbstractArray{<:Pair}) where {N} = DictTabular{N}(Dict(x))
