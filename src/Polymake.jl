module Polymake

export pm_Integer, pm_Matrix,
    pm_perl_Object, pm_perl_PropertyValue,
    pm_Rational, pm_Set, pm_Vector


# We need to import all functions which will be extended on the Cxx side
import Base: ==, <, <=, *, -, +, /, div, rem,
    append!, delete!, numerator, denominator,
    empty!, getindex, in, intersect, intersect!, isempty,
    length, numerator, push!,
    setdiff, setdiff!, setindex!, symdiff, symdiff!,
    union, union!

using CxxWrap


###########################
# Load Cxx stuff and init
##########################

@static if Sys.isapple()
    @wrapmodule(joinpath(@__DIR__, "..", "deps", "src", "libpolymake.dylib"),
        :define_module_polymake)
elseif Sys.islinux()
    @wrapmodule(joinpath(@__DIR__, "..", "deps", "src", "libpolymake.so"),
        :define_module_polymake)
else
    error("System is not supported!")
end

const C_TYPES = [
   ("pm_perl_PropertyValue", pm_perl_PropertyValue),
   ("pm_perl_OptionSet", pm_perl_OptionSet),
   ("pm_perl_Object", pm_perl_Object),
   ("pm_Integer", pm_Integer),
   ("pm_Rational", pm_Rational),
   ("pm_Matrix_pm_Integer", pm_Matrix{pm_Integer}),
   ("pm_Matrix_pm_Rational", pm_Matrix{pm_Rational}),
   ("pm_Vector_pm_Integer", pm_Vector{pm_Integer}),
   ("pm_Vector_pm_Rational", pm_Vector{pm_Rational}),
   ("pm_Set_Int64", pm_Set{Int64}),
   ("pm_Set_Int32", pm_Set{Int32})
]

function __init__()
    @initcxx
    initialize_polymake()
    application("polytope")

    # We need to set the Julia types as c types for polymake
    for (name, c_type) in C_TYPES
        current_type = Ptr{Cvoid}(pointer_from_objref(c_type))
        set_julia_type(name, current_type)
    end
end

const SmallObject = Union{pm_Integer, pm_Rational, pm_Matrix, pm_Vector, pm_Set}

include("functions.jl")
include("convert.jl")
include("integers.jl")
include("rationals.jl")
include("sets.jl")
include("vectors.jl")
include("matrices.jl")
include("generated/includes.jl")

end # of module Polymake
