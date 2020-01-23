@testset "Interface functions" begin
    for (args, val) in [((4,2), 5), ((Polymake.Integer(4), 2), 5)]
        @test call_function(:polytope, :pseudopower, args...) == val
        @test (@pm polytope.pseudopower(args...)) == val
        @test polytope.pseudopower(args...) == val
    end

    @test call_function(:polytope, :cube, 2) isa BigObject
    @test polytope.cube( 2 ) isa BigObject
    @test (@pm polytope.cube{Polymake.Rational}( 3 )) isa BigObject
    c = @pm polytope.cube{Polymake.Rational}( 3 )
    cc = polytope.cube( 3 )
    @test call_function(:polytope, :equal_polyhedra,c,cc)
    @test @pm polytope.equal_polyhedra(c, cc)
    @test polytope.equal_polyhedra(c, cc)

    @test tropical.cyclic(3,5,template_parameters=["Max"]) isa BigObject

    @test (@pm tropical.cyclic{Max}(3,5)) isa BigObject

    @test Base.Docs.getdoc(polytope.Polytope) isa Polymake.Meta.PolymakeDocstring
    @test Base.Docs.getdoc(polytope.cube) isa Polymake.Meta.PolymakeDocstring
end

@testset "Indexing helpers" begin
    X = [2, [2,3], Polymake.Set([3,2,2])]
    Y = [3, [3,4], Polymake.Set([4,3,3])]
    Z = [1, [1,2], Polymake.Set([2,1,1])]
    @test Polymake.to_one_based_indexing(X) == Y
    @test Polymake.to_zero_based_indexing(X) == Z

    to_ZERO = Polymake.to_zero_based_indexing
    to_ONE = Polymake.to_one_based_indexing

    I_types = [Polymake.Int, Polymake.Integer]; V_types = [Polymake.Vector, Polymake.Vector, Polymake.Array]; S_types = [Polymake.Set, Polymake.Set];

    for I in I_types, V in V_types, S in S_types
        i, v, s = X
        @test to_ONE([I(i), V(v), S(s)]) == Y
        @test to_ZERO([I(i), V(v), S(s)]) == Z
        @test to_ZERO(to_ONE([I(i), V(v), S(s)])) == X
        @test to_ONE(to_ZERO([I(i), V(v), S(s)])) == X
    end

    A = Polymake.Array{Polymake.Set{Int32}}([Polymake.Set(Int32[1,1,2]), Polymake.Set(Int32[2,3,1])])
    B = Polymake.Array{Polymake.Set{Int32}}([Polymake.Set(Int32[0,0,1]), Polymake.Set(Int32[1,2,0])])

    @test to_ZERO(A) == B
    @test to_ONE(B) == A
    @test_throws ArgumentError to_ZERO(B)
end
