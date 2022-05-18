module ArcusPerformax

using LibUSB
using LibUSB: Low, null, is_null, get_device_descriptor, throw_libusb_error

# These constants are defined by Arcus.
const PERFORMAX_RETURN_SERIAL_NUMBER = 0x0
const PERFORMAX_RETURN_DESCRIPTION   = 0x1
const PERFORMAX_MAX_DEVICE_STRLEN    = 256

# Timeouts.
const read_timeout = Ref{Cuint}(1_000)
const write_timeout = Ref{Cuint}(1_000)

"""
    ArcusPerformax.set_timeouts(; rd = 1_000, wr = 1_000)

sets timeouts for communication with ArcusPerformax devices.  Keywords `rd` and
`wr` specify the timeouts in milliseconds for reading and writing.  Typical
values of 1000 ms are recommended (these are the default).

"""
function set_timeouts(;rd::Integer = 1_000, wr::Integer = 1_000)
    rd ≥ 0 || throw(ArgumentError("invalid read timeout"))
    wr ≥ 0 || throw(ArgumentError("invalid write timeout"))
    read_timeout[]  = rd
    write_timeout[] = wr
    return nothing
end

"""
    ArcusPerformax.Device(devnum) -> dev

opens Arcus-Performax USB device number `devnum` and returns an object
connected to this device.  The connection is automatically closed when the
returned object s garbage collected.  It is thus not needed to call the `close`
method on the object.

The returned object can be used as a function to send a command (the result is
a string):

    dev(cmd)

For example:

    dev = ArcusPerformax.Device(devnum);
    println("Device Number: ", dev("DN"))
    println("Product Identifier: ", dev("ID"))
    close(dev) # this is not mandatory

"""
mutable struct Device
    # This is just a thin wrapper over a LibUSB.DeviceHandle.
    handle::LibUSB.DeviceHandle
    function Device(devptr::LibUSB.DevicePointer)
        handle = open(devptr)
        is_supported_device(handle) || throw(ArgumentError(
            "not a Performax USB device"))
        code = Low.libusb_claim_interface(handle, 0)
        if code != 0
            close(handle)
            throw_libusb_error(:libusb_claim_interface, code)
        end
        code = _send_urb_control(handle, URB_OPEN)
        if code == 0
            # Flushing the connection right after openning is recommanded in
            # the doc.
            code = _send_urb_control(handle, URB_FLUSH)
        end
        if code != 0
            Low.libusb_release_interface(handle, 0)
            close(handle)
            throw_libusb_error(:libusb_control_transfer, code)
        end
        return finalizer(_close, new(handle))
    end
end

function Device(devnum::Integer)
    devptr = find_device(devnum)
    is_null(devptr) && error("invalid Performax device number")
    return Device(devptr)
end

number(dev::Device) = getfield(dev, :number)
handle(dev::Device) = getfield(dev, :handle)

function Base.flush(dev::Device)
    code = _send_urb_control(dev, URB_FLUSH)
    code == 0 || throw_libusb_error(:libusb_control_transfer, code)
    return dev
end

Base.close(dev::Device) = _close(dev; throwerrors=true)

function _close(dev::Device; throwerrors::Bool = false)
    code1 = _send_urb_control(dev, URB_CLOSE)
    code2 = Low.libusb_release_interface(handle(dev), 0)
    close(handle(dev)) # this function never throws
    if throwerrors && code1 != 0
        throw_libusb_error(:libusb_control_transfer, code1)
    end
    if throwerrors && code2 != 0
        throw_libusb_error(:libusb_release_interface, code2)
    end
    return nothing
end

# Use the device as a function to send commands.
function (dev::Device)(cmd::AbstractString)
    is_null(handle(dev)) && error("connection to device has been closed")

    len = 64 # i/o transfer are 64 bytes in size
    transferred = Ref{Cint}()
    buf = Array{UInt8}(undef, 4096) # big enough buffer for flusing

    # Clear any outstanding reads.  If this fails, it's probably ok.  We
    # probably don't care.
    code = Low.libusb_bulk_transfer(handle(dev), 0x82, buf, sizeof(buf),
                                    transferred, read_timeout[])

    # Prepare bytes to send.
    i = 0
    for c in cmd
        if ((c < '\0') | (c > '\x7f'))
            throw(ArgumentError("non-ASCII character in command"))
        end
        i += 1
        if i ≥ len
            throw(ArgumentError("command is too long"))
        end
        buf[i] = c
    end
    buf[i] = 0

    # Send bytes to write.
    code = Low.libusb_bulk_transfer(handle(dev), 0x02, buf, len,
                                    transferred, write_timeout[])
    code == 0 || throw_libusb_error(:libusb_bulk_transfer, code)

    # Receive bytes to read.
    code = Low.libusb_bulk_transfer(handle(dev), 0x82, buf, len,
                                    transferred, read_timeout[])
    code == 0 || throw_libusb_error(:libusb_bulk_transfer, code)

    # Convert received bytes in a string.
    for i in 1:len
        c = buf[i]
        c < 0x80 || error("non-ASCII character in result")
        c == 0x00 && return unsafe_string(pointer(buf))
    end
    error("result is too long")
end

"""
    ArcusPerformax.count_devices()

yields the number of connected Arcus-Performax devices.

"""
function count_devices()
    list = LibUSB.DeviceList() # Get a list of all connected devices.
    count = 0
    for i ∈ eachindex(list)
        if is_supported_device(list[i])
            count += 1
        end
    end
    close(list) # Unreference and remove items from the list.
    return count
end

"""
    ArcusPerformax.get_serial_number(devnum)

yields the serial number of device number `devnum`.

"""
get_serial_number(devnum::Integer) =
    get_product_string(devnum, PERFORMAX_RETURN_SERIAL_NUMBER)

"""
    ArcusPerformax.get_description(devnum)

yields the description of device number `devnum`.

"""
get_description(devnum::Integer) =
    get_product_string(devnum, PERFORMAX_RETURN_DESCRIPTION)

"""
    ArcusPerformax.get_product_string(devnum, id)

yields the string identified by `id` for Arcus-Performax device number `devnum`.

"""
function get_product_string(devnum::Integer, id::Integer)
    device = get_performax_device(devnum)
    if is_null(device)
        throw(ArgumentError("device not found"))
    end
    buf = Vector{Cuchar}(undef, PERFORMAX_MAX_DEVICE_STRLEN)
    handle = open(device) # Open the device.
    try
        idx = Int(-1)
        if id == PERFORMAX_RETURN_SERIAL_NUMBER
            idx = Int(get_device_descriptor(handle).iSerialNumber)
        elseif id == PERFORMAX_RETURN_DESCRIPTION
            idx = Int(get_device_descriptor(handle).iProduct)
        else
            throw(ArgumentError("invalid identifier"))
        end
        code = Low.libusb_get_string_descriptor_ascii(
            handle, idx, buf, sizeof(buf))
        code == 0 || throw(LibUSBError(
            :libusb_get_string_descriptor_ascii, code))
    finally
        close(handle)
    end
    buf[end] = 0
    return unsafe_string(pointer(buf))
end

"""
    ArcusPerformax.find_device([list,]devnum) -> dev

yields the Arcus-Performax device number `devnum` from the (optional) list of
devices `list`.  A null USB device pointer is returned if no matching device is
found.

"""
function find_device(devnum::Integer)
    list = LibUSB.DeviceList() # Get a list of all connected devices.
    try
        return find_device(list, devnum)
    finally
        close(list) # Unreference and remove items from the list.
    end
end

function find_device(list::LibUSB.DeviceList, devnum::Integer)
    for dev ∈ list
        # Iterate through each device and find a Perfomax device.
        if is_supported_device(dev)
            if devnum > 0
                # Skip this Performax device.
                devnum -= 1
            else # This is the one we're interested in...
                return dev
            end
        end
    end
    return null(eltype(list))
end

"""
    ArcusPerformax.is_supported_device(x)

yields whether `x` is a supported Arcus-Performax USB device.

"""
is_supported_device(desc::LibUSB.DeviceDescriptor) =
    ((desc.idVendor == 0x1589) && (desc.idProduct == 0xa101))
is_supported_device(x) = is_supported_device(get_device_descriptor(x))

const URB_FLUSH = 0x01 # flush command
const URB_OPEN  = 0x02 # open command
const URB_CLOSE = 0x04 # close command

_send_urb_control(dev::Device, id::Integer) = _send_urb_control(handle(dev), id)
_send_urb_control(handle::LibUSB.DeviceHandle, id::Integer) =
    Low.libusb_control_transfer(
        handle,         # dev_handle
        0x40,           # request_type
        0x02,           # bRequest,
        id,             # wValue,
        0x00,           # wIndex,
        Ptr{Cuchar}(0), # data,
        0,              # wLength,
        write_timeout[])

end # module
