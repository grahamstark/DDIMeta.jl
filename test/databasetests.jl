using DataFrames
using Test

include( "../src/metaincludes.jl")
include( "../src/meta.jl")
include( "../src/psqdao.jl")
include( "../src/ddidao.jl")

@testset "Tests of database IO" begin

  cstr = make_connection_str( "etc/msc.ini" )

  hhv :: VariableList = load_variable_list( cstr, "frs", "househol", 2015 )
  @test length( hhv )[1] > 0
  adv :: VariableList = load_variable_list( cstr, "frs", "adult", 2015 )
  @test length( adv )[1] > 0
  # println( vl )
  allv = merge( hhv, adv )
  println(  make_enumerated_type( "Tenure", allv[:tentyp2], true, true ))
  println(  make_enumerated_type( "EmpStat", allv[:empstat], true, true ))

end
