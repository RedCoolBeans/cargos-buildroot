################################################################################
#
# cmake
#
################################################################################

CMAKE_VERSION_MAJOR = 3.1
CMAKE_VERSION = $(CMAKE_VERSION_MAJOR).3
CMAKE_SITE = http://www.cmake.org/files/v$(CMAKE_VERSION_MAJOR)
CMAKE_LICENSE = BSD-3c
CMAKE_LICENSE_FILES = Copyright.txt

HOST_CMAKE_DEPENDENCIES = host-pkgconf

# Get rid of -I* options from $(HOST_CPPFLAGS) to prevent that a
# header available in $(HOST_DIR)/usr/include is used instead of a
# CMake internal header, e.g. lzma* headers of the xz package
HOST_CMAKE_CFLAGS = $(shell echo $(HOST_CFLAGS) | sed -r "s%$(HOST_CPPFLAGS)%%")
HOST_CMAKE_CXXFLAGS = $(shell echo $(HOST_CXXFLAGS) | sed -r "s%$(HOST_CPPFLAGS)%%")

define HOST_CMAKE_CONFIGURE_CMDS
	(cd $(@D); \
		LDFLAGS="$(HOST_LDFLAGS)" \
		CFLAGS="$(HOST_CMAKE_CFLAGS)" \
		./bootstrap --prefix=$(HOST_DIR)/usr \
			--parallel=$(PARALLEL_JOBS) -- \
			-DCMAKE_C_FLAGS="$(HOST_CMAKE_CFLAGS)" \
			-DCMAKE_CXX_FLAGS="$(HOST_CMAKE_CXXFLAGS)" \
			-DCMAKE_EXE_LINKER_FLAGS="$(HOST_LDFLAGS)" \
			-DBUILD_CursesDialog=OFF \
	)
endef

define HOST_CMAKE_BUILD_CMDS
	$(HOST_MAKE_ENV) $(MAKE) -C $(@D)
endef

define HOST_CMAKE_INSTALL_CMDS
	$(HOST_MAKE_ENV) $(MAKE) -C $(@D) install
endef

$(eval $(host-generic-package))
