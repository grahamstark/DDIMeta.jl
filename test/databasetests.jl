using DataFrames
using Test

include( "../src/metaincludes.jl")
include( "../src/meta.jl")
include( "../src/jdbcdao.jl")
include( "../src/ddidao.jl")

@testset "Tests of database IO" begin

  conn = init( "../etc/msc.ini")
  @test conn != nothing

  hhv :: VariableList = loadvariablelist( conn, "frs", "househol", 2015 )
  @test length( hhv )[1] > 0
  adv :: VariableList = loadvariablelist( conn, "frs", "adult", 2015 )
  @test length( adv )[1] > 0
  # println( vl )
  allv = merge( hhv, adv )
  println(  make_enumerated_type( allv[:tentyp2], true, true ))
  println(  make_enumerated_type( allv[:empstat], true, true ))

end
