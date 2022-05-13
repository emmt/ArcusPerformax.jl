using Libdl
using Clang.Generators
using Clang.LibClang.Clang_jll

function build_deps(deps_dir::AbstractString, driver_dir::AbstractString)
    # Dynamic library file.
    driver_file = joinpath(driver_dir, "ArcusPerformaxDriver.$(Libdl.dlext)")

    # Header file(s).
    headers = map(x -> joinpath(driver_dir, x), ["ArcusPerformaxDriver.h",])

    # The rest is pretty standard.
    cd(deps_dir)
    options = load_options(joinpath(deps_dir, "generator.toml"))
    args = get_default_args()
    push!(args, "-I$(driver_dir)")
    for str in readlines(`pkg-config libusb-1.0 --cflags`)
        push!(args, str)
    end
    ctx = create_context(headers, args, options)
    build!(ctx)

    # Rewrite destination file.
    dest_file = options["general"]["output_file_path"]
    code = readlines(dest_file)
    for repl in [
        r"^\s*const\s+ArcusDriver\s*=.*$" => "const ArcusDriver = \"$driver_file\"",
    ]
        for i in eachindex(code)
            code[i] = replace(code[i], repl)
        end
    end
    open(dest_file, "w") do io
        foreach(line -> println(io, line), code)
    end
end

# Run the build script.
build_deps(@__DIR__, normpath(joinpath(@__DIR__, "../driver")))
