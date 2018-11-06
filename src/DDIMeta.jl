module DDIMeta.jl

    using JDBC
    using DataStructures
    using DataFrames
    using LightXML

    # jdbc dao stuff for our UKDS meta database
    export getconnection, loadvariablelist, init, shutdown
    # XML utilities
    export basiccensor, getIntAttr, getStrContent, getIntContent
    export getIntContentAttr
    # DDI XML parsing
    export parseddi
    # meta stuff
    export EnumVal, EnumsDict, Variable, VariableList
    export adddummies!, isprobablymissing


    include( "meta.jl" )
    include( "xmlutils.jl")
    include( "jdbcdao.jl" )
    include( "ddidao.jl" )

end # module
