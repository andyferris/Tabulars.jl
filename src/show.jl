function compact_string(x)
    io = IOContext(IOBuffer(), :compact, true)
    print(io, x)
    return String(io.io)
end

show(io::IO, ::MIME"text/plain", s::Series) = show_series(io, s)
function show_series(io::IO, s::ANY)
    inds = collect(indices(s)[1])::Vector
    len = length(inds)::Int

    if len == 0
        print(io, "0-element Series")
        return
    end

    print(io, len, "-element Series:")

    max_show_rows = 5

    if len <= max_show_rows
        ind_strings = map(compact_string, inds)::Vector{String}
        val_strings = map(i -> compact_string(s[i]), inds)::Vector{String}
    else
        ind_strings = String[compact_string(inds[i]) for i ∈ 1:max_show_rows]
        val_strings = String[compact_string(s[inds[i]]) for i ∈ 1:max_show_rows]
    end

    max_ind_len = maximum(length, ind_strings)
    max_val_len = maximum(length, val_strings)

    if len > max_show_rows
        push!(ind_strings, (" " ^ div(max_ind_len-1, 2)) *  "⋮")
        push!(val_strings, (" " ^ div(max_val_len-1, 2)) *  "⋮")
    end

    for i ∈ 1:length(ind_strings)
        print(io, "\n ")
        @inbounds ind_str = ind_strings[i]
        print(io, ind_str)
        n_spaces = max_ind_len - length(ind_str)
        if n_spaces > 0
            print(io, " " ^ n_spaces)
        end
        print(io, " │ ")
        @inbounds val_str = val_strings[i]
        print(io, val_str)
        #n_spaces = length(val_strings[i]) - max_val_len
        #if n_spaces > 0
        #    print(io, " " ^ n_spaces)
        #end
    end
end

show(io::IO, ::MIME"text/plain", t::Table) = show_table(io, t)
function show_table(io::IO, t::ANY)
    inds = indices(t)
    row_inds = collect(inds[1])::Vector
    col_inds = collect(inds[2])::Vector
    nrows = length(row_inds)::Int
    ncols = length(col_inds)::Int

    if nrows == 0 | ncols == 0
        print(io, "$nrows×$ncols Table")
        return
    end

    print(io, nrows, "×", ncols, " Table:")

    max_show_rows = 5

    strings = Vector{Vector{String}}(ncols+1)
    for i ∈ 1:(ncols + 1)
        for j ∈ 1:(min(max_show_rows, nrows) + 1)
            if j == 1
                if i == 1
                    strings[i] = [""]
                else
                    strings[i] = [compact_string(col_inds[i-1])]
                end
            else
                if i == 1
                    push!(strings[i], compact_string(row_inds[j-1]))
                else
                    push!(strings[i], compact_string(t[row_inds[j-1], col_inds[i-1]]))
                end
            end
        end
    end

    max_column_lengths = [maximum(length, str_vec) for str_vec ∈ strings]

    if nrows > max_show_rows
        for i ∈ 1:length(strings)
            push!(strings[i], (" " ^ div(max_column_lengths[i]-1, 2)) *  "⋮")
        end
    end

    # Now produce output

    # Header: " --  Column1  Column2"
    print(io, "\n ")
    n_spaces = max_column_lengths[1] + 3
    print(io, " " ^ n_spaces)
    for i ∈ 2:length(strings)
        @inbounds col_str = strings[i][1]
        print(io, col_str)
        if i != length(strings)
            n_spaces = max_column_lengths[i] - length(col_str) + 2
            print(io, " " ^ n_spaces)
        end
    end

    # Seperator: " ┌────────"
    print(io, "\n ")
    print(io, " " ^ max_column_lengths[1])
    print(io, " ┌─")
    for i = 2:length(strings)
        print(io, "─" ^ (max_column_lengths[i] + 2))
    end

    # Body " rowind │ val1  val2"
    for j = 2:length(strings[1])
        print(io, "\n ")
        @inbounds row_str = strings[1][j]
        print(io, row_str)
        n_spaces = max_column_lengths[1] - length(row_str)
        if n_spaces > 0
            print(io, " " ^ n_spaces)
        end
        print(io, " │ ")

        for i = 2:length(strings)
            @inbounds val_str = strings[i][j]
            print(io, val_str)

            if i != length(strings)
                n_spaces = max_column_lengths[i] - length(val_str) + 2
                print(io, " " ^ n_spaces)
            end
        end
    end
end
