
function basiccensor( s :: AbstractString ) :: AbstractString
        s = strip( s )
        # downcase.
        s = replace( s, r"[ \-,\t–]" => "_" )
        s = replace( s, r"[=\:\)\('’‘]" => "" )
        s = replace( s,  r"[\";:\.\?\*”“]" => "" )
        s = replace( s,  r"_$"=> "" )
        s = replace( s,  r"^_"=> "" )
        s = replace( s,  r"^_"=> "" )
        s = replace( s,  r"\/"=> "_or_" )
        s = replace( s,  r"\&"=> "_and_" )
        s = replace( s,  r"\+"=> "_plus_" )
        s = replace( s,  r"_\$+$"=> "" )
        if occursin( r"^[\d].*", s )
                s = string("v_", s ) # leading digit
        end
        s = replace( s,  r"__+"=> "_" )
        s = replace( s, r"^_" => "" )
        s = replace( s, r"_$" => "" )
        return s
end



function getIntAttr( e :: XMLElement, name :: AbstractString; default=nothing ) :: Union{Nothing,Int64}
    v = default
    a = attribute( e, name )
    # println( "looking for $name in $e;  got attr $a")
    if a !== nothing
        try
            v = parse( Int64, a )
        catch
            v = default
        end
    end
    # println( "@$name=$v")
    return v
end

function getStrContent( e :: XMLElement, name :: AbstractString; default=nothing ) :: Union{Nothing,String}
    se = find_element( e, name )
    if se === nothing
        return default
    end
    return strip(content(se))
end


function getIntContent( e :: XMLElement, name :: AbstractString; default=nothing ) :: Union{Nothing,Int64}
    value = default
    se = find_element( e, name )
    if se === nothing
        return value
    end
    vs = strip(content(se))
    try
        value = parse( Int64, vs )
    catch
        value = default
    end
    value
end

function getIntContentAttr( e :: XMLElement, name :: AbstractString; attr :: AbstractString, attrval :: AbstractString, default=nothing ) :: Union{Nothing,Int64}
    value = default
    els = get_elements_by_tagname( e, name )
    se = nothing
    for e in els
        ads = attributes_dict( e )
        if haskey(ads, attr ) && ads[attr] == attrval
            se = e
            break
        end
    end
    if se === nothing
        return value
    end
    vs = strip(content(se))
    try
        value = parse( Int64, vs )
    catch
        value = default
    end
    value
end
