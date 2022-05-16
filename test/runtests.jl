module TestingArcusPerformax

using LibUSB
using ArcusPerformax
using Test

@testset "ArcusPerformax.jl" begin
    @test ArcusPerformax.count_devices() ≥ 0
    @test ArcusPerformax.find_device(0) isa LibUSB.DevicePointer
end

end # module
