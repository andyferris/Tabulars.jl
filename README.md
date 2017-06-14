# Tabulars

Flexible, multi-dimensional storage containers for Julia.

[![Build Status](https://travis-ci.org/andyferris/Tabulars.jl.svg?branch=master)](https://travis-ci.org/andyferris/Tabulars.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/7nx9q1b5ogrysafk?svg=true)](https://ci.appveyor.com/project/andyferris/tabulars-jl)
[![Coverage Status](https://coveralls.io/repos/andyferris/Tabulars.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/andyferris/Tabulars.jl?branch=master)
[![codecov.io](http://codecov.io/github/andyferris/Tabulars.jl/coverage.svg?branch=master)](http://codecov.io/github/andyferris/Tabulars.jl?branch=master)

This package introduces the `AbstractTabular` type and related
interface. Objects which are subtypes of `AbstractTabular{N}` (such as 1D-`Series` and
2D-`Table`) represent multi-dimensional maps from `N` index variables to an
element. This is similar to `AbstractArray`, excepting that the indices do not
need to be a contiguous set of integers such as `1:n`. In many senses this may
be considered a multi-dimensional generalization of `Associative` (however, we
tend to mimic the `AbstractArray` interface more closely, using `indices`
instead of `keys`, for instance).

Note that this package is a work-in-progress. Here is a simple example:

```
julia> using Tabulars

julia> t = Table(:Name => ["Alice", "Bob", "Eve"], :Evil => [false, false, true])
3×2 Table:
     Evil   Name
   ┌─────────────
 1 │ false  Alice
 2 │ false  Bob
 3 │ true   Eve

julia> t[1, :Name]
"Alice"
```

The constructor above creates a `Table` (itself an alias of
`Tabular{2}`, a concrete `AbstractTabular`) which stores columns indicated
by the symbols `:Name` and `:Evil`.
In this case a table which uses a nested storage pattern was created, without
modifying the input in any way.  In the above example, the
first dimensional (i.e. row) indices are inferred to be those of the provided
vectors, and the indices of each vector should be the same (like arrays, the 
indices of a tabular object should form a Cartesian/outer product).

## Goals

The goal of this package is to provide storage containers that can provide a
high degree of flexibility, power and expressiveness in representing data, while
approaching optimal machine performance. The general "trick" here is use a
lightweight wrapper which allows many different data containers to be
accessed through a uniform interface. `Tabular` has been taught how to access
arrays, associatives (dictionaries), tuples of pairs and even arbitrary Julia
structs. With your supplied data, and conveniences such as transposed views
of tables, an `AbstractTabular` can behave in a similar way to all of the
following

 * An `AbstractArray` or `Array`, where the indices might be a unit range.
 * A `Dict` layer wrapping arrays would provide storage similar to a `DataFrame`.
 * A tuple backed by singleton indices, which would allow type-stable, static
   indexing, like in *TypedTables*.
 * Structs-of-arrays and arrays-of-structs, differing by a simple transpose.
 * A "grouped" index, such as provided by Pandas `MultiIndex` (not implemented
   yet).
 * etc...

Given such a container, we can then work on providing methods for using such
containers like maps, filters, reductions, tabular joins, and so-forth.

## Approach

For clarity and simplicity we'll lay out some assumptions:

 * Like `AbstractArray`, the indices form a Cartesian product. (A direct sum of
   indices can be acheived by concatenation or a "grouped" index.) These are not
   generically shaped "ragged" arrays.
 * Within each dimension each index is unique.
 * Indices are an important part of the data and are therefore persistent - for
   example indexing a vector-series with a vector of `n` indices will preserve
   those indices, unlike standard vectors which return an object with indices `1:n`.
 * Code is focussed on `N=1` and `N=2` for the moment, but structures generally
   allow for arbitrary-dimensionality via nesting. We also haven't tried to extend to
   the zero dimensional case.
 * Lightweight approach to data structures - attempts not copy or wrap data unnecessarily,
   and defer to the container's implementation of `map` and so-on wherever possible.

## Tabular types

While the user primarily interacts with the abstract types `Series` and `Table`,
there are many specialized `getindex` which compose and nest to allow access to
a rich set of data structures, such as:

 * `AbstractArray`: An array wrapped up in a tabular
   structure - in many respects it behaves quite similarly to an `AbstractArray`,
   however it does not support linear indexing (e.g. `Table` must *always*
   be indexed by two values). A `Table` may contain a flat matrix, or it
   may contain a vector of nested vectors, e.g.
   `Table([1 2; 3 4]) == Table([[1,3],[2,4]])`.
 * `Dict` and other `Associative`s: By wrapping a dictionary of columns with
   `Table`, we can access the data much like a `DataFrame`. Unlike `Associative`,
   these support indexing with `:` and vectors of keys. 
 * `Tuple{Vararg{Pair}}`: Tuples of `Pair`s wrapped in a tabular
   structure. Unlike other containers, these may contain heterogenously-typed
   data and present it in a type-stable fashion. For this to work, the indices
   must be singleton types (the constructors automatically detect this). The
   package provides the singleton `Label` string type, which can be constructed
   with `l"Name"`. For example, a strongly-typed table can be made via
   `Table(l"Name" => ["Alice", "Bob"], l"Age" => [28, 35])` - much more convenient
   than *TypedTables.jl*.
 * Arbitrary types: Automatically deconstructs any Julia struct into a series or table,
   which may be indexed via a `Label`. For example `s = Series(2+3im)`, where
   `s[l"re"] == 2` and `s[l"im"] == 3`. Also `Table([1+2im, 3+4im])` will
   deconstruct the vector into columns of real and imaginary components (similarly for
   `Colors.RGB` or any other data that you may be working with). Like tuples, these
   support heterogenously-typed data by using static `Label` strings to reference the indices.

There is also a `PermutedDimsTabular` which differs from `Tabular` only in the
order the indices are applied to the (possibly nesting) data structures. 
Transposing a table stored as an array-of-structs will effectively present a 
view which looks like a struct-of-arrays, and vice-versa. This is generally used
via the transpose operator `.'` or simply  `'`, **which is non-recursive in both cases**.

All of these can be mixed in a variety of ways, and inner structures
are treated equal to outer structures and are always indexed in an appropriate way 
for arrays, associatives, tuples and structs. All support indexing with single indices, colon `:`, or
collections of indices (vectors and tuples). 
Some more structures which seem desirable are:

 * Grouped indices, for supporting common group-by operations.
 * Sub-tabulars, for views and filtering.
 * Ordered tabulars, where indexing is accelearted via sort-ordering rather than
   hashing *a la* `Dict`. Not sure if this is a new `Tabular`, or a new
   `Associative`.
 * The transpose of a series (like `RowVector`)? Similarly, columns and rows
   (being series with a *single* row/column index attached)?

## Operations

Ideally, this package would support a variety of *primitive* operations on
`Tabular`s, such as maps, reductions, filtering and grouping. However, the goal
isn't to construct an entire querying front-end. This is still a WIP.
