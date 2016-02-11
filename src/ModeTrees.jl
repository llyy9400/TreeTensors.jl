export ModeTree, ModeTree!, link!, tree, mode


# Data structure

typealias ModeDict Dict{Tree,Vector{Mode}}
immutable ModeTree
    tree::Tree
    free_modes::ModeDict
end


# Basic functions

tree(t::ModeTree) = t.tree
for f in (:getindex, :setindex!) @eval $f(x::ModeTree, args...) = $f(x.free_modes, args...) end


# Tree construction

function ModeTree!(children::Vector{ModeTree}, free_modes::Vector{Mode})
    r = Tree!([tree(u) for u in children]...)
    D = merge!(ModeDict(r => copy(free_modes)), [u.free_modes for u in children]...)
    return ModeTree(r,D)
end
ModeTree!(children::ModeTree...) = ModeTree!(ModeTree[children...], Mode[])
function ModeTree!(free_modes::Vector{Mode})
    r = Tree()
    D = ModeDict(r => free_modes)
    return ModeTree(r,D)
end
ModeTree(children::Vector{ModeTree}, free_modes::Vector{Mode}) = ModeTree!(deepcopy(children), free_modes)
ModeTree(children::ModeTree...) = ModeTree([children...], Mode[])

function link!(v::ModeTree, u::ModeTree)
    link!(tree(v), tree(u))
    merge!(v.free_modes, u.free_modes)
    return v
end


# Other

function Tensors.mode(t::ModeTree)
    modes = Mode[]
    for D in values(t.free_modes) append!(modes, D) end
    return modes
end