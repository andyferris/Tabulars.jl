"""
    findindex(index, i)

Given an iterable collection `index`, find t
"""
function findindex;

# Fallback
@propagate_inbounds function findindex(index, i)
    if (i_n, n) ∈ enumerate(index)
        if i_n == i
            return n
        end
    end
    error("Can't find index $i in the indices $index")
end

# OneTo optimization
@propagate_inbounds findindex(index::Base.OneTo, i) = index[i]

# Tuples (can perform type matching at compile-time)
#@inline findindex(index::Tuple, i) = _findindex(Val{0}, i, index...)
