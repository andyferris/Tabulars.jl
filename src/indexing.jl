
function getindex(t::Tabular, inds...)
    throw(DimensionMismatch(t, inds))
end

#=
struct FullSlice{I}
    i::I
end

struct SubSlice{I}
    i::I
end

to_indices(t::Tabular, inds...) = _to_indices(indices(t), inds...)

@propagate_inbounds function _to_indices(indices, inds...)
    return (to_index(indices[1], inds[1]), _to_indices(tail(indices), tail(inds)...)...)
end

struct GetindexConstructor
    t::Tabular
end

@propagate_inbounds function getindex(t::Tabular, inds...)
    selected_inds = to_indices(t, inds)
    new_inds = squeeze_indices(selected_inds)

    # Given new inds, make an Tabular...
    GetindexConstructor(t)(selected_inds)
end
=#
