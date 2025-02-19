cmake_minimum_required(VERSION 3.0)

# Configure CMake for compiling to wasm
if(COMPILE_TO_WASM)
  if (NOT THREAD_BENCHMARKS)
    message(STATUS "Compiling to wasm without threads")
    set(CMAKE_TOOLCHAIN_FILE "${WASI_SDK_PATH}/share/cmake/wasi-sdk.cmake")
  else(THREAD_BENCHMARKS)
    message(STATUS "Compiling to wasm with threads")
    set(CMAKE_TOOLCHAIN_FILE "${WASI_SDK_PATH}/share/cmake/wasi-sdk-pthread.cmake")
  endif()
endif()



project(mimalloc-bench CXX C)
set(CMAKE_CXX_STANDARD 17)

if (NOT CMAKE_BUILD_TYPE)
  message(STATUS "No build type selected, default to *** Release ***")
  set(CMAKE_BUILD_TYPE "Release")
endif()

FUNCTION(PREPEND var prefix)
   SET(listVar "")
   FOREACH(f ${ARGN})
      LIST(APPEND listVar "${prefix}/${f}")
   ENDFOREACH(f)
   SET(${var} "${listVar}" PARENT_SCOPE)
ENDFUNCTION(PREPEND)

set(cfrac_sources
    cfrac.c
    pops.c pconst.c pio.c
    pabs.c pneg.c pcmp.c podd.c phalf.c
    padd.c psub.c pmul.c pdivmod.c psqrt.c ppowmod.c
    atop.c ptoa.c itop.c utop.c ptou.c errorp.c
    pfloat.c pidiv.c pimod.c picmp.c
    primes.c pcfrac.c pgcd.c)
PREPEND(cfrac_sources cfrac/ ${cfrac_sources})

set(espresso_sources
    cofactor.c cols.c compl.c contain.c cubestr.c cvrin.c cvrm.c cvrmisc.c cvrout.c
    dominate.c equiv.c espresso.c essen.c exact.c expand.c gasp.c getopt.c gimpel.c
    globals.c hack.c indep.c irred.c main.c map.c matrix.c mincov.c opo.c pair.c part.c
    primes.c reduce.c rows.c set.c setc.c sharp.c sminterf.c solution.c sparse.c unate.c
    utility.c verify.c)
PREPEND(espresso_sources espresso/ ${espresso_sources})

set(barnes_sources
    code.c code_io.c load.c grav.c getparam.c util.c)
PREPEND(barnes_sources barnes/ ${barnes_sources})


# turn off warnings..
message(STATUS "${CMAKE_C_COMPILER_ID}")
if(CMAKE_C_COMPILER_ID MATCHES "AppleClang|Clang|GNU")
  set(FLAGS " -w -Wno-implicit-function-declaration -Wno-implicit-int -Wno-int-conversion")
  string(APPEND CMAKE_C_FLAGS ${FLAGS})
  string(APPEND CMAKE_CXX_FLAGS ${FLAGS})
endif()


# Set common flags for wasm compilation
if (COMPILE_TO_WASM)
  set(CMAKE_EXECUTABLE_SUFFIX ".wasm")
  set(WASI_FLAGS " -D_WASI_EMULATED_PROCESS_CLOCKS -lwasi-emulated-process-clocks -D_WASI_EMULATED_SIGNAL -lwasi-emulated-signal -DWASM=1")
  string(APPEND CMAKE_C_FLAGS ${WASI_FLAGS})
  string(APPEND CMAKE_CXX_FLAGS ${WASI_FLAGS})
endif()

# Set common flags for mimalloc compilation
if(USE_MIMALLOC)
  set(MIMALLOC_FLAGS " -L../mimalloc/build_wasm -lmimalloc")
  string(APPEND CMAKE_C_FLAGS ${MIMALLOC_FLAGS})
  string(APPEND CMAKE_CXX_FLAGS ${MIMALLOC_FLAGS})
  set(CMAKE_EXECUTABLE_SUFFIX "_mimalloc.wasm")
endif()

# Set common flags for musl copmilation
if(COMPILE_WITH_MUSL)
  set(CMAKE_C_COMPILER "${MUSL_PATH}/bin/x86_64-linux-musl-gcc")
  set(CMAKE_CXX_COMPILER "${MUSL_PATH}/bin/x86_64-linux-musl-g++")
  set(MUSL_FLAGS " -Wl,-rpath,${MUSL_PATH}/x86_64-linux-musl/lib")
  string(APPEND CMAKE_C_FLAGS ${MUSL_FLAGS})
  string(APPEND CMAKE_CXX_FLAGS ${MUSL_FLAGS})
  set(CMAKE_EXECUTABLE_SUFFIX ".musl")
endif()


# NON THREADED BENCHMARKS
if (NOT THREAD_BENCHMARKS)

  add_executable(cfrac ${cfrac_sources})
  target_compile_options(cfrac PRIVATE $<$<C_COMPILER_ID:GNU>:-std=gnu89>)
  target_compile_definitions(cfrac PRIVATE NOMEMOPT=1)
  target_link_libraries(cfrac m)

  add_executable(espresso ${espresso_sources})
  target_compile_options(espresso PRIVATE $<$<C_COMPILER_ID:GNU>:-std=gnu89> -D_WASI_EMULATED_PROCESS_CLOCKS ) # if clock emulaton is not added explicitly crushes ¿Why?
  target_link_libraries(espresso m)

  add_executable(malloc-large malloc-large/malloc-large.cpp)

  add_executable(bench-malloc-simple bench-malloc/bench-malloc-simple.c)
  target_compile_options(bench-malloc-simple PRIVATE -D_WASI_EMULATED_PROCESS_CLOCKS )

endif()


# THREADED BENCHMARKS
if (THREAD_BENCHMARKS)

  # Set flags for wasi threads
  if(COMPILE_TO_WASM)
    set(WASI_FLAGS " -Wl,--import-memory,--export-memory,--max-memory=4294967296")
    string(APPEND CMAKE_C_FLAGS ${WASI_FLAGS})
    string(APPEND CMAKE_CXX_FLAGS ${WASI_FLAGS})
  endif()

  add_executable(larson larson/larson.cpp)
  target_compile_options(larson PRIVATE -Wno-unused-result)
  target_compile_definitions(larson PRIVATE CPP=1)
  target_link_libraries(larson pthread)

  add_executable(larson-sized larson/larson.cpp)
  target_compile_options(larson-sized PRIVATE -Wno-unused-result -fsized-deallocation)
  target_compile_definitions(larson-sized PRIVATE CPP=1 SIZED=1)
  target_link_libraries(larson-sized pthread)

  add_executable(mstress mstress/mstress.c)
  target_link_libraries(mstress pthread)

  add_executable(mleak mleak/mleak.c)
  target_link_libraries(mleak pthread)

  add_executable(bench-malloc-threads bench-malloc/bench-malloc-threads.c)
  target_link_libraries(bench-malloc-threads pthread)

  add_executable(xmalloc-test xmalloc-test/xmalloc-test.c)
  target_link_libraries(xmalloc-test pthread)

  add_executable(t-test1 t-test1/t-test1.c)
  target_link_libraries(t-test1 pthread)
  
endif()






# error: unreachable instrtuction executed
#add_executable(barnes ${barnes_sources})
#target_link_libraries(barnes m)

# error: variable has incomplete type 'struct sigaction'
#add_executable(glibc-thread glibc-bench/bench-malloc-thread.c)
#target_link_libraries(glibc-thread pthread)

# error: unreachable instrtuction executed
#add_executable(rptest rptest/rptest.c rptest/thread.c rptest/timer.c)
#target_compile_options(rptest PRIVATE -fpermissive)
#target_include_directories(rptest PRIVATE rptest)
#target_link_libraries(rptest pthread m)
#target_compile_definitions(rptest PRIVATE __MACH__=1) # __MACH__ to avoid using memalign in benchmark.h
