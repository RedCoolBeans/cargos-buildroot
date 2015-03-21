##### To build CargOS from scratch, do the following:

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
- squashfs-tools
- unzip
- xorriso
- wget

Then proceed to build CargOS:

1. run 'make cargos_x86_defconfig'
2. run 'make'
3. wait while it compiles

##### You do not need to be root to build or run buildroot.  Have fun!
