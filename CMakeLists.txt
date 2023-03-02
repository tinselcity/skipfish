# ------------------------------------------------------------------------------
# Project setup
# ------------------------------------------------------------------------------
project(skipfish)
cmake_minimum_required(VERSION 3.5)
# ------------------------------------------------------------------------------
# Build options
# ------------------------------------------------------------------------------
option(DEBUG_MODE           "Compile in debug mode." OFF)
option(FORTIFY              "Fortify source." OFF)
option(BUILD_SYMBOLS        "Build with Symbols" OFF)
option(BUILD_TCMALLOC       "Build with tcmalloc" OFF)
option(BUILD_PROFILER       "Enable google cpu and heap profiler support" OFF)
option(BUILD_ASAN           "Build with Address Sanitizer" OFF)
option(BUILD_UBSAN          "Build with Undefined Behavior Sanitizer" OFF)
option(BUILD_TESTS          "Build the unit tests." OFF)
# ------------------------------------------------------------------------------
# Display the current settings
# ------------------------------------------------------------------------------
message(STATUS "Build Configuration:")
message("")
message("    Build Option                               Variable                Value                 ")
message("    -----------------------------------------------------------------------------------------")
message("    Debug mode:                                " "DEBUG_MODE              " ${DEBUG_MODE})
message("    Fortify Source:                            " "FORTIFY                 " ${FORTIFY})
message("    Install path:                              " "INSTALL_PREFIX          " ${CMAKE_INSTALL_PREFIX})
message("    Build Symbols                              " "BUILD_SYMBOLS           " ${BUILD_SYMBOLS})
message("    Build with tcmalloc:                       " "BUILD_TCMALLOC          " ${BUILD_TCMALLOC})
message("    Enable google cpu/heap profiler support:   " "BUILD_PROFILER          " ${BUILD_PROFILER})
message("    Build with Address Sanitizer:              " "BUILD_ASAN              " ${BUILD_ASAN})
message("    Build with Undefined Behavior Sanitizer:   " "BUILD_UBSAN             " ${BUILD_UBSAN})
message("    Build unit tests:                          " "BUILD_TESTS             " ${BUILD_TESTS})
message("")
# ------------------------------------------------------------------------------
# fail if not found
# ------------------------------------------------------------------------------
macro(fail_if_not_found_library a_lib)
  find_library(${a_lib}_LIBRARY
               NAME ${a_lib}
               PATH_SUFFIXES ${CMAKE_LIBRARY_ARCHITECTURE})
  if(NOT ${a_lib}_LIBRARY)
    message(FATAL_ERROR "${a_lib} library not found")
  endif()
  set(LIBRARIES ${LIBRARIES} ${a_lib})
endmacro(fail_if_not_found_library)
# ------------------------------------------------------------------------------
# ASAN
# ------------------------------------------------------------------------------
if(BUILD_ASAN)
  set(DEBUG_LIBRARIES asan ${DEBUG_LIBRARIES})
  add_definitions(-g3 -fno-omit-frame-pointer -fsanitize=address)
  set(DEBUG_MODE ON)
  set(BUILD_PROFILER OFF)
  set(BUILD_TCMALLOC OFF)
# ------------------------------------------------------------------------------
# UBSAN
# ------------------------------------------------------------------------------
elseif(BUILD_UBSAN)
  set(DEBUG_LIBRARIES ubsan ${DEBUG_LIBRARIES})
  add_definitions(-g3 -fno-omit-frame-pointer -fsanitize=undefined -fno-sanitize-recover)
  set(DEBUG_MODE ON)
  set(BUILD_PROFILER OFF)
  set(BUILD_TCMALLOC OFF)
endif()
# ------------------------------------------------------------------------------
# Build PROFILER
# ------------------------------------------------------------------------------
if(BUILD_PROFILER)
  add_definitions(-DENABLE_PROFILER=1)
  if(BUILD_UBUNTU)
    fail_if_not_found_library(libprofiler.a)
    set(LIBRARIES ${LIBRARIES} unwind)
  else()
    set(LIBRARIES ${LIBRARIES} tcmalloc profiler)
  endif()
endif()
# ------------------------------------------------------------------------------
# Build TCMALLOC
# ------------------------------------------------------------------------------
if(BUILD_TCMALLOC)
  if(BUILD_UBUNTU)
    fail_if_not_found_library(libtcmalloc.a)
    fail_if_not_found_library(libunwind.a)
    LIST(APPEND LIBRARIES pthread)
  endif()
  add_definitions(-DBUILD_TCMALLOC)
endif()
# ------------------------------------------------------------------------------
# std libraries
# ------------------------------------------------------------------------------
#set(LIBRARIES ${LIBRARIES} dl)
#set(LIBRARIES ${LIBRARIES} pthread)
#set(LIBRARIES ${LIBRARIES} crypto)
#if(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
#  set(LIBRARIES ${LIBRARIES} rt)
#endif(${CMAKE_SYSTEM_NAME} MATCHES "Linux")
#set(LIBRARIES ${LIBRARIES} m)
message(STATUS "Libraries: ${LIBRARIES}")
# ------------------------------------------------------------------------------
#
# ------------------------------------------------------------------------------
# make the cmake list variables into .deb-compatible strings
string(REPLACE ";" ", " CPACK_DEBIAN_PACKAGE_DEPENDS "${CPACK_DEBIAN_PACKAGE_DEPENDS_LIST}")
string(REPLACE ";" ", " CPACK_DEBIAN_PACKAGE_BUILDS_DEPENDS "${CPACK_DEBIAN_PACKAGE_BUILDS_DEPENDS_LIST}")
# ------------------------------------------------------------------------------
# Version
# ------------------------------------------------------------------------------
EXECUTE_PROCESS(COMMAND git -C ${CMAKE_SOURCE_DIR} describe --tags OUTPUT_VARIABLE VERSION OUTPUT_STRIP_TRAILING_WHITESPACE)
add_definitions(-DSKIPFISH_VERSION="${VERSION}")
# ------------------------------------------------------------------------------
# Debian Package Support
# ------------------------------------------------------------------------------
EXECUTE_PROCESS(COMMAND lsb_release -cs OUTPUT_VARIABLE DISTRIBUTION OUTPUT_STRIP_TRAILING_WHITESPACE)
SET(CPACK_GENERATOR "DEB")
SET(CPACK_DEBIAN_PACKAGE_VERSION "${VERSION}-${DISTRIBUTION}")
SET(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "amd64")
if(BUILD_ASAN)
  SET(CPACK_PACKAGE_FILE_NAME "skipfish_${CPACK_DEBIAN_PACKAGE_VERSION}_${CPACK_DEBIAN_PACKAGE_ARCHITECTURE}-debug")
else()
  SET(CPACK_PACKAGE_FILE_NAME "skipfish_${CPACK_DEBIAN_PACKAGE_VERSION}_${CPACK_DEBIAN_PACKAGE_ARCHITECTURE}")
endif()
SET(CPACK_DEBIAN_PACKAGE_NAME "skipfish")
SET(CPACK_DEBIAN_PACKAGE_MAINTAINER "Reed Morrison")
SET(CPACK_PACKAGE_DESCRIPTION_SUMMARY "skipfish - web application security scanner")
SET(CPACK_PACKAGE_DESCRIPTION "active web application security reconnaissance tool")
message(STATUS "Package Configuration:")
message("")
message("    Option                                     Value                     ")
message("    ---------------------------------------------------------------------")
message("    Package Version:                           ${CPACK_DEBIAN_PACKAGE_VERSION}")
message("")
INCLUDE(CPack)
# ------------------------------------------------------------------------------
# include source/test directories
# ------------------------------------------------------------------------------
add_subdirectory(src)
if(BUILD_TESTS)
  enable_testing()
  add_subdirectory(tests)
endif()
# ------------------------------------------------------------------------------
# release target
# NOTE deb has to exist in order to create tar.gz
# ------------------------------------------------------------------------------
if(BUILD_ASAN)
  SET(RELEASE_PACKAGE_FILE_NAME "skipfish_${CPACK_DEBIAN_PACKAGE_VERSION}_${CPACK_DEBIAN_PACKAGE_ARCHITECTURE}-debug.deb")
else()
  SET(RELEASE_PACKAGE_FILE_NAME "skipfish_${CPACK_DEBIAN_PACKAGE_VERSION}_${CPACK_DEBIAN_PACKAGE_ARCHITECTURE}.deb")
endif()
add_custom_target(release
  COMMAND ${CMAKE_SOURCE_DIR}/support/deb2tar.sh -d ${CMAKE_BINARY_DIR}/${RELEASE_PACKAGE_FILE_NAME}
  WORKING_DIRECTORY ${CMAKE_BINARY_DIR}
)

