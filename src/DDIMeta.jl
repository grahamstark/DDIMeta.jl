module DDIMeta.jl

    using JDBC
    using DataStructures
    using DataFrames
    using LightXML
    using IniFile

    # jdbc dao stuff for our UKDS meta database
    export getconnection, loadvariablelist, init, shutdown, DBInfo

    # XML utilities
    export basiccensor, getIntAttr, getStrContent, getIntContent
    export getIntContentAttr

    # meta stuff
    export EnumVal, EnumsDict, Variable, VariableList
    export adddummies!, isprobablymissing

    # DDI XML parsing
    export parseddi

    include( "meta.jl" )
    include( "xmlutils.jl")
    include( "jdbcdao.jl" )
    include( "ddidao.jl" )

end # module
