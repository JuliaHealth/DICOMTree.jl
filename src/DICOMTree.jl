module DICOMTree
import Term.Trees: Tree, TreeCharSet, print_node, print_key, Theme, TERM_THEME, _TREE_PRINTING_TITLE
import Term.Style: apply_style
using DICOM

export Tree

function apply_style(text::AbstractString, style::String)
    text = convert(String, text)
    apply_style(text, style)
end

function get_name_from_tag(gelt::Tuple{UInt16,UInt16})
    if gelt[1] & 0xff00 == 0x5000
        gelt = (0x5000, gelt[2])
    elseif gelt[1] & 0xff00 == 0x6000
        gelt = (0x6000, gelt[2])
    end
    r = get(DICOM.dcm_dict, gelt, DICOM.empty_vr_lookup)

    (r[1] == "") ? (return gelt) : (return r[1])
end


"""
    Tree(
        tree;
        with_keys::Bool = false,
        guides::Union{TreeCharSet,Symbol} = :standardtree,
        theme::Theme = TERM_THEME[],
        printkeys::Union{Nothing,Bool} = true,
        print_node_function::Function = print_node,
        print_key_function::Function = print_key,
        title::Union{String, Nothing}=nothing,
        prefix::String = "  ",
        kwargs...,
    )

Constructor for `Tree`

It uses `AbstractTrees.print_tree` to get a string representation of `tree` (any object
compatible with the `AbstractTrees` packge). Applies style to the string and creates a 
renderable `Tree`.

Arguments:
- `tree`: anything compatible with `AbstractTree`
- 'with_keys': if `true` print DICOM keys (e.g. : (0x0010, 0x0020)). If `false`, print DICOM tags( e.g. : PatientID).
- `guides`: if a symbol, the name of preset tree guides types. Otherwise an instance of
    `AbstractTrees.TreeCharSet`
- `theme`: `Theme` used to set tree style.
- `printkeys`: If `true` print keys. If `false` don't print keys. 
- `print_node_function`: Function used to print nodes.
- `print_key_function`: Function used to print keys.
- `title`: Title of the tree.
- `prefix`: Prefix to be used in `AbstractTrees.print_tree`


For other kwargs look at `AbstractTrees.print_tree`
"""
function Tree(
    dicom::DICOM.DICOMData;
    with_keys::Bool=false,
    guides::Union{TreeCharSet,Symbol}=:standardtree,
    theme::Theme=Theme(tree_max_leaf_width=displaysize(stdout)[2]),
    printkeys::Union{Nothing,Bool}=true,
    print_node_function::Function=print_node,
    print_key_function::Function=print_key,
    title::Union{String,Nothing}="",
    prefix::String="  ",
    kwargs...
)
    _TREE_PRINTING_TITLE[] = title
    _theme = TERM_THEME[]
    TERM_THEME[] = theme

    md = haskey(kwargs, :maxdepth) ? kwargs[:maxdepth] : 2

    format(x, md) = x

    function format(x::AbstractArray, md)::Tree
        return (Tree(Dict("Size" => string(size(x)), "Type" => typeof(x)),
            guides=guides,
            title="Array",
            maxdepth=md))
    end

    function format(x::Vector, md)::Tree
        if length(x) <= 6
            return Tree(string(x), guides=guides)
        else
            return Tree(Dict("Length" => length(x),
                    "ElementsType" => eltype(x),
                    "Overview" => string(x[begin:begin+2])[1:end-1] * ", ..., " * string(x[end-3:end-1])[2:end]), guides=guides, title="Vector", maxdepth=md)
        end
    end

    function format(x::DICOM.DICOMData, md)::Tree
        return Tree(x.meta, guides=guides, title="", maxdepth=md)
    end

    function format(x::Vector{DICOM.DICOMData}, md)::Tree
        if md >= 2
            return Tree(Tree.(x, with_keys=with_keys, guides=guides, title="", maxdepth=md), guides=guides, title="", maxdepth=md)
        else
            return Tree(Dict("Length" => length(keys(x))), guides=guides, title="Vector of DICOMData", maxdepth=md)
        end
    end


    tree = Dict()

    if with_keys
        for symbol in keys(dicom.meta)
            tree[symbol] = format(dicom[symbol], md - 1)
        end
    else
        tag_names = get_name_from_tag.(keys(dicom.meta))
        for symbol in tag_names
            tree[symbol] = format(dicom[symbol], md - 1)
        end
    end

    if haskey(tree, :PatientID)
        title = string(tree[:PatientID])
    else
        title = ""
    end

    return Tree(tree, guides=guides, title=title, maxdepth=md - 1)

end

function Tree(
    dicom_vector::Vector{DICOM.DICOMData};
    with_keys::Bool=false,
    guides::Union{TreeCharSet,Symbol}=:standardtree,
    theme::Theme=Theme(tree_max_leaf_width=displaysize(stdout)[2]),
    printkeys::Union{Nothing,Bool}=true,
    print_node_function::Function=print_node,
    print_key_function::Function=print_key,
    title::Union{String,Nothing}="",
    prefix::String="  ",
    kwargs...
)
    md = haskey(kwargs, :maxdepth) ? kwargs[:maxdepth] : 2
    return Tree(Tree.(dicom_vector, with_keys=with_keys, guides=guides, title="", maxdepth=md), guides=guides, title="", maxdepth=md)
end

end
