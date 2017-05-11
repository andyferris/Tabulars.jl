"""
    PermutedDimsTabular{Perm}(tabular)

Presents a view of a tabular object where the order of indices is permuted. `Perm` must be
a tuple instance of the same length as the number of dimensions of the `Tabular` input, e.g.
`PermutDimsTabular{(2,1)}(table)` takes the "transpose" of a table.

See also `permutedims`, `transpose`.
"""
struct PermutedDimsTabular{Perm, N, Tab <: Tabular{N}} <: Tabular{N}
    t::Tab
end

@inline function PermutedDimsTabular{Perm}(t::Tabular{N}) where {Perm, N}
    return PermutedDimsTabular{Perm, N, typeof(t)}(t)
end

"""
    permutedims(tabular::Tabular, Val{Perm})

Presents a view of a tabular object where the order of indices is permuted as a
`PermutedDimsTabular`. `Perm` must be a tuple instance of the same length as the number of
dimensions of the `Tabular` input, e.g. `permutedims(table, Val{(2,1)})` takes the
"transpose" of a table.

See also `transpose`, `PermutedDimsTabular`.
"""
permutedims(t::Tabular, ::Type{Val{Perm}}) where {Perm} = PermutedDimsTabular{Perm}(t)
permutedims(t::Tabular{0}, ::Type{Val{()}}) = t
permutedims(t::Tabular{1}, ::Type{Val{(1,)}}) = t

"""
    transpose(t::Table)

Presents a view of a table object where the column and row indices are reversed.

See also `permutedims`, `PermutedDimsTabular`
"""
transpose(t::Table) = permutedims(t, Val{(2,1)})

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

indices(t::PermutedDimsTabular{Perm}) where {Perm} = _permute(Val{Perm}, indices(t.t))

@propagate_inbounds function getindex(t::PermutedDimsTabular{Perm, N}, inds::Vararg{Any, N}) where {Perm, N}
    return t.t[_permute(Val{Perm}, inds)...]
end

@propagate_inbounds function setindex!(t::PermutedDimsTabular{Perm, N}, value, inds::Vararg{Any, N}) where {Perm, N}
    t.t[_permute(Val{Perm}, inds)...] = value
    return t
end
