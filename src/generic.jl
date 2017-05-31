# Generally, these methods may not have optimal speed for all Tabular types, but they should
# be robust fallbacks, with reference implementation behavior that other types can
# specialize for speed

function (==)(s1::Series, s2::Series)
    i1 = collect(indices(s1))
    i2 = collect(indices(s2))

    # They are not equal if they have different indices
    if i1 != i2
        if length(i1) != length(i2)
            for i ∈ i1
                if i ∉ i2
                    return false
                end
            end
        end
    end

    # They are not equal if they have different values
    for i ∈ i1
        @inbounds if s1[i] != s2[i]
            return false
        end
    end

    return true
end

function (==)(t1::Table, t2::Table)
    inds_1 = indices(t1)
    inds_2 = indices(t2)

    row_inds_1 = collect(inds_1[1])
    row_inds_2 = collect(inds_2[1])

    # They are not equal if they have different row indices
    if row_inds_1 != row_inds_2
        if length(row_inds_1) != length(row_inds_2)
            for r ∈ row_inds_1
                if r ∉ row_inds_2
                    return false
                end
            end
        end
    end

    col_inds_1 = collect(inds_1[2])
    col_inds_2 = collect(inds_2[2])

    # They are not equal if they have different column indices
    if col_inds_1 != col_inds_2
        if length(col_inds_1) != length(col_inds_2)
            for c ∈ col_inds_1
                if c ∉ col_inds_2
                    return false
                end
            end
        end
    end

    # They are not equal if they have different values
    for r ∈ row_inds_1
        for c ∈ col_inds_1
            @inbounds if t1[r, c] != t2[r, c]
                return false
            end
        end
    end

    return true
end