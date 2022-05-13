# ArcusPerformax [![Build Status](https://github.com/emmt/ArcusPerformax.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/emmt/ArcusPerformax.jl/actions/workflows/CI.yml?query=branch%3Amain) [![Build Status](https://ci.appveyor.com/api/projects/status/github/emmt/ArcusPerformax.jl?svg=true)](https://ci.appveyor.com/project/emmt/ArcusPerformax-jl) [![Coverage](https://codecov.io/gh/emmt/ArcusPerformax.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/emmt/ArcusPerformax.jl)

`ArcusPerformax` is a [Julia](https://julialang.org/) package to deal with
[ArcusPerformax](https://www.arcus-technology.com/support/downloads/download-category/sample-source-code/)
USB devices.

# Usage

See file [`src/example.jl`](src/example.jl) for an example of usage.


# Installation

## Prerequisites

You need `libusb` (1.0) installed with its headers.  On Ubuntu-like system,
this can be done by:

```{.sh}
sudo apt install libusb-1.0-0-dev
```


## Building

Installing and building the package is as simple as typing the following
commands in Julia:

```{.julia}
using Pkg
pkg"add https://github.com/emmt/ArcusPerformax.jl"
```
