# Iteration occurs as a nested container

# Series
@inline start(s::AbstractSeries) = start(indices(s)[1])
@inline function next(s::AbstractSeries, i) 
    (ind, i) = next(indices(s)[1], i)
    @inbounds return (s[ind], i)
end
@inline done(s::AbstractSeries, i) = done(indices(s)[1], i)

@inline length(s::AbstractSeries) = length(indices(s)[1])
@inline endof(s::AbstractSeries) = last(indices(s)[1])

# Tables iterate rows as series
@inline start(t::AbstractTable) = start(indices(t)[1])
@inline function next(t::AbstractTable, i)
    (ind, i) = next(indices(t)[1], i)
    @inbounds return (t[ind, :], i)
end
@inline done(t::AbstractTable, i) = done(indices(t)[1], i)

@inline endof(t::AbstractTable) = last(indices(t)[1]) # not type stable
@inline endof(t::AbstractTable, i::Int) = last(indices(t)[i]) # not type stable
@inline endof(t::AbstractTable, ::Type{Val{i}}) where {i} = last(indices(t)[i::Int])

@inline length(t::AbstractTable) = length(indices(t)[1])

