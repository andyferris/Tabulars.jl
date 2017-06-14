"""
    PermutedDimsTabular{Perm}(data)

Like `Tabular`, but presents a view of tabular data where the order of indices is 
permuted. `Perm` must be a tuple instance of the same length as the number of 
dimensions of the `Tabular` input, e.g. `PermutDimsTabular{(2,1)}(table)` takes
the "transpose" of a table.

See also `permutedims`, `transpose`.
"""
struct PermutedDimsTabular{Perm, N, D} <: AbstractTabular{N}
    data::D
end

@inline function PermutedDimsTabular{Perm}(data::D) where {Perm, D}
    return PermutedDimsTabular{Perm::Tuple{Vararg{Int}}, length(Perm), D}(data)
end

@inline PermutedDimsTabular{Perm,N}(data::D) where {Perm,N,D} = PermutedDimsTabular{Perm,N,D}(data)

const TransposedTable{D} = PermutedDimsTabular{(2,1), 2, D}

get(t::PermutedDimsTabular) = t.data


"""
    permutedims(tabular::Tabular, Val{Perm})

Presents a view of a tabular object where the order of indices is permuted as a
`PermutedDimsTabular`. `Perm` must be a tuple instance of the same length as the number of
dimensions of the `Tabular` input, e.g. `permutedims(table, Val{(2,1)})` takes the
"transpose" of a table.

See also `transpose`, `PermutedDimsTabular`.
"""
permutedims(t::Tabular, ::Type{Val{Perm}}) where {Perm} = PermutedDimsTabular{Perm, ndims(t), typeof(get(t))}(get(t))
#permutedims(t::Tabular{0}, ::Type{Val{()}}) = t
permutedims(t::Tabular{1}, ::Type{Val{(1,)}}) = t

"""
    transpose(t::Table)

Presents a view of a table object where the column and row indices are reversed.

See also `permutedims`, `PermutedDimsTabular`
"""
transpose(t::Table) = permutedims(t, Val{(2,1)})
transpose(t::TransposedTable) = Table(get(t))

@generated function _permute(::Type{Val{Perm}}, inds) where {Perm}
    l = length(Perm)
    if l != length(inds.parameters)
        error("Cannot permute $(length(inds)) values by a length $l permutation")
    end
    exprs = [:(inds[$i]) for i ∈ Perm]
    return quote
        @_inline_meta
        tuple($(exprs...))
    end
end

indices(t::PermutedDimsTabular{Perm}) where {Perm} = _permute(Val{Perm}, indices(t.data))

@propagate_inbounds function getindex(t::PermutedDimsTabular{(1,), 1}, i)
    dims = Dims(index_shape(t, i))
    data = _getindex(Dims(1), get(t), i)
    if dims == 0
        return data
    else
        return Tabular{get(dims)}(data)
    end
end

@propagate_inbounds function getindex(t::PermutedDimsTabular{(1, 2), 2}, i1, i2)
    dims = Dims(index_shape(t, i1, i2))
    data = _getindex(Dims(2), get(t), i1, i2)
    if dims == 0
        return data
    else
        return Tabular{get(dims)}(data)
    end
end

@propagate_inbounds function getindex(t::TransposedTable, i1, i2)
    dims = Dims(index_shape(t, i2, i1))
    data = _getindex(Dims(2), get(t), i2, i1)
    if dims == 0
        return data
    elseif dims == 1
        return Series(data)
    else
        return TransposedTable(data)
    end
end

@inline function index_shape(x::TransposedTable, i1, i2)
    shape = _index_shape(Dims(2), typeof(get(x)), typeof(i2), typeof(i1))
    if shape[1] === nothing || shape[2] === nothing
        # TODO: An explicit path using data from elements?
        throw(IndexError("Tried to index a transposed $(typeof(x)) with $(typeof(i1)), $(typeof(i2))"))
    else
        return (shape[2], shape[1]) # fast path for fully-typed, inferred case
    end
end

# @propagate_inbounds function setindex!(t::PermutedDimsTabular{Perm, N}, value, inds::Vararg{Any, N}) where {Perm, N}
#     t.t[_permute(Val{Perm}, inds)...] = value
# end
