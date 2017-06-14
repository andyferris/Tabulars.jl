@inline length(s::AbstractSeries) = length(indices(s)[1])

# Pretty sure this one doesn't make sense:
# @inline length(s::AbstractTable) = (inds = indices(s); length(inds[1])*length(inds[2]))

@inline endof(s::AbstractSeries) = last(indices(s)[1])
@inline endof(t::AbstractTabular, i::Int) = last(indices(t)[i]) # not type stable
@inline endof(t::AbstractTabular, ::Type{Val{i}}) where {i} = last(indices(t)[i::Int])

# Series
start(s::AbstractSeries) = start(indices(s)[1])
next(s::AbstractSeries, i) = next(indices(s)[1], i)
done(s::AbstractSeries, i) = done(indices(s)[1], i)
