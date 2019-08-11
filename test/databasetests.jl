using DataFrames
using Test

include( "../src/metaincludes.jl")
include( "../src/meta.jl")
include( "../src/jdbcdao.jl")
include( "../src/ddidao.jl")

@testset "Tests of database IO" begin

  conn = init( "../etc/msc.ini")
  @test conn != nothing

  vl :: VariableList = loadvariablelist( conn, "frs", "househol", 2015 )
  @test length( vl )[1] > 0
  # println( vl )
  println(  make_dummy_var( vl[:tentyp2], true ))

end
