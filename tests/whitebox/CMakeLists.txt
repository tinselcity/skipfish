# ------------------------------------------------------------------------------
# Fortify Options
# ------------------------------------------------------------------------------
if (FORTIFY)
  add_definitions(-D_FORTIFY_SOURCE=2 -O1 -Wl,-z,relro,-z,now)
endif()
if(DEBUG_MODE)
  add_definitions(-O0 -g3)
else()
  add_definitions(-O2)
endif()
if(BUILD_SYMBOLS)
  add_definitions(-g3)
endif()
# ------------------------------------------------------------------------------
# flags
# ------------------------------------------------------------------------------
set(CMAKE_C_FLAGS "-Wall -g -ggdb")
# ------------------------------------------------------------------------------
# include directories
# ------------------------------------------------------------------------------
include_directories(
  ${CMAKE_SOURCE_DIR}/src
  ${CMAKE_CURRENT_SOURCE_DIR}
)
# ------------------------------------------------------------------------------
# macros
# ------------------------------------------------------------------------------
SET(SRCS
  ${CMAKE_SOURCE_DIR}/src/analysis.c
  ${CMAKE_SOURCE_DIR}/src/auth.c
  ${CMAKE_SOURCE_DIR}/src/checks.c
  ${CMAKE_SOURCE_DIR}/src/crawler.c
  ${CMAKE_SOURCE_DIR}/src/database.c
  ${CMAKE_SOURCE_DIR}/src/http_client.c
  ${CMAKE_SOURCE_DIR}/src/report.c
  ${CMAKE_SOURCE_DIR}/src/signatures.c
  same_test.c
)
add_executable(wb_same_test ${SRCS})
target_compile_definitions(wb_same_test PUBLIC TEST_RESOURCE_DIR="${CMAKE_CURRENT_SOURCE_DIR}/data/")
target_link_libraries(wb_same_test
  ${DEBUG_LIBRARIES}
  pcre
  ssl
  z
  idn
)
add_test(wb_same_test same_test)
set_property(TEST wb_same_test PROPERTY ENVIRONMENT "ASAN_OPTIONS=detect_odr_violation=0")
