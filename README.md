# ArcusPerformax [![Build Status](https://github.com/emmt/ArcusPerformax.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/emmt/ArcusPerformax.jl/actions/workflows/CI.yml?query=branch%3Amain) [![Build Status](https://ci.appveyor.com/api/projects/status/github/emmt/ArcusPerformax.jl?svg=true)](https://ci.appveyor.com/project/emmt/ArcusPerformax-jl) [![Coverage](https://codecov.io/gh/emmt/ArcusPerformax.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/emmt/ArcusPerformax.jl)


# Installation

1. Clone or update (`git pull -r`) repository.

2. Compile driver (warning messages are expected):

   ```{.sh}
   cd ArcusPerformax.jl/driver
   make
   ```

3. Compile driver (warning messages are expected):

   ```{.sh}
   cd ../deps
   julia -e "using Pkg; pkg\"add Clang\";"
   julia build.jl
   ```
