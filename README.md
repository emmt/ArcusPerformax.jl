# ArcusPerformax [![Build Status](https://github.com/emmt/ArcusPerformax.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/emmt/ArcusPerformax.jl/actions/workflows/CI.yml?query=branch%3Amain) [![Build Status](https://ci.appveyor.com/api/projects/status/github/emmt/ArcusPerformax.jl?svg=true)](https://ci.appveyor.com/project/emmt/ArcusPerformax-jl) [![Coverage](https://codecov.io/gh/emmt/ArcusPerformax.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/emmt/ArcusPerformax.jl)


# Installation

1. Prerequisites: you need `libusb` (1.0) installed with its headers.  On
   Ubuntu-like system, this can be done by:

   ```{.sh}
   sudo apt install libusb-1.0-0-dev
   ```

2. Clone or update (`git pull -r`) repository.

3. Compile driver:

   ```{.sh}
   cd ArcusPerformax.jl/driver
   make
   ```

4. Compile driver:

   ```{.sh}
   cd ../deps
   julia -e "using Pkg; pkg\"add Clang\";"
   julia build.jl
   ```
