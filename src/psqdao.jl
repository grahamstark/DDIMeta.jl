const varstmt = "select name,pos,measurement_level,label,vmin,vmax,question,instructions,vdecimals,valid,invalid from dictionaries.variables where dataset=\$1 and tables=\$2 and year=\$3"
const enumstmt = "select value,label,enum_value,freq from dictionaries.enums where dataset=\$1 and tables=\$2 and variable_name=\$3 and year=\$4 order by value"


function make_pg_connection_str( inifilename :: AbstractString )::String
    inifile = read( IniFile.Inifile(), inifilename )
    user = IniFile.get( inifile, "DB", "username")
    passwd = IniFile.get( inifile, "DB", "password")
    db = IniFile.get( inifile, "DB", "database")
    server = IniFile.get( inifile, "DB", "server")
    # note we ignore password
    # local and trust turned on -
    str = "postgresql://$(user)@$(server)/$(db)"
    str
end

function getconnection( psqstr :: String ) :: LibPQ.Connection
    LibPQ.Connection( psqstr )
end


function loadvariablelist(
    connstr   :: AbstractString,
    dataset   :: AbstractString,
    tablename :: AbstractString,
    year      :: Integer  ) :: VariableList

    vl = VariableList()

    conn = getconnection( connstr )

    vr = LibPQ.execute( conn, varstmt, [dataset, tablename, year] )
    rows = Tables.rows( Tables.columntable( vr ))
    for row in rows
        enums = EnumsDict()
        ve = LibPQ.execute( conn, enumstmt, [dataset, tablename, row.name, year] )
        enumrows = Tables.rows( Tables.columntable( ve ))
        for erow in enumrows
            enval = parse(Int, erow.value )
            enum = EnumVal( enval , erow.label, erow.enum_value, erow.freq )
            enums[ enval ] = enum
        end
        variable = Variable( row.name, row.pos, row.measurement_level, row.label,
             row.vmin, row.vmax, row.question, row.instructions, row.vdecimals,
             row.valid, row.invalid,
             enums );
        vl[Symbol(row.name)] = variable
    end
    return vl
end
