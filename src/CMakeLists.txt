# ------------------------------------------------------------------------------
# include paths
# ------------------------------------------------------------------------------
include_directories(
  # ------------------------------------------------------
  # brew support
  # ------------------------------------------------------
  /usr/local/opt/openssl/include
  /usr/local/opt/pcre/include
  /opt/homebrew/opt/openssl/include
  /opt/homebrew/opt/pcre/include
  ${CMAKE_CURRENT_SOURCE_DIR}
)
# ------------------------------------------------------------------------------
# sources
# ------------------------------------------------------------------------------
SET(SRCS
  analysis.c
  checks.c
  database.c
  options.c
  signatures.c
  auth.c
  crawler.c
  http_client.c
  report.c
  skipfish.c
)
SET_SOURCE_FILES_PROPERTIES(${SRCS} PROPERTIES LANGUAGE C)
add_executable(skipfish_cmd ${HDRS} ${SRCS})
# ------------------------------------------------------------------------------
# flags...
# ------------------------------------------------------------------------------
target_compile_options(skipfish_cmd PRIVATE
  -Wall
  #-Werror
  -funsigned-char
  -g
  -ggdb
)
# if debug mode
if(DEBUG_MODE)
  target_compile_options(skipfish_cmd PRIVATE
    -DLOG_STDERR=1
    -DDEBUG_ALLOCATOR=1
  )
else()
  target_compile_options(skipfish_cmd PRIVATE
    -O3
    -Wno-format
  )
endif()
# ------------------------------------------------------------------------------
# build and install
# ------------------------------------------------------------------------------
SET_TARGET_PROPERTIES(skipfish_cmd PROPERTIES OUTPUT_NAME "skipfish")
target_link_libraries(skipfish_cmd
  ${DEBUG_LIBRARIES}
  pcre
  ssl
  z
  idn
)
install(TARGETS skipfish_cmd
  DESTINATION ${CMAKE_INSTALL_PREFIX}/bin/
  COMPONENT Executables
)
