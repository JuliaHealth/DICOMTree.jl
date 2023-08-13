module DICOMTree
import Term.Trees: Tree, TreeCharSet, print_node, print_key, Theme, TERM_THEME, _TREE_PRINTING_TITLE
import Term.Style: apply_style
import DICOM

export Tree

function apply_style(text::AbstractString, style::String)
    text = convert(String, text)
    apply_style(text, style)
end

function get_symbol(gelt::Tuple{UInt16,UInt16})
    if gelt[1] & 0xff00 == 0x5000
        gelt = (0x5000, gelt[2])
    elseif gelt[1] & 0xff00 == 0x6000
        gelt = (0x6000, gelt[2])
    end
    r = get(dcm_dict, gelt, empty_vr_lookup)

    (r[1] == "") ? (return gelt) : (return r[1])
end

function Tree(
    dicom::DICOMData;
    with_keys::Bool = false,
    guides::Union{TreeCharSet,Symbol} = :standardtree,
    theme::Theme = Theme(tree_max_leaf_width = displaysize(stdout)[2]),
    printkeys::Union{Nothing,Bool} = true,
    print_node_function::Function = print_node,
    print_key_function::Function = print_key,
    title::Union{String,Nothing} = "",
    prefix::String = "  ",
    kwargs...,
)
    _TREE_PRINTING_TITLE[] = title
    _theme = TERM_THEME[]
    TERM_THEME[] = theme

    md = haskey(kwargs, :maxdepth) ? kwargs[:maxdepth] : 2

    format(x, md) = x
    
    function format(x::AbstractArray, md)::Tree
        return (Tree(Dict("Size" => string(size(x)), "Type" => typeof(x)), with_keys = with_keys, guides = guides, title = "Array", maxdepth = md))
    end

    function format(x::Vector, md)::Tree
        if length(x) <= 6
            return Tree(string(x), with_keys = with_keys, guides = guides)
        else
            return Tree(Dict("Length" => length(x), 
                            "ElementsType" => eltype(x),
                            "Overview" => string(x[begin:begin+2])[1:end-1] * ", ..., " * string(x[end-3:end-1])[2:end]), guides = guides, title = "Vector", maxdepth = md)
        end
    end

    function format(x::DICOMData, md)::Tree
        return Tree(x.meta, with_keys = with_keys, guides = guides, title = "", maxdepth = md)
    end

    function format(x::Vector{DICOMData}, md)::Tree
        if md >= 2
            return Tree(Tree.(x, with_keys = with_keys, guides = guides, title = "", maxdepth = md), with_keys = with_keys, guides = guides, title = "", maxdepth = md)
        else
            return Tree(Dict("Length" => length(keys(x))), with_keys = with_keys, guides = guides, title = "Vector of DICOMData", maxdepth = md)
        end
    end


    tree = Dict()

    if with_keys
        for symbol in keys(dicom.meta)
            tree[symbol] = format(dicom[symbol], md - 1)
        end
    else
        for symbol in get_symbol.(keys(dicom.meta))
            tree[symbol] = format(dicom[symbol], md - 1)
        end
    end

    if haskey(tree, :PatientID)
        title = string(tree[:PatientID])
    else
       title = ""
    end

    return Tree(tree, with_keys = with_keys, guides = guides,  title = title, maxdepth = md - 1)

end

function Tree(
    dicom_vector::Vector{DICOMData};
    with_keys::Bool = false,
    guides::Union{TreeCharSet,Symbol} = :standardtree,
    theme::Theme = Theme(tree_max_leaf_width = displaysize(stdout)[2]),
    printkeys::Union{Nothing,Bool} = true,
    print_node_function::Function = print_node,
    print_key_function::Function = print_key,
    title::Union{String,Nothing} = "",
    prefix::String = "  ",
    kwargs...,
)
    md = haskey(kwargs, :maxdepth) ? kwargs[:maxdepth] : 2
    return Tree(Tree.(dicom_vector, with_keys = with_keys, guides = guides,  title = "", maxdepth = md), with_keys = with_keys, guides = guides,  title = "", maxdepth = md)
end

end
