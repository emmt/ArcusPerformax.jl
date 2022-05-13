# ArcusPerformax [![Build Status](https://github.com/emmt/ArcusPerformax.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/emmt/ArcusPerformax.jl/actions/workflows/CI.yml?query=branch%3Amain) [![Build Status](https://ci.appveyor.com/api/projects/status/github/emmt/ArcusPerformax.jl?svg=true)](https://ci.appveyor.com/project/emmt/ArcusPerformax-jl) [![Coverage](https://codecov.io/gh/emmt/ArcusPerformax.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/emmt/ArcusPerformax.jl)

# Usage

See file [`src/example.jl`](src/example.jl) for an example of usage.


# Installation

## Prerequisites

You need `libusb` (1.0) installed with its headers.  On Ubuntu-like system,
this can be done by:

```{.sh}
sudo apt install libusb-1.0-0-dev
```

You also need the `Clang` Julia package which can be pre-installed by:

```{.sh}
cd ../deps
julia -e "using Pkg; pkg\"add Clang\";"
```


## Building

Building the package is as simple as:

1. Clone or update (`git pull -r`) repository.

2. Compile driver and build low-level interface:

   ```{.sh}
   julia -e "using Pkg; pkg\"add Clang\";"
   cd ArcusPerformax.jl/deps
   julia build.jl
   ```
