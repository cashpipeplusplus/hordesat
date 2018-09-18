cmake_minimum_required(VERSION 2.6 FATAL_ERROR)
project(hordesat)


# Get any missing submodules.  It is too easy to check out the main repo without
# its submodules.
if(NOT EXISTS submodules/minisat/README OR NOT EXISTS submodules/lingeling/README)
    message("Updating submodules.")
    execute_process(COMMAND git submodule update --init
                    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
endif()


# Do a release build by default.  This will include aggressive optimizations.
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Release)
endif()


# MPI setup:
find_package(MPI REQUIRED)
find_package(Threads REQUIRED)
message("MPI include dirs: ${MPI_CXX_HEADER_DIR}")
message("MPI compile flags: ${MPI_CXX_COMPILE_OPTIONS}")
message("MPI link flags: ${MPI_CXX_LINK_FLAGS}")


# MiniSat:
add_library(minisat STATIC
    submodules/minisat/minisat/utils/Options.cc
    submodules/minisat/minisat/utils/System.cc
    submodules/minisat/minisat/core/Solver.cc
    submodules/minisat/minisat/simp/SimpSolver.cc)
target_include_directories(minisat PUBLIC
    submodules/minisat/)
target_link_libraries(minisat z)

add_executable(minisat-bin
    submodules/minisat/minisat/simp/Main.cc)
target_link_libraries(minisat-bin minisat)
set_target_properties(minisat-bin
    PROPERTIES OUTPUT_NAME minisat)
install(TARGETS minisat-bin
    RUNTIME DESTINATION bin)


# Lingeling:
set(INTERMEDIATE_DIR "${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_FILES_DIRECTORY}")
add_custom_command(OUTPUT "${INTERMEDIATE_DIR}/lglcfg.h"
    COMMAND "${CMAKE_CURRENT_SOURCE_DIR}/submodules/lingeling/mkconfig.sh" > "${INTERMEDIATE_DIR}/lglcfg.h"
    DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/submodules/lingeling/mkconfig.sh"
    COMMENT "Generating lingeling config"
    VERBATIM)
add_custom_command(OUTPUT "${INTERMEDIATE_DIR}/lglcflags.h"
    COMMAND echo "#define LGL_CC \"$(${CMAKE_C_COMPILER} --version|head -1)\"" > "${INTERMEDIATE_DIR}/lglcflags.h"
    COMMAND echo "#define LGL_CFLAGS \"${CMAKE_C_FLAGS}\"" >> "${INTERMEDIATE_DIR}/lglcflags.h"
    COMMENT "Generating lingeling compiler config"
    VERBATIM)

add_library(lingeling STATIC
    "${INTERMEDIATE_DIR}/lglcfg.h"
    "${INTERMEDIATE_DIR}/lglcflags.h"
    submodules/lingeling/lglib.c
    submodules/lingeling/lglbnr.c
    submodules/lingeling/lgldimacs.c
    submodules/lingeling/lglopts.c)
target_compile_definitions(lingeling PRIVATE
    NLGLOG
    NDEBUG
    NCHKSOL
    NLGLDRUPLIG
    NLGLYALSAT
    NLGLFILES
    NLGLDEMA)
target_include_directories(lingeling PRIVATE
    "${INTERMEDIATE_DIR}")
target_include_directories(lingeling PUBLIC
    submodules/lingeling/)
target_link_libraries(lingeling m)

add_executable(lingeling-bin
    submodules/lingeling/lglmain.c)
target_link_libraries(lingeling-bin lingeling)
set_target_properties(lingeling-bin
    PROPERTIES OUTPUT_NAME lingeling)
install(TARGETS lingeling-bin
    RUNTIME DESTINATION bin)


# HordeSat:
add_executable(hordesat
    src/sharing/LogSharingManager.cpp
    src/sharing/AllToAllSharingManager.cpp
    src/utilities/Logger.cpp
    src/utilities/SatUtils.cpp
    src/utilities/ClauseDatabase.cpp
    src/utilities/ClauseFilter.cpp
    src/solvers/MiniSat.cpp
    src/solvers/Lingeling.cpp
    src/hordesat.cpp)
set_target_properties(hordesat PROPERTIES
    INCLUDE_DIRECTORIES "${MPI_CXX_HEADER_DIR}"
    COMPILE_FLAGS "${MPI_CXX_COMPILE_OPTIONS}"
    LINK_FLAGS "${MPI_CXX_LINK_FLAGS}")
target_link_libraries(hordesat
    minisat
    lingeling
    ${CMAKE_THREAD_LIBS_INIT}
    ${MPI_LIBRARIES})

install(TARGETS hordesat
    RUNTIME DESTINATION bin)
