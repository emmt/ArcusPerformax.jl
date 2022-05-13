module ArcusPerformax

# Load the low level interface to the Arcus driver.
let file = joinpath(@__DIR__, "..", "deps", "deps.jl")
    if !isfile(file)
        error("File \"$file\" does not exists.  You may may generate it by:\n",
              "    using Pkg\n",
              "    Pkg.build(\"$(@__MODULE__)\")")
    end
    include(file)
end

"""
    ArcusPerformax.GetNumDevices()

yields the number of devices.

"""
function GetNumDevices()
    num = Ref{Driver.AR_DWORD}()
    status = Driver.fnPerformaxComGetNumDevices(num)
    status == 0 && error(
        "error $status in fnPerformaxComGetNumDevices")
    return num[]
end

end
