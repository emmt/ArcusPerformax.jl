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

const NULL = Driver.AR_HANDLE(0)

"""
    ArcusPerformax.Device(num) -> dev

opens ArcusPerformax device number `num` and returns an object connected to this
device.  The connection is automatically closed when the returned object s
garbage collected.  It is thus not needed to call the `close` method on the
object.  If `num < 0`, an unconnected object is returned.

The returned object can be used as a function to send a command (the result is
a string):

    dev(cmd)

For example:

    dev = ArcusPerformax.Device(num);
    println("Device Number: ", dev("DN"))
    println("Product Identifier: ", dev("ID"))
    close(dev) # this is not mandatory

"""
mutable struct Device
    number::Driver.AR_DWORD
    handle::Driver.AR_HANDLE
    function Device(number::Integer = -1)
        handle = Ref(NULL)
        if number ≥ 0 && Driver.fnPerformaxComOpen(number, handle) != 0
            error("failed to open device $number")
        end
        # Flushing the connection right after openning it is recommanded in the
        # doc.
        return finalizer(finalize, flush(new(number, handle[])))
    end
end

number(dev::Device) = getfield(dev, :number)
handle(dev::Device) = getfield(dev, :handle)

function Base.flush(dev::Device)
    if handle(dev) != NULL
        if Driver.fnPerformaxComFlush(handle(dev)) != 0
            error("failed to flush communication buffer")
        end
    end
    return dev
end

Base.close(dev::Device) = finalize(dev; throwerrors=true)

function finalize(dev::Device; throwerrors::Bool=false)
    ptr = handle(dev)
    if ptr != NULL
        setfield!(dev, :handle, NULL)
        setfield!(dev, :number, convert(Driver.AR_DWORD, -1))
        if Drive.fnPerformaxComClose(ptr) != 0 && throwerrors
            error("failed to close device")
        end
    end
    return nothing
end


# Use the device as a function to send commands.
function (dev::Device)(cmd::AbstractString)
    if handle(dev) == NULL
        error("connection to device has been closed")
    end
    siz = 64 # buffers must have 64 bytes
    inp = Array{UInt8}(undef, siz)
    out = Array{UInt8}(undef, siz)
    k = 0
    for c in cmd
        if ((c < '\0') | (c > '\x7f'))
            throw(ArgumentError("non-ASCII character in command"))
        end
        k += 1
        if k ≥ len
            throw(ArgumentError("command is too long"))
        end
        inp[k] = c
    end
    inp[k+1] = 0
    if Driver.fnPerformaxComSendRecv(handle(dev), inp, siz, siz, out) != 0
        error("error in call to `fnPerformaxComSendRecv`")
    end
    out[siz] = 0
    return unsafe_string(pointer(out))
end

"""
    ArcusPerformax.get_num_devices()

yields the number of connected ArcusPerformax devices.

"""
function get_num_devices()
    num = Ref{Driver.AR_DWORD}()
    if Driver.fnPerformaxComGetNumDevices(num) != 0
        error("error in call to `fnPerformaxComGetNumDevices`")
    end
    return Int(num[])
end

"""
    ArcusPerformax.set_timeouts(; rd = 1_000, wr = 1_000)

sets timeouts for communication with ArcusPerformax devices.  Keywords `rd` and
`wr` specify the timeouts in milliseconds for reading and writing.  Typical
values of 1000 ms are recommended (these are the default).

"""
function set_timeouts(; rd::Integer = 1_000, wr::Integer = 1_000)
    if Driver.fnPerformaxComSetTimeouts(rd, wr) != 0
        error("error in call to `fnPerformaxComSetTimeouts`")
    end
    return nothing
end

"""
    ArcusPerformax.get_serial_number(num)

yields the serial number of device number `num`.

"""
get_serial_number(num::Integer) =
    get_product_string(num, Driver.PERFORMAX_RETURN_SERIAL_NUMBER)

"""
    ArcusPerformax.get_description(num)

yields the description of device number `num`.

"""
get_description(num::Integer) =
    get_product_string(num, Driver.PERFORMAX_RETURN_DESCRIPTION)

function get_product_string(num::Integer, id::Integer)
    id ∈ (Driver.PERFORMAX_RETURN_SERIAL_NUMBER,
          Driver.PERFORMAX_RETURN_DESCRIPTION) || throw(ArgumentError(
              "invalid identifier $id"))
    siz = Driver.PERFORMAX_MAX_DEVICE_STRLEN
    buf = Array{UInt8}(undef, siz)
    if Driver.fnPerformaxComGetProductString(num, buf, id) != 0
        error("error in call to `fnPerformaxComGetProductString`")
    end
    buf[siz] = 0
    # NOTE: First character is set to '?' in case of errors.
    return unsafe_string(pointer(buf))
end

end # module
