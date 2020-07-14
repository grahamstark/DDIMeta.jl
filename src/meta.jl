using Unicode

struct EnumVal
    value :: Integer
    label :: AbstractString
    enum_value :: AbstractString
    freq  :: Integer
end

function isprobablymissing( e :: EnumVal ) :: Bool
    # TODO
    false
end

EnumsDict = OrderedDict{Integer,EnumVal}

struct Variable
    name :: AbstractString
    pos  :: Integer
    measurement_level :: AbstractString
    label :: AbstractString
    ## following are for DDI verson only
    min  :: Number
    max  :: Number
    question :: AbstractString
    instructions :: AbstractString
    decimals :: Integer
    valid :: Integer
    invalid :: Integer
    enums :: EnumsDict
end

VariableList = OrderedDict{Symbol,Variable}

function make_enumerated_type(
    enumname         :: AbstractString,
    var              :: Variable,
    include_values   :: Bool = false,
    include_missings :: Bool = false ) :: AbstractString
    capname = Unicode.titlecase( var.name )
    el = length( var.enums )[1]
    i = 1
    s = "   export $enumname  # mapped from $(var.name)\n   export"
    some_missing = false
    for e in values(var.enums)
        if( e.value > 0 ) || include_missings
            val = replace( e.enum_value,  r"__"=> "_" ) # hack because I've allowed dup '__' in the DB version
            s *= " $(val)"
            if i < el
                s *= ","
            end
            i += 1
        end
        if e.value < 0
            some_missing = true
        end
    end

    s *= "\n"
    add_missing = (! some_missing) && include_missings
    if add_missing
        s *= "   export Missing_$enumname\n"
    end
    s *= "\n"
    s *= "   @enum $enumname begin  # mapped from $(var.name)\n"
    if add_missing
        s *= "      Missing_$enumname"
        if include_values
            s *= " = -1\n"
        end
    end
    for e in values(var.enums)
        if( e.value > 0 ) || include_missings
            val = replace( e.enum_value,  r"__"=> "_" )
            s *= "      $val"
            if include_values
                s *= " = $(e.value)"
            end
            s *= "\n"
        end
    end

    s *= "   end\n\n"
    s
end

"
Add columns with
returns an array of the new column names
"
function adddummies!( df :: DataFrame, var :: Variable, alias :: String="" ) :: Array{Symbol,1}
    n  = size( df, 1 )
    if alias != ""
        vs = Symbol( alias )
    else
        vs = Symbol( var.name )
    end
    newcols = Array{Symbol,1}()
    for e in values(var.enums)
        if ! isprobablymissing( e )
            newsym = Symbol( vs,"_",e.enum_value )
            println( "adding col $newsym")
            df[newsym] = zeros( Union{Missing,Integer}, n )
            for i in 1:n
                if ismissing(df[vs][i])
                    df[newsym][i] = missing
                elseif df[vs][i] == e.value
                    df[newsym][i] = 1
                end
            end
            push!( newcols, newsym )
        end # not a missing indicator
    end # each enum value
    return newcols
end
