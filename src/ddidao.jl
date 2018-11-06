using LightXML

"
    all the variables matching just the filename
    or just all vars if only 1 filename
"
function parseddi( ddifilename :: AbstractString, datafilename :: AbstractString = "" )
    xdoc = parse_file( ddifilename )
    xroot = root( xdoc )

    vl = VariableList()

    filesections = get_elements_by_tagname( xroot, "fileDscr")
    targetfileid = ""
    #
    # files can have multiple file sections;
    # since we're making this to match a dataframe, match
    # 1 datafile section by filename, or just everything if there is only 1
    #
    if size( filesections, 1 ) == 1
        targetfileid = attribute( filesections[1], "ID")
    else
        for fs in filesections
            ftxt = find_element( fs, "fileTxt")
            fname = getStrContent( ftxt, "fileName" )
            fname = splitext(basename( fname ))[1]
            if fname == datafilename
                targetfileid = attribute( fs, "ID")
            end
        end
    end
    @assert targetfileid != ""
    datasection = find_element( xroot, "dataDscr" )
    vars = get_elements_by_tagname( datasection, "var" )
    for var in vars
        thisfileid = attribute( var, "files")
        # println( "thisfileid '$thisfileid' fileid '$targetfileid'")
        if thisfileid == targetfileid
            decimals  = getIntAttr( var, "dcml", default=0 )
            intrvl = attribute( var, "intrvl" )
            name = attribute( var, "name" )
            # println( "name $name" )
            id = attribute(var, "ID" );
            location = find_element( var, "location" )
            width = getIntAttr( location, "width", default=1 )
            startpos = getIntAttr( location, "StartPos" )
            endpos = getIntAttr( location, "EndPos" )
            @assert startpos == endpos-width+1
            label = getStrContent( var, "labl" )
            valrange = find_element( var, "valrng" )
            min = 0
            max = 0
            if( valrange !== nothing )
                range = find_element( valrange, "range" )
                min = getIntAttr( range, "min")
                max = getIntAttr( range, "min")
            end
            measurement = "" # this is a UKDS field
            quest = find_element( var, "valrng" )
            question = ""
            instructions = ""
            if quest !== nothing
                instructions = getStrContent( quest, "ivuInstr", default="" )
                question = getStrContent( quest, "qstnLit",  default="" )
            end
            valid = getIntContentAttr( var, "sumStat", attr="type", attrval="valid", default=0 )
            invalid = getIntContentAttr( var, "sumStat", attr="type", attrval="invalid", default=0 )
            enumsDic = EnumsDict()
            #println(
            #"name = $name startpos = $startpos measurement = $measurement label = $label ");
            #println( "min = $min max = $max question = $question " );
            #println( "instructions = $instructions decimals = $decimals valid = $valid");
            #println( "invalid = $invalid ");
            variable = Variable(
                name, startpos, measurement, label,
                min, max, question, instructions, decimals, valid, invalid,
                enumsDic );


            enums = get_elements_by_tagname( var, "catgry" )
            i = 0
            for e in enums
                i += 1
                # with a default counter from 1 for the (rare) occasions where catValu is missing
                value = getIntContent( e, "catValu", default=i )
                # with a default of the value as a string
                label = getStrContent( e, "labl", default=string(i))
                freq = getIntContentAttr( e, "catStat", attr="type", attrval="freq", default=0 )
                enum_value = basicCensor( label )
                enum = EnumVal( value, label, enum_value, freq )
                variable.enums[value]=enum
                # println( "freq = $freq")
            end # loop enum attrs
        end # on the right file
        sort!( variable.enums ) # unclear why I need this ..
        vl[ Symbol( name )] = variable
    end # loop vars
    return vl
end # function
