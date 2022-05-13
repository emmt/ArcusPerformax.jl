using ArcusPerformax

function test_device(num::Integer = 0)

    # Private function to check whether motor is still moving.
    is_moving(str::AbstractString) = length(res) < 1 || res[1] != 'O'

    # acquire information
    numdev = ArcusPerformax.get_num_devices()
    if numdev < 1
        println("No motor found")
	return
    end
    try
        println("Serial Number: ", ArcusPerformax.get_serial_number(num))
    catch
    end
    try
        println("Description: ", ArcusPerformax.get_description(num))
    catch
    end

    # Open device (no needs to flush).
    dev = ArcusPerformax.Device(num)

    # Setup connection timeouts.
    ArcusPerformax.set_timeouts(rd=5_000, wr=5_000)

    # Setup the device.
    dev("EIDO=0")      # disable the DIO communication (to change the microstepping)
    dev("DO=3")        # set the microstepping
    dev("DO")          # set the microstepping
    dev("EX=0")        # set encoder value
    dev("LSPD=00")     # set low speed
    dev("HSPD=1000")   # set high speed
    if false
        # This seems to be an unknown command in the current firmware...
	dev("CUR=500") # set current
    end

    #dev("POL=16")     # set polarity on the limit switch to be positive
    dev("ACC=600")     # set acceleration
    dev("EO=1")        # enable device
    dev("INC")         # set incremental mode
    id = dev("ID")     # read current identifier
    println("Arcus Product: ", id)
    dn = dev("DN")     # read current device number
    println("Device Number: ", dn)

    println("Motor is moving. Please wait.\n")

    for i in 1:2
	while true
	    res = dev("X-1000") # move the motor
	    # wait and retry while motor is still moving.
            sleep(1.0)
            if !is_moving(res)
                break
            end
        end
	while true
	    res = dev("X1000") # move the motor
	    # wait and retry while motor is still moving.
            sleep(1.0)
            if !is_moving(res)
                break
            end
	end

    end
    sleep(1.0)
    dev("J-") # move the motor at constant speed
    sleep(10.0)
    dev("STOP") # stop the motor
    close(dev)
    println("Motor connection has been closed")
end
