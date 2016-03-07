### To build CargOS from scratch, do the following:

Ensure the build dependencies are satisfied, this includes the following,
most of which are normally already installed:

- bc
- bison
- bzip2
- flex
- g++ / gcc-c++
- gcc
- make
- patch
- perl
- perl-Data-Dumper
- perl-Thread-Queue
- qemu-img
- unzip
- wget
- which

Depending on the platform you're building for you'll need these additional
dependencies:

`x86_64` (64-bit capable x86 only)

- squashfs-tools
- xorriso

Then proceed to build CargOS, replace ${platform} with the platform you're
building for, e.g. `x86_64`:

1. run `make cargos_${platform}_defconfig`
2. run `make`
3. wait while it compiles

**You do not need to be root to build or run buildroot.  Have fun!**

### Caveats

- Development on support Raspberry Pi 2 has stalled. Some code is available in
  this repository, but isn't kept up to date. The installer is the next component
  that needs work.
