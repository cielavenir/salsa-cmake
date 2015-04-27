set(APPLE 1)

# Darwin versions:
#   6.x == Mac OSX 10.2 (Jaguar)
#   7.x == Mac OSX 10.3 (Panther)
#   8.x == Mac OSX 10.4 (Tiger)
#   9.x == Mac OSX 10.5 (Leopard)
#  10.x == Mac OSX 10.6 (Snow Leopard)
#  11.x == Mac OSX 10.7 (Lion)
#  12.x == Mac OSX 10.8 (Mountain Lion)
string(REGEX REPLACE "^([0-9]+)\\.([0-9]+).*$" "\\1" DARWIN_MAJOR_VERSION "${CMAKE_SYSTEM_VERSION}")
string(REGEX REPLACE "^([0-9]+)\\.([0-9]+).*$" "\\2" DARWIN_MINOR_VERSION "${CMAKE_SYSTEM_VERSION}")

# Do not use the "-Wl,-search_paths_first" flag with the OSX 10.2 compiler.
# Done this way because it is too early to do a TRY_COMPILE.
if(NOT DEFINED HAVE_FLAG_SEARCH_PATHS_FIRST)
  set(HAVE_FLAG_SEARCH_PATHS_FIRST 0)
  if("${DARWIN_MAJOR_VERSION}" GREATER 6)
    set(HAVE_FLAG_SEARCH_PATHS_FIRST 1)
  endif()
endif()
# More desirable, but does not work:
  #include(CheckCXXCompilerFlag)
  #CHECK_CXX_COMPILER_FLAG("-Wl,-search_paths_first" HAVE_FLAG_SEARCH_PATHS_FIRST)

set(CMAKE_SHARED_LIBRARY_PREFIX "lib")
set(CMAKE_SHARED_LIBRARY_SUFFIX ".dylib")
set(CMAKE_SHARED_MODULE_PREFIX "lib")
set(CMAKE_SHARED_MODULE_SUFFIX ".so")
set(CMAKE_MODULE_EXISTS 1)
set(CMAKE_DL_LIBS "")

# Enable rpath support for 10.5 and greater where it is known to work.
if("${DARWIN_MAJOR_VERSION}" GREATER 8)
  set(CMAKE_SHARED_LIBRARY_RUNTIME_C_FLAG "-Wl,-rpath,")
endif()

set(CMAKE_C_OSX_COMPATIBILITY_VERSION_FLAG "-compatibility_version ")
set(CMAKE_C_OSX_CURRENT_VERSION_FLAG "-current_version ")
set(CMAKE_CXX_OSX_COMPATIBILITY_VERSION_FLAG "${CMAKE_C_OSX_COMPATIBILITY_VERSION_FLAG}")
set(CMAKE_CXX_OSX_CURRENT_VERSION_FLAG "${CMAKE_C_OSX_CURRENT_VERSION_FLAG}")

set(CMAKE_C_LINK_FLAGS "-Wl,-headerpad_max_install_names")
set(CMAKE_CXX_LINK_FLAGS "-Wl,-headerpad_max_install_names")

if(HAVE_FLAG_SEARCH_PATHS_FIRST)
  set(CMAKE_C_LINK_FLAGS "-Wl,-search_paths_first ${CMAKE_C_LINK_FLAGS}")
  set(CMAKE_CXX_LINK_FLAGS "-Wl,-search_paths_first ${CMAKE_CXX_LINK_FLAGS}")
endif()

set(CMAKE_PLATFORM_HAS_INSTALLNAME 1)
set(CMAKE_SHARED_LIBRARY_CREATE_C_FLAGS "-dynamiclib -Wl,-headerpad_max_install_names")
set(CMAKE_SHARED_MODULE_CREATE_C_FLAGS "-bundle -Wl,-headerpad_max_install_names")
set(CMAKE_SHARED_MODULE_LOADER_C_FLAG "-Wl,-bundle_loader,")
set(CMAKE_SHARED_MODULE_LOADER_CXX_FLAG "-Wl,-bundle_loader,")
set(CMAKE_FIND_LIBRARY_SUFFIXES ".dylib" ".so" ".a")

# hack: if a new cmake (which uses CMAKE_INSTALL_NAME_TOOL) runs on an old build tree
# (where install_name_tool was hardcoded) and where CMAKE_INSTALL_NAME_TOOL isn't in the cache
# and still cmake didn't fail in CMakeFindBinUtils.cmake (because it isn't rerun)
# hardcode CMAKE_INSTALL_NAME_TOOL here to install_name_tool, so it behaves as it did before, Alex
if(NOT DEFINED CMAKE_INSTALL_NAME_TOOL)
  find_program(CMAKE_INSTALL_NAME_TOOL install_name_tool)
  mark_as_advanced(CMAKE_INSTALL_NAME_TOOL)
endif()

# Make sure the combination of SDK and Deployment Target are allowed
if(CMAKE_OSX_DEPLOYMENT_TARGET)
  if("${_CMAKE_OSX_SYSROOT_PATH}" MATCHES "/MacOSX([0-9]+\\.[0-9]+)[^/]*\\.sdk")
    set(_sdk_ver "${CMAKE_MATCH_1}")
  elseif("${_CMAKE_OSX_SYSROOT_ORIG}" MATCHES "^macosx([0-9]+\\.[0-9]+)$")
    set(_sdk_ver "${CMAKE_MATCH_1}")
  elseif("${_CMAKE_OSX_SYSROOT_ORIG}" STREQUAL "/")
    set(_sdk_ver "${_CURRENT_OSX_VERSION}")
  else()
    message(FATAL_ERROR
      "CMAKE_OSX_DEPLOYMENT_TARGET is '${CMAKE_OSX_DEPLOYMENT_TARGET}' "
      "but CMAKE_OSX_SYSROOT:\n \"${_CMAKE_OSX_SYSROOT_ORIG}\"\n"
      "is not set to a MacOSX SDK with a recognized version.  "
      "Either set CMAKE_OSX_SYSROOT to a valid SDK or set "
      "CMAKE_OSX_DEPLOYMENT_TARGET to empty.")
  endif()
  if(CMAKE_OSX_DEPLOYMENT_TARGET VERSION_GREATER "${_sdk_ver}")
    message(FATAL_ERROR
      "CMAKE_OSX_DEPLOYMENT_TARGET (${CMAKE_OSX_DEPLOYMENT_TARGET}) "
      "is greater than CMAKE_OSX_SYSROOT SDK:\n ${_CMAKE_OSX_SYSROOT_ORIG}\n"
      "Please set CMAKE_OSX_DEPLOYMENT_TARGET to ${_sdk_ver} or lower.")
  endif()
endif()

# Enable shared library versioning.
set(CMAKE_SHARED_LIBRARY_SONAME_C_FLAG "-install_name")

# Xcode does not support -isystem yet.
if(XCODE)
  set(CMAKE_INCLUDE_SYSTEM_FLAG_C)
  set(CMAKE_INCLUDE_SYSTEM_FLAG_CXX)
endif()

if("${_CURRENT_OSX_VERSION}" VERSION_LESS "10.5")
  # Need to list dependent shared libraries on link line.  When building
  # with -isysroot (for universal binaries), the linker always looks for
  # dependent libraries under the sysroot.  Listing them on the link
  # line works around the problem.
  set(CMAKE_LINK_DEPENDENT_LIBRARY_FILES 1)
endif()

set(CMAKE_C_CREATE_SHARED_LIBRARY_FORBIDDEN_FLAGS -w)
set(CMAKE_CXX_CREATE_SHARED_LIBRARY_FORBIDDEN_FLAGS -w)
set(CMAKE_C_CREATE_SHARED_LIBRARY
  "<CMAKE_C_COMPILER> <LANGUAGE_COMPILE_FLAGS> <CMAKE_SHARED_LIBRARY_CREATE_C_FLAGS> <LINK_FLAGS> -o <TARGET> <SONAME_FLAG> <TARGET_INSTALLNAME_DIR><TARGET_SONAME> <OBJECTS> <LINK_LIBRARIES>")
set(CMAKE_CXX_CREATE_SHARED_LIBRARY
  "<CMAKE_CXX_COMPILER> <LANGUAGE_COMPILE_FLAGS> <CMAKE_SHARED_LIBRARY_CREATE_CXX_FLAGS> <LINK_FLAGS> -o <TARGET> <SONAME_FLAG> <TARGET_INSTALLNAME_DIR><TARGET_SONAME> <OBJECTS> <LINK_LIBRARIES>")
set(CMAKE_Fortran_CREATE_SHARED_LIBRARY
  "<CMAKE_Fortran_COMPILER> <LANGUAGE_COMPILE_FLAGS> <CMAKE_SHARED_LIBRARY_CREATE_Fortran_FLAGS> <LINK_FLAGS> -o <TARGET> <SONAME_FLAG> <TARGET_INSTALLNAME_DIR><TARGET_SONAME> <OBJECTS> <LINK_LIBRARIES>")

set(CMAKE_CXX_CREATE_SHARED_MODULE
      "<CMAKE_CXX_COMPILER> <LANGUAGE_COMPILE_FLAGS> <CMAKE_SHARED_MODULE_CREATE_CXX_FLAGS> <LINK_FLAGS> -o <TARGET> <OBJECTS> <LINK_LIBRARIES>")

set(CMAKE_C_CREATE_SHARED_MODULE
      "<CMAKE_C_COMPILER>  <LANGUAGE_COMPILE_FLAGS> <CMAKE_SHARED_MODULE_CREATE_C_FLAGS> <LINK_FLAGS> -o <TARGET> <OBJECTS> <LINK_LIBRARIES>")

set(CMAKE_Fortran_CREATE_SHARED_MODULE
      "<CMAKE_Fortran_COMPILER>  <LANGUAGE_COMPILE_FLAGS> <CMAKE_SHARED_MODULE_CREATE_Fortran_FLAGS> <LINK_FLAGS> -o <TARGET> <OBJECTS> <LINK_LIBRARIES>")

set(CMAKE_C_CREATE_MACOSX_FRAMEWORK
      "<CMAKE_C_COMPILER> <LANGUAGE_COMPILE_FLAGS> <CMAKE_SHARED_LIBRARY_CREATE_C_FLAGS> <LINK_FLAGS> -o <TARGET> <SONAME_FLAG> <TARGET_INSTALLNAME_DIR><TARGET_SONAME> <OBJECTS> <LINK_LIBRARIES>")
set(CMAKE_CXX_CREATE_MACOSX_FRAMEWORK
      "<CMAKE_CXX_COMPILER> <LANGUAGE_COMPILE_FLAGS> <CMAKE_SHARED_LIBRARY_CREATE_CXX_FLAGS> <LINK_FLAGS> -o <TARGET> <SONAME_FLAG> <TARGET_INSTALLNAME_DIR><TARGET_SONAME> <OBJECTS> <LINK_LIBRARIES>")

# Set default framework search path flag for languages known to use a
# preprocessor that may find headers in frameworks.
set(CMAKE_C_FRAMEWORK_SEARCH_FLAG -F)
set(CMAKE_CXX_FRAMEWORK_SEARCH_FLAG -F)
set(CMAKE_Fortran_FRAMEWORK_SEARCH_FLAG -F)

# default to searching for frameworks first
if(NOT DEFINED CMAKE_FIND_FRAMEWORK)
  set(CMAKE_FIND_FRAMEWORK FIRST)
endif()

# Older OS X linkers do not report their framework search path
# with -v but "man ld" documents the following locations.
set(CMAKE_PLATFORM_IMPLICIT_LINK_FRAMEWORK_DIRECTORIES
  ${_CMAKE_OSX_SYSROOT_PATH}/Library/Frameworks
  ${_CMAKE_OSX_SYSROOT_PATH}/System/Library/Frameworks
  )
if(_CMAKE_OSX_SYSROOT_PATH)
  # Treat some paths as implicit so we do not override the SDK versions.
  list(APPEND CMAKE_PLATFORM_IMPLICIT_LINK_FRAMEWORK_DIRECTORIES
    /System/Library/Frameworks)
endif()
if("${_CURRENT_OSX_VERSION}" VERSION_LESS "10.5")
  # Older OS X tools had more implicit paths.
  list(APPEND CMAKE_PLATFORM_IMPLICIT_LINK_FRAMEWORK_DIRECTORIES
    ${_CMAKE_OSX_SYSROOT_PATH}/Network/Library/Frameworks)
endif()

# set up the default search directories for frameworks
set(CMAKE_SYSTEM_FRAMEWORK_PATH
  ~/Library/Frameworks
  )
if(_CMAKE_OSX_SYSROOT_PATH)
  list(APPEND CMAKE_SYSTEM_FRAMEWORK_PATH
    ${_CMAKE_OSX_SYSROOT_PATH}/Library/Frameworks
    ${_CMAKE_OSX_SYSROOT_PATH}/Network/Library/Frameworks
    ${_CMAKE_OSX_SYSROOT_PATH}/System/Library/Frameworks
    )
endif()
list(APPEND CMAKE_SYSTEM_FRAMEWORK_PATH
  /Library/Frameworks
  /Network/Library/Frameworks
  /System/Library/Frameworks)

# Warn about known system mis-configuration case.
if(CMAKE_OSX_SYSROOT)
  get_property(_IN_TC GLOBAL PROPERTY IN_TRY_COMPILE)
  if(NOT _IN_TC AND
     NOT IS_SYMLINK "${CMAKE_OSX_SYSROOT}/Library/Frameworks"
     AND IS_SYMLINK "${CMAKE_OSX_SYSROOT}/Library/Frameworks/Frameworks")
    message(WARNING "The SDK Library/Frameworks path\n"
      " ${CMAKE_OSX_SYSROOT}/Library/Frameworks\n"
      "is not set up correctly on this system.  "
      "This is known to occur when installing Xcode 3.2.6:\n"
      " http://bugs.python.org/issue14018\n"
      "The problem may cause build errors that report missing system frameworks.  "
      "Fix your SDK symlinks to resolve this issue and avoid this warning."
      )
  endif()
endif()

# default to searching for application bundles first
if(NOT DEFINED CMAKE_FIND_APPBUNDLE)
  set(CMAKE_FIND_APPBUNDLE FIRST)
endif()
# set up the default search directories for application bundles
set(_apps_paths)
foreach(_path
  "~/Applications"
  "/Applications"
  "${OSX_DEVELOPER_ROOT}/../Applications" # Xcode 4.3+
  "${OSX_DEVELOPER_ROOT}/Applications"    # pre-4.3
  )
  get_filename_component(_apps "${_path}" ABSOLUTE)
  if(EXISTS "${_apps}")
    list(APPEND _apps_paths "${_apps}")
  endif()
endforeach()
if(_apps_paths)
  list(REMOVE_DUPLICATES _apps_paths)
endif()
set(CMAKE_SYSTEM_APPBUNDLE_PATH
  ${_apps_paths})
unset(_apps_paths)

include(Platform/UnixPaths)
if(_CMAKE_OSX_SYSROOT_PATH AND EXISTS ${_CMAKE_OSX_SYSROOT_PATH}/usr/include)
  list(APPEND CMAKE_SYSTEM_PREFIX_PATH ${_CMAKE_OSX_SYSROOT_PATH}/usr)
  foreach(lang C CXX)
    list(APPEND CMAKE_${lang}_IMPLICIT_INCLUDE_DIRECTORIES ${_CMAKE_OSX_SYSROOT_PATH}/usr/include)
  endforeach()
endif()
list(APPEND CMAKE_SYSTEM_PREFIX_PATH
  /sw        # Fink
  /opt/local # MacPorts
  )
