using DataFrames
using StatFiles

include( "../src/metaincludes.jl")
include( "../src/xmlutils.jl")
include( "../src/meta.jl")
include( "../src/jdbcdao.jl")
include( "../src/ddidao.jl")

@testset "Tests of hacking a dataframe using WB/ScotSoc data" begin

    # TODO some actual tests ...

    df1 = DataFrame( StatFiles.load( "/mnt/data/World_Bank/data/Afghanistan_idstd_Formal.dta" ))
    xdoc1 = parseddi("/mnt/data/World_Bank/ddi/312.xml", "x" )

    df2 = DataFrame( StatFiles.load( "/mnt/data/World_Bank/data/Afghanistan_idstd_Informal.dta" ))
    xdoc2 = parseddi("/mnt/data/World_Bank/ddi/313.xml", "x" )

    # see: https://stackoverflow.com/questions/51544317/breaking-change-on-vcat-when-columns-are-missing
    # vcat needs manual adding non-common columns
    for n in unique([names(df1); names(df2)] ), df in [df1,df2]
          n in names(df) || (df[n] = missing)
    end

    dfm = vcat( df1, df2 )

    names( xdoc1 )

    adddummies!( dfm, xdoc1[:fgq23])

end # not quite a test set
