struct Tabular{N, Index, Data}
    index::Index
    data::Data
end

ndims(t::Tabular{N}) where {N} = N

@inline indices(t::Tabular{0}) = ()
@inline indices(t::Tabular{1}) = (t.index)
@inline indices(t::Tabular) = (indices(t.data)..., t.index)

@inline size(t::Tabular) = map(length, indices(t))

# getindex
@inline getindex(t::Tabular{0}) = t.data

@propagate_inbounds function getindex(t::Tabular{1}, i)
    t.data[findindex(t.index, i)]
end

@propagate_inbounds function getindex(t::Tabular{N}, inds::Vararg{Any, N}) where {N}
    (other_inds, this_ind) = pop(inds)
    t.data[findindex(t.index, this_ind)][other_inds...]
end
