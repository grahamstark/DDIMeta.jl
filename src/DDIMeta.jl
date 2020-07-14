module DDIMeta

    using DataStructures
    using DataFrames
    using LightXML
    using IniFile
    using Unicode
    using LibPQ

    # jdbc dao stuff for our UKDS meta database
    export get_connection, load_variable_list, make_connection_str

    # XML utilities
    export basiccensor, getIntAttr, getStrContent, getIntContent
    export getIntContentAttr

    # meta stuff
    export EnumVal, EnumsDict, Variable, VariableList
    export adddummies!, isprobablymissing, make_enumerated_type

    # DDI XML parsing
    export parseddi

    include( "meta.jl" )
    include( "xmlutils.jl")
    # include( "jdbcdao.jl" )
    include( "ddidao.jl" )
    include( "psqdao.jl")

end # module
