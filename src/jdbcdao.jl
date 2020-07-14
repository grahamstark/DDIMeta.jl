# see: https://github.com/JuliaDatabases/JDBC.jl

struct DBInfo
    jdbcdriver :: String
    username   :: String
    password   :: String
    database   :: String
    server     :: String
end


function init( inifilename :: AbstractString ) :: DBInfo
    inifile = read( IniFile.Inifile(), inifilename )
    dbinf = DBInfo(
        IniFile.get( inifile, "JDBC", "driver"),
        IniFile.get( inifile, "DB", "username"),
        IniFile.get( inifile, "DB", "password"),
        IniFile.get( inifile, "DB", "database"),
        IniFile.get( inifile, "DB", "server"))
    JDBC.usedriver( dbinf.jdbcdriver )
    JDBC.init()
    return dbinf
end

function getconnection( dbinfo :: DBInfo  )
    connstr = string("jdbc:postgresql://",dbinfo.server,"/",dbinfo.database,"?user=",dbinfo.username,"&password=",dbinfo.password )
    JDBC.DriverManager.getConnection( connstr )
end

function loadvariablelist( dbinfo :: DBInfo, dataset :: AbstractString, table :: AbstractString, year :: Integer  ) :: VariableList

    vl = VariableList()

    conn = getconnection( dbinfo )

    #                                            1   2      3              4     5     6    7       8            9          10    11
    qps = JDBC.prepareStatement( conn, "select name,pos,measurement_level,label,vmin,vmax,question,instructions,vdecimals,valid,invalid from dictionaries.variables where dataset=? and tables=? and year=?" )
    #                                             1    2     3          4
    eps = JDBC.prepareStatement( conn, "select value,label,enum_value,freq from dictionaries.enums where dataset=? and tables=? and variable_name=? and year=? order by value" )

    JDBC.setString( qps, 1, dataset )
    JDBC.setString( qps, 2, table )
    JDBC.setInt( qps, 3, year )

    JDBC.setString( eps, 1, dataset )
    JDBC.setString( eps, 2, table )

    JDBC.setInt( eps, 4, year )

    rs = JDBC.executeQuery( qps )
    for r in rs
           name = getString(r,1)
           pos = getInt( r, 2 )
           measurement = getString( r, 3 )
           label = getString( r, 4 )
           vmin = getInt( r, 5 )
           vmax = getInt(r, 6 )
           question = getString( r, 7 )
           instructions = getString( r, 8 )
           vdecimals = getInt(r, 9 )
           valid = getInt( r, 10 )
           invalid = getInt( r, 11 )
           enums = EnumsDict()
           variable = Variable( name, pos, measurement, label,
                vmin, vmax, question, instructions, vdecimals, valid, invalid,
                enums );
           JDBC.setString( eps, 3, name )
           ers = JDBC.executeQuery( eps )
           for e in ers
                 value = getInt( e, 1 )
                 label  =  getString( e, 2 )
                 enum_value =  getString( e, 3 )
                 freq = getInt( e, 4 ) # not in UKDS
                 enum = EnumVal( value, label, enum_value, freq )
                 variable.enums[ value ] = enum
                 # println( "==== $value '$label' '$enum_value' " )
           end
           sort!( variable.enums ) # unclear why I need this ..
           vl[ Symbol( name )] = variable
    end
    vl
end


function shutdown()
    JDBC.destroy()
end
