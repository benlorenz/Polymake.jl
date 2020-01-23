@inline function Matrix{T}(rows::UR, cols::UR) where {T <: VecOrMat_eltypes, UR<:Base.AbstractUnitRange}
    return Matrix{T}(length(rows), length(cols))
end

@inline function Vector{T}(len::UR) where {T <: VecOrMat_eltypes, UR<:Base.AbstractUnitRange}
    return Vector{T}(length(len))
end

@inline function SparseMatrix{T}(rows::UR, cols::UR) where {T <: VecOrMat_eltypes, UR<:Base.AbstractUnitRange}
    return SparseMatrix{T}(length(rows), length(cols))
end

Base.similar(X::Union{Vector, Matrix}, ::Type{S}, dims::Dims{1}) where
    {S <: VecOrMat_eltypes} = Vector{convert_to_pm_type(S)}(dims...)

Base.similar(X::Union{Vector, Matrix}, ::Type{S}, dims::Dims{1}) where {S} = Base.Vector{S}(dims...)

Base.similar(X::Union{Vector, Matrix}, ::Type{S}, dims::Dims{2}) where
    {S <: VecOrMat_eltypes} = Matrix{convert_to_pm_type(S)}(dims...)

Base.similar(X::Union{Vector, Matrix}, ::Type{S}, dims::Dims{2}) where {S} = Base.Matrix{S}(dims...)

Base.similar(X::SparseMatrix, ::Type{S}, dims::Dims{2}) where
    {S <: VecOrMat_eltypes} = SparseMatrix{convert_to_pm_type(S)}(dims...)

Base.similar(X::SparseMatrix, ::Type{S}, dims::Dims{2}) where {S} = SparseMatrixCSC{S}(dims...)

Base.BroadcastStyle(::Type{<:Vector}) = Broadcast.ArrayStyle{Vector}()
Base.BroadcastStyle(::Type{<:Matrix}) = Broadcast.ArrayStyle{Matrix}()
Base.BroadcastStyle(::Type{<:SparseMatrix}) = Broadcast.ArrayStyle{SparseMatrix}()

function Base.similar(bc::Broadcast.Broadcasted{Broadcast.ArrayStyle{Vector}},
    ::Type{ElType}) where ElType
    return Vector{promote_to_pm_type(Vector, ElType)}(axes(bc)...)
end

function Base.similar(bc::Broadcast.Broadcasted{Broadcast.ArrayStyle{Matrix}},
    ::Type{ElType}) where ElType
    return Matrix{promote_to_pm_type(Matrix, ElType)}(axes(bc)...)
end

#SparseArrays.HigherOrderFns.SparseMatStyle{SparseMatrix}
function Base.similar(bc::Broadcast.Broadcasted{Broadcast.ArrayStyle{SparseMatrix}},
    ::Type{ElType}) where ElType
    return SparseMatrix{promote_to_pm_type(SparseMatrix, ElType)}(axes(bc)...)
end

#Overloading some of julia's broadcast functions to allow correct typing when
#broadcasting julia sparse matrices with polymake element type output
SparseVecOrMat{T} =
Union{SparseVector{T},SparseArrays.AbstractSparseMatrix{T}}

function Base.Broadcast.combine_eltypes(f::Tf,
args::Tuple{SparseVecOrMat{ElType},N}) where {N, Tf, ElType<:Union{Integer,
Rational}}
    any(isempty, args) && return Any
    x = first.(args)
    return typeof(f(x...))
end

function Base.Broadcast.combine_eltypes(f::Tf,
args::Tuple{SparseVecOrMat{ElType}}) where {Tf, ElType<:Union{Integer,
Rational}}
    any(isempty, args) && return Any
    x = first.(args)
    return typeof(f(x...))
end

function Base.Broadcast.combine_eltypes(f::Tf,
args::Tuple{SparseVecOrMat{ElType}}) where {Tf<:Union{Type{<:Integer},
Type{<:Rational}}, ElType}
    any(isempty, args) && return Any
    x = first.(args)
    return typeof(f(x...))
end
