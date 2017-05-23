struct FullSlice{I}
    i::I
end

struct SubSlice{I}
    i::I
end

to_indices(t::Tabular, inds...) = _to_indices(indices(t), inds...)

@propagate_inbounds _to_indices(indices, inds...) = (to_index(indices[1], inds[1]), _to_indices(tail(indices), tail(inds)...)...)

@propagate_inbounds function getindex(t::Tabular, inds...)
    to_indices(t, inds)
end
