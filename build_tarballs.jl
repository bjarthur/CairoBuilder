# Note that this script can accept some limited command-line arguments, run
# `julia build_tarballs.jl --help` to see a usage message.
using BinaryBuilder
name = "Cairo"
version = v"1.12.12"
#
# function url2hash(url)
#     path = download(url)
#     open(io-> bytes2hex(BinaryProvider.sha256(io)), path)
# end
# url2hash("https://www.cairographics.org/releases/cairo-1.14.12.tar.xz") |> println

sources = [
    "https://www.cairographics.org/releases/cairo-1.14.12.tar.xz" =>
    "8c90f00c500b2299c0a323dd9beead2a00353752b2092ead558139bd67f7bf16",
]

# Bash recipe for building across all platforms
script = raw"""
cd $WORKSPACE/srcdir
cd cairo-1.14.12/
LDFLAGS="-L$prefix/lib" CPPFLAGS="-I$prefix/include" ./configure --prefix=$prefix --host=$target --disable-xlib --disable-ft --disable-dependency-tracking
make -j${ncore}
make install
exit
"""

# These are the platforms we will build for by default, unless further
# platforms are passed in on the command line
platforms = [
    Linux(:x86_64, libc=:glibc),
]

# The products that we will ensure are always built
products(prefix) = [
    LibraryProduct(prefix, "libcairo", :libcairo),
]

# Dependencies that must be installed before this package can be built
dependencies = [
    "https://github.com/bicycle1885/ZlibBuilder/releases/download/v1.0.1/build_Zlib.v1.2.11.jl",
    "https://github.com/SimonDanisch/LibpngBuilder/releases/download/v1.6.31/build_libpng.v1.0.0.jl",
    "https://github.com/staticfloat/PixmanBuilder/releases/download/v0.34.0-1/build_Pixman.v0.34.0.jl",
    "https://github.com/JuliaGraphics/FreeTypeBuilder/releases/download/v2.9.1-1/build_FreeType2.v2.9.1.jl",
]


# Build the tarballs, and possibly a `build.jl` as well.
build_tarballs(ARGS, name, version, sources, script, platforms, products, dependencies)
