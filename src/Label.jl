struct Label{Name}; end

@pure Label(name::Symbol) = Label{name}()

macro l_str(ex)
    return Label(Symbol(ex::String))
end

@pure (==)(::Label{Name}, ::Label{Name}) where {Name} = true
@pure (==)(::Label{Name1}, ::Label{Name2}) where {Name1, Name2} = false

show(io::IO, ::Label{Name}) where {Name} = print(io, "l\"$(Name)\"")
