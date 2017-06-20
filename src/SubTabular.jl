struct SubTabular{N, I<:Tuple, D} <: AbstractTabular{N}
    indices::I
    data::D
end

const SubSeries{I <: Tuple, D} = SubTabular{1,I,D}
const SubTable{I <: Tuple, D} = SubTabular{2,I,D}

SubTabular{N}(indices::I, data::D) where {N,I,D} = SubTabular{N,I,D}(indices, data)

# function aresubindices(new_inds::NTuple{N,Any}, data) where {N}
#     old_inds = _indices(Dims(N), data)
#     shape = index_shape(Dims(N), new_inds, data)
#     
#     return all(_map(issubindex, shape, old_inds, new_inds))
# end

@inline function indices(t::SubTabular{N}) where {N}
    full_inds = _indices(Dims(length(t.indices)), t.data)
    subshape = index_subshape(t)
    if subshape === (NonscalarIndex(),)
        return (replace_colon(t.indices[1], full_inds[1]),)
    elseif subshape === (NonscalarIndex(), ScalarIndex())
        return (replace_colon(t.indices[1], full_inds[1]),)
    elseif subshape === (ScalarIndex(), NonscalarIndex())
        return (replace_colon(t.indices[2], full_inds[2]),)
    elseif subshape === (NonscalarIndex(), NonscalarIndex())
        return (replace_colon(t.indices[1], full_inds[1]), replace_colon(t.indices[2], full_inds[2]))
    else
        error("Index subshape = $subshape")  
    end
end

replace_colon(::Colon, fullindex) = fullindex
replace_colon(subindex, fullindex) = subindex

issubindex(::ScalarIndex, i, inds) = i ∈ inds
issubindex(::NonscalarIndex, i, inds) = i ⊆ inds
issubindex(::NonscalarIndex, ::Colon, inds) = true
issubindex(::NonscalarIndex, i, ::Colon) = true # TODO error("Unsure")
issubindex(::NonscalarIndex, ::Colon, ::Colon) = true


# inject_indices(::Tuple{ScalarIndex}, ::Tuple{}, old_inds) = old_inds
@inline function inject_indices(::Tuple{NonscalarIndex}, new_inds::Tuple{Any}, old_inds)
    @boundscheck if !issubindex(NonscalarIndex(), new_inds[1], old_inds[1])
        throw(IndexError("Indices $(new_inds[1]) not found in Tabular"))
    end
    if new_inds isa Tuple{Colon}
        return old_inds
    else
        return new_inds
    end
end

# inject_indices(::Tuple{ScalarIndex,ScalarIndex}, ::Tuple{}, old_inds) = old_inds
@inline function inject_indices(::Tuple{NonscalarIndex,ScalarIndex}, new_inds::Tuple{Any}, old_inds)
    @boundscheck if !issubindex(NonscalarIndex(), new_inds[1], old_inds[1])
        throw(IndexError("Indices $(new_inds[1]) not found in Tabular"))
    end
    if new_inds isa Tuple{Colon}
        return old_inds
    else
        return (new_inds[1], old_inds[2])
    end
end
@inline function inject_indices(::Tuple{ScalarIndex,NonscalarIndex}, new_inds::Tuple{Any}, old_inds)
    @boundscheck if !issubindex(NonscalarIndex(), new_inds[1], old_inds[2])
        throw(IndexError("Indices $(new_inds[1]) not found in Tabular"))
    end
    if new_inds isa Tuple{Colon}
        return old_inds
    else
        return (old_inds[1], new_inds[1])
    end
end
@inline function inject_indices(::Tuple{NonscalarIndex,NonscalarIndex}, new_inds::Tuple{Any,Any}, old_inds)
    @boundscheck if !issubindex(NonscalarIndex(), new_inds[1], old_inds[1])
        throw(IndexError("Indices $(new_inds[1]) not found in Tabular"))
    end
    @boundscheck if !issubindex(NonscalarIndex(), new_inds[2], old_inds[2])
        throw(IndexError("Indices $(new_inds[2]) not found in Tabular"))
    end
    if new_inds isa Tuple{Colon, Any}
        if new_inds isa Tuple{Colon, Colon}
            return old_inds
        else
            return (old_inds[1], new_inds[2])
        end
    else
        if new_inds isa Tuple{Any, Colon}
            return (new_inds[1], old_inds[2])
        else
            return new_inds
        end
    end
end

# Helper function to get shape of subindices with respect to the full structure
function index_subshape(s::SubSeries)
    if length(s.indices) === 1
        return _index_shape(Dims(1), typeof(s.data), typeof(s.indices[1]))
    else
        return _index_shape(Dims(2), typeof(s.data), typeof(s.indices[1]), typeof(s.indices[2]))
    end
end
function index_subshape(s::SubTable)
    _index_shape(Dims(2), typeof(s.data), typeof(s.indices[1]), typeof(s.indices[2]))
end

index_shape(s::SubSeries, ::Any) = (ScalarIndex(),)
index_shape(s::SubSeries, ::AbstractVector) = (NonscalarIndex(),)
index_shape(s::SubSeries, ::Colon) = (NonscalarIndex(),)

index_shape(s::SubTable, ::Any, ::Any) = (ScalarIndex(), ScalarIndex())
index_shape(s::SubTable, ::AbstractVector, ::Any) = (NonscalarIndex(), ScalarIndex())
index_shape(s::SubTable, ::Colon, ::Any) = (NonscalarIndex(), ScalarIndex())
index_shape(s::SubTable, ::Any, ::AbstractVector) = (ScalarIndex(), NonscalarIndex())
index_shape(s::SubTable, ::AbstractVector, ::AbstractVector) = (NonscalarIndex(), NonscalarIndex())
index_shape(s::SubTable, ::Colon, ::AbstractVector) = (NonscalarIndex(), NonscalarIndex())
index_shape(s::SubTable, ::Any, ::Colon) = (ScalarIndex(), NonscalarIndex())
index_shape(s::SubTable, ::AbstractVector, ::Colon) = (NonscalarIndex(), NonscalarIndex())
index_shape(s::SubTable, ::Colon, ::Colon) = (NonscalarIndex(), NonscalarIndex())



#@inline function index_shape(s::SubSeries, i1)
#    inds = indices[i1]
    
#    subshape = index_subshape(s)


#    fullinds = _indices(Dims(N), t.data)
#    subinds = inject_indices((i1,) fullinds)
#    _index_shape(Dims(length(fullinds)), typeof(t.data), typeof(subinds[1]))
#end

# function index_shape(t::SubSeries, i1, i2)
#     fullinds = _indices(Dims(N), t.data)
#     subinds = inject_indices((i1,i2), fullinds)
#     _index_shape(Dims(length(fullinds)), typeof(t.data), typeof(subinds[1]), typeof(subinds[2]))    
# end

@propagate_inbounds function getindex(s::SubSeries, i)
    inds = inject_indices(index_subshape(s), (i,), s.indices)#, _indices(Dims(length(s.indices)), s.data))
    if length(inds) === 1
        shape = _index_shape(Dims(length(inds)), typeof(s.data), typeof(inds[1]))
    elseif length(inds) === 2
        shape = _index_shape(Dims(length(inds)), typeof(s.data), typeof(inds[1]), typeof(inds[2]))
    end
    data = _getindex(Dims(length(inds)), s.data, inds...)
    if shape isa Tuple{Vararg{ScalarIndex}}
        return data
    else
        return Series(data)
    end
end
@propagate_inbounds function getindex(t::SubTable, i1, i2)
    inds = inject_indices(index_subshape(t), (i1,i2), t.indices)#, _indices(Dims(length(t.indices)), t.data))
    shape = _index_shape(Dims(length(inds)), typeof(t.data), typeof(inds[1]), typeof(inds[2]))
    data = _getindex(Dims(length(inds)), t.data, inds[1], inds[2])
    if shape[1] isa ScalarIndex
        if shape[2] isa ScalarIndex
            return data
        else
            return Series(data)
        end
    else
        if shape[2] isa ScalarIndex
            return Series(data)
        else
            return Table(data)
        end
    end
end


@propagate_inbounds function setindex!(t::SubTabular{N}, val, i::Vararg{Any, N}) where N
    inds = inject_indices(index_subshape(t), i, t.indices)
    if length(inds) === 1
        shape = _index_shape(Dims(length(inds)), typeof(t.data), typeof(inds[1]))
    else
        shape = _index_shape(Dims(length(inds)), typeof(t.data), typeof(inds[1]), typeof(inds[2]))
    end

    if shape isa Tuple{Vararg{ScalarIndex}}
        _setindex!(Dims(length(inds)), t.data, val, inds...)
    else
        error("Non-scalar setindex! has not yet been implemented.")
    end
    return val
end



@inline function view(s::Series, i)
    shape = index_shape(s, i)
    
    if shape[1] == ScalarIndex()
        throw("Cannot take the view of a scalar index")
    end

    # Check if all indices in `i` are a part of the original indices
    @boundscheck begin
        if !(issubindex(NonscalarIndex(), i, indices(s)[1]))
            throw(IndexError("Indices $i are not in the input Series"))
        end
    end

    return SubSeries((i,), s.data)
end
@inline function view(s::SubSeries, i)
    subshape = index_subshape(s)
    shape = index_shape(s, i)

    if shape[1] == ScalarIndex()
        throw("Cannot take the view of a scalar index")
    end

    # Check if all indices in `i` were a part of the original indices
    @boundscheck begin
        if !(issubindex(NonscalarIndex(), i, indices(s)[1]))
            throw(IndexError("Indices $i are not in the input Series"))
        end
    end
    
    if subshape === (NonscalarIndex(),) 
        if i isa Colon
            return SubSeries((indices(s)[1],), s.data)
        else
            return SubSeries((i,), s.data)
        end
    elseif subshape === (NonscalarIndex(), ScalarIndex())
        if i isa Colon
            return SubSeries((indices(s)[1], s.indices[2]), s.data)
        else
            return SubSeries((i, s.indices[2]), s.data)
        end
    elseif subshape === (ScalarIndex(), NonscalarIndex())
        if i isa Colon
            return SubSeries((s.indices[1], indices(s)[1]), s.data)
        else
            return SubSeries((s.indices[1], i), s.data)
        end
    end
end

@inline function view(t::Table, i1, i2)
    shape = index_shape(t, i1, i2)

    @boundscheck begin
        inds = indices(t)
        if !issubindex(shape[1], replace_colon(i1, inds[1]), inds[1])
            throw(IndexError("Indices $i1 are not in the input Table columns"))
        end    
        if !issubindex(shape[2], i2, inds[2])
            throw(IndexError("Indices $i2 are not in the input Table rows"))
        end
    end

    if shape[1] == ScalarIndex()
        if shape[2] == ScalarIndex()
            throw("Cannot take the view of a scalar index")
        else
            SubSeries((i1, i2), t.data)
        end
    else
        if shape[2] == ScalarIndex()
            SubSeries((i1, i2), t.data)
        else
            SubTable((i1, i2), t.data)
        end
    end
end

@inline function view(t::SubTable, i1, i2)
    shape = index_shape(t, i1, i2)

    @boundscheck begin
        # Don't need the output, but this will check for inclusion
        inject_indices(index_subshape(t), (i1,i2), indices(t))
    end

    if shape[1] == ScalarIndex()
        if shape[2] == ScalarIndex()
            throw("Cannot take the view of a scalar index")
        else
            if i2 isa Colon
                SubSeries((i1, t.indices[2]), t.data)
            else
                SubSeries((i1, i2), t.data)
            end
        end
    else
        if shape[2] == ScalarIndex()
            if i1 isa Colon
                SubSeries((indices(t)[1], i2), t.data)
            else
                SubSeries((i1, i2), t.data)
            end
        else
            if i1 isa Colon
                if i2 isa Colon
                    SubTable(indices(t), t.data)
                else
                    SubTable((indices(t)[1], i2), t.data)
                end
            else
                if i2 isa Colon
                    SubTable((i1, indices(t)[2]), t.data)
                else
                    SubTable((i1, i2), t.data)
                end
            end
        end
    end
end