# Exception returned by bad tabular indexing
struct IndexError <: Exception
    str::String
end

# Dims trait for dimensionality of a Tabular
struct Dims{n}; end
@pure Dims(n::Int) = Dims{n}()
Dims(::Tabular{n}) where {n} = Dims(n)
get(::Dims{n}) where {n} = n

@pure Base.:+(::Dims{n}, m::Int) where {n} = Dims{n+m}()
@pure Base.:+(n::Int, ::Dims{m}) where {m} = Dims{n+m}()
@pure Base.:+(::Dims{n}, ::Dims{m}) where {n,m} = Dims{n+m}()

@pure Base.:-(::Dims{n}, m::Int) where {n} = Dims{n-m}()
@pure Base.:-(n::Int, ::Dims{m}) where {m} = Dims{n-m}()
@pure Base.:-(::Dims{n}, ::Dims{m}) where {n,m} = Dims{n-m}()

@pure Base.:(==)(::Dims{n}, m::Int) where {n} = n == m
@pure Base.:(==)(n::Int, ::Dims{m}) where {m} = n == m
@pure Base.:(==)(::Dims{n}, ::Dims{m}) where {n,m} = n == m

@pure Base.:(<)(::Dims{n}, m::Int) where {n} = n < m
@pure Base.:(<)(n::Int, ::Dims{m}) where {m} = n < m
@pure Base.:(<)(::Dims{n}, ::Dims{m}) where {n,m} = n < m

@pure Base.:(<=)(::Dims{n}, m::Int) where {n} = n <= m
@pure Base.:(<=)(n::Int, ::Dims{m}) where {m} = n <= m
@pure Base.:(<=)(::Dims{n}, ::Dims{m}) where {n,m} = n <= m

@pure Base.:(>=)(::Dims{n}, m::Int) where {n} = n >= m
@pure Base.:(>=)(n::Int, ::Dims{m}) where {m} = n >= m
@pure Base.:(>=)(::Dims{n}, ::Dims{m}) where {n,m} = n >= m

@pure Base.:(>)(::Dims{n}, m::Int) where {n} = n > m
@pure Base.:(>)(n::Int, ::Dims{m}) where {m} = n > m
@pure Base.:(>)(::Dims{n}, ::Dims{m}) where {n,m} = n > m


struct ScalarIndex; end
struct NonscalarIndex; end

"""
    index_shape(tabular, inds...)

Returns a tuple indicating which `inds` are a `ScalarIndex()`, and which are a 
`NonScalarIndex()`. The output is useful to determine dimensionality of the output of
indexing and other operations.
"""
@inline function index_shape(x::Series, i)
    shape = _index_shape(Dims(1), typeof(get(x)), typeof(i))
    if shape === (nothing,)
        # TODO: An explicit path using dat from elements?
        throw(IndexError("Tried to index a $(typeof(x)) with a $(typeof(i))"))
    else
        return shape # fast path for fully-typed, inferred case
    end
end

@inline function index_shape(x::Table, i1, i2)
    shape = _index_shape(Dims(2), typeof(get(x)), typeof(i1), typeof(i2))
    if shape[1] === nothing || shape[2] === nothing
        # TODO: An explicit path using data from elements?
        throw(IndexError("Tried to index a $(typeof(x)) with $(typeof(i1)), $(typeof(i2))"))
    else
        return shape # fast path for fully-typed, inferred case
    end
end

@pure function Dims(x::Tuple{Vararg{Union{ScalarIndex, NonscalarIndex}}})
    Dims{count(i -> (i isa NonscalarIndex), x)}()
end

# ============================
#  index_shape implementation
# ============================
_index_shape(::Dims{N}, container_type, index_types...) where {N} = ntuple(i->nothing, Val{N})

# Series

# associatives
_index_shape(::Dims{1}, ::Type{<:Associative{K}}, ::Type{K}) where {K} = (ScalarIndex(),)
_index_shape(::Dims{1}, ::Type{<:Associative{K}}, ::Type{<:AbstractVector{K}}) where {K} = (NonscalarIndex(),)
_index_shape(::Dims{1}, ::Type{<:Associative}, ::Type{Colon}) = (NonscalarIndex(),)

# vectors
_index_shape(::Dims{1}, ::Type{<:AbstractVector}, ::Type{<:Integer}) = (ScalarIndex(),)
_index_shape(::Dims{1}, ::Type{<:AbstractVector}, ::Type{<:AbstractVector{<:Integer}}) = (NonscalarIndex(),)
_index_shape(::Dims{1}, ::Type{<:AbstractVector}, ::Type{Colon}) = (NonscalarIndex(),)

# tuples of pairs
_index_shape(::Dims{1}, ::Type{<:Tuple{Vararg{Pair}}}, ::Type) = (ScalarIndex(),)
_index_shape(::Dims{1}, ::Type{<:Tuple{Vararg{Pair}}}, ::Type{<:Label}) = (ScalarIndex(),)
_index_shape(::Dims{1}, ::Type{<:Tuple{Vararg{Pair}}}, ::Type{<:Tuple}) = (NonscalarIndex(),)
_index_shape(::Dims{1}, ::Type{<:Tuple{Vararg{Pair}}}, ::Type{<:Tuple{Vararg{Label}}}) = (NonscalarIndex(),)
_index_shape(::Dims{1}, ::Type{<:Tuple{Vararg{Pair}}}, ::Type{Colon}) = (NonscalarIndex(),)

# everything else - structs
_index_shape(::Dims{1}, ::Type, ::Type{<:Label}) = (ScalarIndex(),)
_index_shape(::Dims{1}, ::Type, ::Type{<:Tuple{Vararg{Label}}}) = (NonscalarIndex(),)
_index_shape(::Dims{1}, ::Type, ::Type{Colon}) = (NonscalarIndex(),)

# Table

# associatives
function _index_shape(::Dims{2}, ::Type{<:Associative{K,V}}, ::Type{I}, ::Type{K}) where {K,V,I}
    (_index_shape(Dims(1), V, I)..., ScalarIndex())
end
function _index_shape(::Dims{2}, ::Type{<:Associative{K,V}}, ::Type{I}, ::Type{<:AbstractVector{K}}) where {K,V,I}
    (_index_shape(Dims(1), V, I)..., NonscalarIndex())
end
function _index_shape(::Dims{2}, ::Type{<:Associative{K,V}}, ::Type{I}, ::Type{Colon}) where {K,V,I}
    (_index_shape(Dims(1), V, I)..., NonscalarIndex())
end

# vectors
function _index_shape(::Dims{2}, ::Type{<:AbstractVector{V}}, ::Type{I}, ::Type{<:Integer}) where {V,I}
    (_index_shape(Dims(1), V, I)..., ScalarIndex())
end
function _index_shape(::Dims{2}, ::Type{<:AbstractVector{V}}, ::Type{I}, ::Type{<:AbstractVector{<:Integer}}) where {V,I}
    (_index_shape(Dims(1), V, I)..., NonscalarIndex())
end
function _index_shape(::Dims{2}, ::Type{<:AbstractVector{V}}, ::Type{I}, ::Type{Colon}) where {V,I}
    (_index_shape(Dims(1), V, I)..., NonscalarIndex())
end

# matrices
function _index_shape(::Dims{2}, ::Type{<:AbstractMatrix}, ::Type{<:Integer}, ::Type{<:Integer})
    (ScalarIndex(), ScalarIndex())
end
function _index_shape(::Dims{2}, ::Type{<:AbstractMatrix}, ::Type{<:Integer}, ::Type{<:AbstractVector{<:Integer}})
    (ScalarIndex(), NonscalarIndex())
end
function _index_shape(::Dims{2}, ::Type{<:AbstractMatrix}, ::Type{<:Integer}, ::Type{Colon})
    (ScalarIndex(), NonscalarIndex())
end
function _index_shape(::Dims{2}, ::Type{<:AbstractMatrix}, ::Type{<:AbstractVector{<:Integer}}, ::Type{<:Integer})
    (NonscalarIndex(), ScalarIndex())
end
function _index_shape(::Dims{2}, ::Type{<:AbstractMatrix}, ::Type{Colon}, ::Type{<:Integer})
    (NonscalarIndex(), ScalarIndex())
end
function _index_shape(::Dims{2}, ::Type{<:AbstractMatrix}, ::Type{<:AbstractVector{<:Integer}}, ::Type{<:AbstractVector{<:Integer}})
    (NonscalarIndex(), NonscalarIndex())
end
function _index_shape(::Dims{2}, ::Type{<:AbstractMatrix}, ::Type{<:AbstractVector{<:Integer}}, ::Type{Colon})
    (NonscalarIndex(), NonscalarIndex())
end
function _index_shape(::Dims{2}, ::Type{<:AbstractMatrix}, ::Type{Colon}, ::Type{<:AbstractVector{<:Integer}})
    (NonscalarIndex(), NonscalarIndex())
end
function _index_shape(::Dims{2}, ::Type{<:AbstractMatrix}, ::Type{Colon}, ::Type{Colon})
    (NonscalarIndex(), NonscalarIndex())
end


# tuples of pairs
function _index_shape(::Dims{2}, ::Type{T}, ::Type{I}, ::Type) where {I, T <: Tuple{Vararg{Pair}}}
    (_index_shape(Dims(1), first_val_type(T), I)..., ScalarIndex())
end
function _index_shape(::Dims{2}, ::Type{T}, ::Type{I}, ::Type{<:Label}) where {I, T <: Tuple{Vararg{Pair}}}
    (_index_shape(Dims(1), first_val_type(T), I)..., ScalarIndex())
end
function _index_shape(::Dims{2}, ::Type{T}, ::Type{I}, ::Type{<:Tuple}) where {I, T <: Tuple{Vararg{Pair}}}
    (_index_shape(Dims(1), first_val_type(T), I)..., NonscalarIndex())
end
function _index_shape(::Dims{2}, ::Type{T}, ::Type{I}, ::Type{<:Tuple{Vararg{Label}}}) where {I, T <: Tuple{Vararg{Pair}}}
    (_index_shape(Dims(1), first_val_type(T), I)..., NonscalarIndex())
end
function _index_shape(::Dims{2}, ::Type{T}, ::Type{I}, ::Type{Colon}) where {I, T <: Tuple{Vararg{Pair}}}
    (_index_shape(Dims(1), first_val_type(T), I)..., NonscalarIndex())
end
@pure function first_val_type(T::Type{<:Tuple{Vararg{Pair}}})
    T.parameters[1].parameters[2]
end

# everything else - structs
function _index_shape(::Dims{2}, ::Type{T}, ::Type{I}, ::Type{<:Label}) where {I, T}
    (_index_shape(Dims(1), first_field_type(T), I)..., ScalarIndex())
end
function _index_shape(::Dims{2}, ::Type{T}, ::Type{I}, ::Type{<:Tuple{Vararg{Label}}}) where {I, T}
    (_index_shape(Dims(1), first_field_type(T), I)..., NonscalarIndex())
end
function _index_shape(::Dims{2}, ::Type{T}, ::Type{I}, ::Type{Colon}) where {I, T}
    (_index_shape(Dims(1), first_field_type(T), I)..., NonscalarIndex())
end
@pure function first_field_type(T::Type)
    T.types[1]
end


# =========
#  indices
# =========
@inline indices(t::Tabular{N}) where {N} = _indices(Dims(N), get(t))

# Series

@inline _indices(::Dims{1}, d::Associative) = ((keys(d)),)
# @inline _indices(::Dims{1}, v::AbstractVector{<:Pair}) = ((_map(first, v)),)

# Flat arrays...
@inline _indices(::Dims{1}, a::AbstractVector) = indices(a)
@inline _indices(::Dims{2}, a::AbstractMatrix) = indices(a)

# tuples of pairs
@inline _indices(::Dims{1}, t::Tuple{Vararg{Pair}}) = (_map(first, t),)

# everything else - structs
@inline _indices(::Dims{1}, t) = (field_indices(typeof(t)),)
@pure field_indices(::Type{T}) where {T} = (map(name -> Label{name}(), fieldnames(T))...)

# Tables

@inline function _indices(::Dims{2}, d::Associative)
    (_indices(Dims(1), first(values(d)))..., keys(d))
end

# @inline function _indices(::Dims{2}, x::AbstractVector{<:Pair}) where {N}
#     f = first(x).second
#     (_indices(Dims(1), f)..., _map(first, x))
# end

@inline function _indices(::Dims{2}, v::AbstractVector)
    (_indices(Dims(1), first(v))..., indices(v)...)
end

@inline function _indices(::Dims{2}, t::Tuple{Vararg{Pair}})
    (_indices(Dims(1), first(t).second)..., _map(first, t))
end

@inline function _indices(::Dims{2}, t)
    (_indices(Dims(1), getfield(t,1))..., field_indices(typeof(t)))
end

# ==========
#  Indexing
# ==========

@propagate_inbounds function getindex(t::Tabular{N}, i::Vararg{Any, N}) where N
    dims = Dims(index_shape(t, i...))
    data = _getindex(Dims(N), get(t), i...)
    if dims == 0
        return data
    else
        return Tabular{get(dims)}(data)
    end
end

@propagate_inbounds function setindex!(t::Tabular{N}, val, i::Vararg{Any, N}) where N
    if index_shape(t, i...) isa Tuple{Vararg{ScalarIndex}}
        _setindex!(Dims(N), t.data, val, i...)
    else
        error("Non-scalar setindex! has not yet been implemented.")
    end
    return val
end

# Series

# associatives
@propagate_inbounds function _getindex(::Dims{1}, dict::Associative{K}, i::K) where {K}
    dict[i]
end
@propagate_inbounds function _getindex(::Dims{1}, dict::Associative{K}, inds::AbstractVector{K}) where {K}
    return Dict(map(k -> Pair(k, dict[k]), inds))
end
@propagate_inbounds function _getindex(::Dims{1}, d::Associative, ::Colon)
    return copy(d)
end

@propagate_inbounds function _setindex!(::Dims{1}, dict::Associative{K}, val, i::K) where {K}
    dict[i] = val
end

# vectors
@propagate_inbounds function _getindex(::Dims{1}, v::AbstractVector, i::Integer)
    v[i]
end
@propagate_inbounds function _getindex(::Dims{1}, v::AbstractVector{T}, i::AbstractVector{I}) where {I <: Integer,T}
    # Unlike AbstractArray, must preserve index values (not just element values)
    # TODO: some sort-based dictionary would be better for this kind of data, 
    #       and might be very efficient for ranges
    d = Dict{I, T}()
    for ind ∈ i
        d[ind] = v[ind]
    end
    return d
end
@propagate_inbounds function _getindex(::Dims{1}, v::AbstractVector, ::Colon)
    v[:]
end

@propagate_inbounds function _setindex!(::Dims{1}, v::AbstractVector, val, i::Integer)
    v[i] = val
end

# tuples of pairs
@propagate_inbounds function _getindex(::Dims{1}, t::Tuple{Vararg{Pair}}, i)
    get_tuple_value(t, i)
end
@propagate_inbounds function _getindex(::Dims{1}, t::Tuple{Vararg{Pair}}, i::Label)
    get_tuple_value(t, i)
end
@propagate_inbounds function _getindex(::Dims{1}, t::Tuple{Vararg{Pair}}, inds::Tuple)
    _map(i -> get_tuple_pair(t, i), inds)
end
@propagate_inbounds function _getindex(::Dims{1}, t::Tuple{Vararg{Pair}}, inds::Tuple{Vararg{Label}})
    _map(i -> get_tuple_pair(t, i), inds)
end
@propagate_inbounds function _getindex(::Dims{1}, t::Tuple{Vararg{Pair}}, ::Colon)
    t
end

# everything else - structs
@inline function _getindex(::Dims{1}, x, ::Label{L}) where L
    getfield(x, L)
end
@inline function _getindex(::Dims{1}, x, inds::Tuple{Vararg{Label}})
    _map(l -> l => _getfield(x, l), inds)
end
@inline function _getindex(::Dims{1}, x, ::Colon)
    # Try return the same struct type when possible,
    # and make a copy since this isn't a view (x may be mutable)
    # Is this a good idea?
    # typeof(x)(_map(l -> _getfield(x, l), field_indices(typeof(x))))
    
    # or punt on that and just return a tuple:
    _getindex(Dims(1), x, field_indices(typeof(x)))
end
_getfield(x, ::Label{L}) where {L} = getfield(x, L)

@inline function _setindex!(::Dims{1}, x, val, ::Label{L}) where L
    setfield!(x, val, L)
end

# Table

# associatives
@propagate_inbounds function _getindex(::Dims{2}, dict::Associative{K}, i1, i2::K) where {K}
    _getindex(Dims(1), dict[i2], i1)
end
@propagate_inbounds function _getindex(::Dims{2}, dict::Associative{K}, i1, i2::AbstractVector{K}) where {K}
    @boundscheck if length(i2) == 0
        throw(IndexError("Expected at least one index"))
    end
    @inbounds first_ind = i2[1]
    first_data = _getindex(Dims(1), dict[first_ind], i1)
    V = typeof(first_data)
    out = similar(dict, Pair{K, V})
    out[first_ind] = first_data
    for j = 2:length(i2)
        @inbounds ind = i2[j]
        out[ind] = _getindex(Dims(1), dict[ind], i1)
    end
    return out
end
@propagate_inbounds function _getindex(::Dims{2}, dict::Associative{K}, i1, ::Colon) where {K}
    map(kv -> kv.first => _getindex(Dims(1), kv.second, i1), dict)
end

@propagate_inbounds function _setindex!(::Dims{2}, dict::Associative{K}, val, i1, i2::K) where {K}
    _setindex!(Dims(1), dict[i2], val, i1)
end

# vectors
@propagate_inbounds function _getindex(::Dims{2}, v::AbstractVector, i1, i2::Integer)
    _getindex(Dims(1), v[i2], i1)
end
@propagate_inbounds function _getindex(::Dims{2}, v::AbstractVector{T}, i1, i2::AbstractVector{I}) where {T, I<:Integer}
    # Unlike AbstractArray, must preserve index values (not just element values)
    # TODO: some sort-based dictionary would be better for this kind of data, 
    #       and might be very efficient for ranges
    # TODO: try avoid intermediate allocation
    vals = map(ind -> _getindex(Dims(1), v[ind], i1), i2)
    Dict(map((k,v) -> k=>v, i2, vals))
end
@propagate_inbounds function _getindex(::Dims{2}, v::AbstractVector, i1, ::Colon)
    map(x -> _getindex(Dims(1), x, i1), v)
end

@propagate_inbounds function _setindex!(::Dims{2}, v::AbstractVector, val, i1, i2::Integer)
    _setindex!(Dims(1), v[i2], val, i1)
end

# matrices
@propagate_inbounds function _getindex(::Dims{2}, m::AbstractMatrix, i1::Integer, i2::Integer)
    m[i1, i2]
end
@propagate_inbounds function _getindex(::Dims{2}, m::AbstractMatrix, i1::AbstractVector{<:Integer}, i2::Integer)
    vals = map(ind -> m[ind, i2], i1)
    Dict(map((k,v) -> k=>v, i1, vals))
end
@propagate_inbounds function _getindex(::Dims{2}, m::AbstractMatrix, i1::Colon, i2::Integer)
    m[i1, i2]
end
@propagate_inbounds function _getindex(::Dims{2}, m::AbstractMatrix, i1::Integer, i2::AbstractVector{<:Integer})
    vals = map(ind -> m[i1, ind], i2)
    Dict(map((k,v) -> k=>v, i2, vals))
end
@propagate_inbounds function _getindex(::Dims{2}, m::AbstractMatrix, i1::AbstractVector{<:Integer}, i2::AbstractVector{<:Integer})
    # Dict of Dicts - needs optimizing
    Dict([j2 => Dict([j1=>m[j1,j2] for j1 ∈ i1]) for j2 ∈ i2])
end
@propagate_inbounds function _getindex(::Dims{2}, m::AbstractMatrix, ::Colon, i2::AbstractVector{<:Integer})
    # Dict of vectors
    vals = map(ind -> m[:, ind], i2)
    Dict(map((k,v) -> k=>v, i2, vals))
end
@propagate_inbounds function _getindex(::Dims{2}, m::AbstractMatrix, i1::Integer, i2::Colon)
    m[i1, i2]
end
@propagate_inbounds function _getindex(::Dims{2}, m::AbstractMatrix, i1::AbstractVector{<:Integer}, ::Colon)
    # Vector of Dicts - needs optimizing
    [Dict([j1=>m[j1,j2] for j1 ∈ i1]) for j2 ∈ indices(m, 2)]
end
@propagate_inbounds function _getindex(::Dims{2}, m::AbstractMatrix, i1::Colon, i2::Colon)
    m[i1, i2]
end

@propagate_inbounds function _setindex!(::Dims{2}, m::AbstractMatrix, val, i1::Integer, i2::Integer)
    m[i1, i2] = val
end

# tuples of pairs
@propagate_inbounds function _getindex(::Dims{2}, t::Tuple{Vararg{Pair}}, other_inds, i)
    _getindex(Dims(1), get_tuple_value(t, i), other_inds)
end
@propagate_inbounds function _getindex(::Dims{2}, t::Tuple{Vararg{Pair}}, other_inds, i::Label)
    _getindex(Dims(1), get_tuple_value(t, i), other_inds)
end
@propagate_inbounds function _getindex(::Dims{2}, t::Tuple{Vararg{Pair}}, other_inds, this_inds::Tuple)
    _map(this_inds) do i
        kv = get_tuple_pair(t, i) 
        Pair(kv.first, _getindex(Dims(1), kv.second, other_inds))
    end
end
@propagate_inbounds function _getindex(::Dims{2}, t::Tuple{Vararg{Pair}}, other_inds, this_inds::Tuple{Vararg{Label}})
    _map(this_inds) do i
        kv = get_tuple_pair(t, i) 
        Pair(kv.first, _getindex(Dims(1), kv.second, other_inds))
    end
end
@propagate_inbounds function _getindex(::Dims{2}, t::Tuple{Vararg{Pair}}, other_inds, ::Colon)
    _map(kv -> Pair(kv.first, _getindex(Dims(1), kv.second, other_inds)), t)
end

@propagate_inbounds function _setindex!(::Dims{2}, t::Tuple{Vararg{Pair}}, val, other_inds, i)
    _setindex!(Dims(1), get_tuple_value(t, i), val, other_inds)
end

# everything else - structs
@inline function _getindex(::Dims{2}, x, i1, ::Label{L}) where L
    _getindex(Dims(1), getfield(x, L), i1)
end
@inline function _getindex(::Dims{2}, x, i1, inds::Tuple{Vararg{Label}})
    _map(l -> l => _getindex(Dims(1), _getfield(x, l), i1), inds)
end
@inline function _getindex(::Dims{2}, x, i1, ::Colon)
    # punt on trying to return the structs back
    _getindex(Dims(2), x, i1, field_indices(typeof(x)))
end

@inline function _setindex!(::Dims{2}, x, val, i1, ::Label{L}) where L
    _setindex!(Dims(1), getfield(x, L), val, i1)
end


# Tables are collections of rows:
@propagate_inbounds getindex(t::AbstractTable, i) = t[i, :]
@propagate_inbounds setindex!(t::AbstractTable, v, i) = (t[i, :] = v)


# """
#     Mutability(tabular)
#     Mutability(typeof(tabular))

# Returns `CanMutate()` if `setindex!` works with `tabular`, and `CannotMutate()` otherwise.
# In the latter case, `Tabulars.setindex` may be expected as a "functional" alternative to
# `setindex!`.
# """
# abstract type Mutability; end
# struct CanMutate; end
# struct CannotMutate; end

# # Maybe a trait for static indices??
# abstract type IndexType; end
# struct StaticIndices; end
# struct DynamicIndices; end

# """
#     TabularIndex

# An abstract type that represents a collection of indices of a tabular object.
# Each subtype of `Tabular` may define a corresponding `TabularIndex`, which will
# be used internally to construct new tabular objects during indexing and other
# operations.
# """
# abstract type TabularIndex; end
