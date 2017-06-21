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

function tabulate(v::AbstractVector{T}) where T
    Table(make_faster(make_faster.(v)))
end

function tabulate(d::Associative{String, <:Any})
    data = ()
    for n ∈ keys(d)
        data = (data..., Label{Symbol(n)}() => make_faster(d[n]))
    end
    return Table(data)
end

function tabulate(d::Associative{Symbol, <:Any})
    data = ()
    for n ∈ keys(d)
        data = (data..., Label{n}() => make_faster(d[n]))
    end
    return Table(data)
end

function make_faster(d::Associative{String, Any})
    data = ()
    for n ∈ keys(d)
        data = (data..., Label{Symbol(n)}() => d[n])
    end
    return data
end

function make_faster(d::Associative{Symbol, Any})
    data = ()
    for n ∈ keys(d)
        data = (data..., Label{n}() => d[n])
    end
    return data
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

function make_faster(vec::AbstractVector{T}) where {T}
    if isleaftype(T)
        return vec
    end

    T2 = Union{}
    for x ∈ vec
        T2 = promote_type(T2, typeof(x))
    end
    
    out = similar(vec, T2)
    out[:] = vec[:]
    
    return out
end