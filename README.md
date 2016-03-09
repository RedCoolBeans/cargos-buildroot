# CargOS and Parcel

CargOS is a new lightweight, open source, platform for Docker hosts that aims
for speed, manageability and security.

Parcel is an even further stripped version of CargOS that serves as a base for
Docker images.

This repository contains the sources for [buildroot](https://buildroot.org/) to build CargOS and Parcel
images.

## Building from source

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

Then proceed to build CargOS/Parcel, replace `${platform}` with the platform you're
building for, e.g. `x86_64` and ${target} with `cargos` or `parcel`:

1. run `make ${target}_${platform}_defconfig`
2. run `make`
3. wait while it compiles

**You do not need to be root to build or run buildroot.  Have fun!**

## Caveats

- Development on support Raspberry Pi 2 has stalled. Some code is available in
  this repository, but isn't kept up to date. The installer is the next component
  that needs work.

## License

Buildroot is [released](https://buildroot.org/downloads/manual/manual.html#legal-info-buildroot) under the GPL v2 or (at your option) any later version.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
