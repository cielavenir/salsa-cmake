include(RunCMake)

function(run_compiler_launcher lang)
  # Use a single build tree for tests without cleaning.
  set(RunCMake_TEST_BINARY_DIR ${RunCMake_BINARY_DIR}/${lang}-build)
  set(RunCMake_TEST_NO_CLEAN 1)
  file(REMOVE_RECURSE "${RunCMake_TEST_BINARY_DIR}")
  file(MAKE_DIRECTORY "${RunCMake_TEST_BINARY_DIR}")
  run_cmake(${lang})

  set(RunCMake_TEST_OUTPUT_MERGE 1)
  if("${RunCMake_GENERATOR}" STREQUAL "Ninja")
    set(verbose_args -- -v)
  endif()
  run_cmake_command(${lang}-Build ${CMAKE_COMMAND} --build . ${verbose_args})
endfunction()

set(langs C CXX)
if(CMake_TEST_CUDA)
  list(APPEND langs CUDA)
endif()

foreach(lang ${langs})
  run_compiler_launcher(${lang})
  if (NOT RunCMake_GENERATOR STREQUAL "Watcom WMake")
    run_compiler_launcher(${lang}-launch)
  endif()
endforeach()
