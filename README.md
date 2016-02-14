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

`rpi2` (Raspberry Pi 2)

- dosfstools
- kpartx

Then proceed to build CargOS, replace ${platform} with the platform you're
building for (`x86_64` or `rpi2`)

1. run `make cargos_${platform}_defconfig`
2. run `make`
3. wait while it compiles

**You do not need to be root to build or run buildroot.  Have fun!**

### Caveats

- Support for Raspberry Pi 2 is currently under development and therefore not
  officially supported (yet).
