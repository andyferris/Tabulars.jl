# Tabulars

Flexible, multi-dimensional storage containers for Julia.

[![Build Status](https://travis-ci.org/andyferris/Tabulars.jl.svg?branch=master)](https://travis-ci.org/andyferris/Tabulars.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/7nx9q1b5ogrysafk?svg=true)](https://ci.appveyor.com/project/andyferris/tabulars-jl)
[![Coverage Status](https://coveralls.io/repos/andyferris/Tabulars.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/andyferris/Tabulars.jl?branch=master)
[![codecov.io](http://codecov.io/github/andyferris/Tabulars.jl/coverage.svg?branch=master)](http://codecov.io/github/andyferris/Tabulars.jl?branch=master)

This package introduces the `Tabular` abstract type and related
interface. Objects which are subtypes of `Tabular{N}` (such as 1D-`Series` and
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

The constructor above creates a (subtype of) `Table` (itself an alias of
`Tabular{2}`) which stores columns indicated by the symbols `:Name` and `:Evil`.
In this case a `DictTable` was created, which uses a nested storage pattern:
many concrete `Tabular{N}` keeps the `N`th dimensional indices and a collection
of `Tabular{N-1}` objects (with *identical indices*). In the above example, the
first dimensional (i.e. row) indices are inferred to be those of the provided
vectors, which themselves are wrapped in an `ArraySeries` internally (to help
with modularity).

## Goals

The goal of this package is to provide storage containers that can provide a
high degree of flexibility, power and expressiveness in representing data, while
approaching optimal machine performance. The general "trick" here is use a
modular structure where containers can leverage off each other. Used together,
a `Tabular` can be a bit like all of the following:

 * An `AbstractArray` or `Array`, where the indices might be a unit range.
 * A `Dict` layer wrapping arrays would provide storage like a `DataFrame`.
 * A tuple backed by singleton indices, which would allow type-stable, static
   indexing, like in *TypedTables*.
 * A "grouped" index, such as provided by Pandas `MultiIndex` (not implemented
   yet).
 * etc...

Given such a container, we can then work on providing methods for using such
containers like maps, filters, tabular joins, and so-forth.

## Approach

For clarity and simplicity we'll lay out some assumptions:

 * Like `AbstractArray`, the indices form a Cartesian product. (A direct sum of
   indices can be acheived by concatenation or a "grouped" index.) These are not
   generically shaped "ragged" arrays.
 * Within each dimension each index is unique.
 * Code is focussed on `N=1` and `N=2` for the moment, but structures generally
   allow for arbitray-dimensionality via nesting. We also won't try to extend to
   the zero dimensional case (for the moment).

## Tabular types

While the user primarily interacts with the abstract types `Series` and `Table`,
there are many specialized types of `Tabular` that compose and nest to create a
rich set of data structures. Currently we have:

 * `ArraySeries` and `ArrayTable`: An `AbstractArray` wrapped up in a tabular
   structure. In many respects it behaves quite similarly to an `AbstractArray`,
   however it does not support linear indexing (e.g. `ArrayTable` must *always*
   be indexed by two values). An `ArrayTable` may contain a flat matrix, or it
   may contain a vector of nested `Series`. Convenient constructors will
   automatically wrap the elements in a `Series`, if necessary.
 * `DictSeries` and `DictTable`: Wrappers of `Associative` containers. For a
   `DictTable`, the elements will be nested `Series`. Supports indexing with `:`
   and vectors of keys.
 * `TupleSeries` and `TupleTable`: Tuples of `Pair`s wrapped in a tabular
   structure. Unlike other containers, these may contain heterogenously-typed
   data and present it in a type-stable fashion. For this to work, the indices
   must be singleton types. The package provides the `Label` string type, which
   can be constructed with `l"Name"`. For example, a strongly-typed table can be
   made via `Table(l"Name" => ["Alice", "Bob"], l"Age" => [28, 35])`.
 * `StructSeries`: Automatically deconstructs any Julia struct into a series,
   which may be indexed via a `Label`. For example `Series(2+3im)[l"re"] === 2`.
 * `PermutedDimsTabular`: used to create a view of a transposed table, where the
   row and column indices are reversed.

These can be mixed in a variety of ways, and for convenience, inner structures
will automatically be wrapped in the appropriate type for arrays, associatives,
tuples and structs. Transposing a table stored as an array-of-structs will
effectively present a view which looks like a struct-of-arrays.

Some more structures which seem desirable:

 * Grouped indices, for supporting common group-by operations
 * Sub-tabulars, for views and filtering.
 * Ordered tabulars, where indexing is accelearted via sort-ordering rather than
   hashing *a la* `Dict`. Not sure if this is a new `Tabular`, or a new
   `Associative`.
 * The transpose of a series? Columns and rows (being series with a *single*
   row/column index attached)?

## Operations

Ideally, this package would support a variety of *primitive* operations on
`Tabular`s, such as maps, reductions, filtering and grouping. However, the goal
isn't to construct an entire querying front-end.
