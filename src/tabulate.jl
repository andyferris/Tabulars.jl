using DataFrames, DataArrays

"""
    tabulate(data)

Constructs a `Table` from the input data, attempting to make a structure with 
This may or may not make copies of data, depending if the ingester decides it would
be beneficial (e.g. accelerate `getindex` from *O(N)* to *O(1)* or *O(log N)*).

Some examples include

 * `DataFrame` becomes a `Table` with column indices as `Label`s (`:x` becomes `l"x"`)
    and type-stable vectors as columns. Makes copies of columns which are `Nullable{T}`
    if the column contains `NA`, or else simply `T` if not.
"""
function tabulate(df::DataFrame)
    data = ()
    for n ∈ names(df)
        data = (data..., Label{n}() => make_faster(df[n]))
    end
    return Table(data)
end

function make_faster(vec::DataVector{T}) where {T}
    has_nulls = false
    for x ∈ vec
        if x === NA
            has_nulls = true
            break
        end
    end
    if has_nulls
        out = Vector{Nullable{T}}(length(vec))
        for i ∈ 1:length(vec)
            if vec[i] === NA
                out[i] = Nullable{T}()
            else
                out[i] = Nullable{T}(vec[i])
            end
        end
    else
        out = Vector{T}(length(vec))
        out[:] = vec[:]
    end
    return out
end