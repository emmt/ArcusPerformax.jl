# ArcusPerformax [![Build Status](https://github.com/emmt/ArcusPerformax.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/emmt/ArcusPerformax.jl/actions/workflows/CI.yml?query=branch%3Amain) [![Build Status](https://ci.appveyor.com/api/projects/status/github/emmt/ArcusPerformax.jl?svg=true)](https://ci.appveyor.com/project/emmt/ArcusPerformax-jl) [![Coverage](https://codecov.io/gh/emmt/ArcusPerformax.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/emmt/ArcusPerformax.jl)

`ArcusPerformax` is a [Julia](https://julialang.org/) package to deal with
[ArcusPerformax](https://www.arcus-technology.com/) USB devices.  The code is
based on the Linux driver which is downloadable
[here](https://www.arcus-technology.com/support/downloads/download-category/sample-source-code/).


# Usage

To load the package, call:

```julia
using ArcusPerformax
```

To retrieve the number of connected Arcus-Performax devices, call:

```julia
ArcusPerformax.count_devices()
```

To set the read/write timeouts for subsequent data transfers, call:

```julia
ArcusPerformax.set_timeouts(; rd=..., wr=...)
```

with keywords `rd` and `wr` used to specify the timeouts (in milliseconds)
for reading and writing.

To find the Arcus-Performax device whose number if `devnum`, call:

```julia
ArcusPerformax.find_device(devnum)
```

which returns a null USB device pointer if no matching device is found.

To open the Arcus-Performax device whose number if `devnum`, call:

```julia
ArcusPerformax.Device(devnum)
```

The returned object, say `dev`, may be then directly called to send commands
(results are returned as strings):

```julia
res = dev(cmd)
```

See file [`src/example.jl`](src/example.jl) for an example of usage.


# Installation

Installing and building the package is as simple as typing the following
commands in Julia:

```julia
using Pkg
pkg"add https://github.com/emmt/LibUSB.jl"
pkg"add https://github.com/emmt/ArcusPerformax.jl"
```
