function (==)(t1::AbstractTabular{N}, t2::AbstractTabular{N}) where {N}
    if indices(t1) != indices(t2)
        return false
    end

    for i ∈ indices(t1)
        @inbounds if t1[i] != t2[i]
            return false
        end
    end
    return true
end
