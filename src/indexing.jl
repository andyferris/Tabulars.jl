# Generic indexing methods. We aim to generalize the APL rules for Base.AbstractArray to
# general sets of indices.

# To begin with, we support slicing with `:` and scalar indices only.

@propagate_inbounds function getindex(t::AbstractTabular{N}, inds::Union{T, Any}...) where {T <: Colon}
    if length(inds) !== N
        error("Can't index an N dimensional tabular object with $(length(inds)) indices.")
    end
    new_indices = _collect_indices(map(Pair, indices(t), inds)
    similar_type(typeof(t), inds)(i -> t)
end

#_collect_indices()
