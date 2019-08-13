#
#
#

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
    var              :: Variable,
    include_values   :: Bool = false,
    include_missings :: Bool = false ) :: AbstractString
    s = "   @enum $(var.name) begin\n"
    for e in values(var.enums)
        if( e.value > 0 ) || include_missings
            s *= "      $(e.enum_value)"
            if include_values
                s *= " = $(e.value)"
            end
            s *= "\n"
        end
    end
    s *= "   end\n\n\n"
    s
end

"
Add columns with
returns an array of the new column names
"
function adddummies!( df :: DataFrame, var :: Variable ) :: Array{Symbol,1}
    n  = size( df, 1 )
    vs = Symbol( var.name )
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
