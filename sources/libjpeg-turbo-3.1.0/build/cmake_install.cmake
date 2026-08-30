# Install script for directory: /home/dev/Desktop/ClaraColour/python/crosstoolsng/libjpeg-turbo-3.1.0

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/home/dev/Desktop/ClaraColour/python/crosstoolsng/jpeg-install")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Release")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Install shared libraries without execute permission?
if(NOT DEFINED CMAKE_INSTALL_SO_NO_EXE)
  set(CMAKE_INSTALL_SO_NO_EXE "1")
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

# Set path to fallback-tool for dependency-resolution.
if(NOT DEFINED CMAKE_OBJDUMP)
  set(CMAKE_OBJDUMP "/home/dev/x-tools/arm-unknown-linux-gnueabihf/bin/arm-unknown-linux-gnueabihf-objdump")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/home/dev/Desktop/ClaraColour/python/crosstoolsng/libjpeg-turbo-3.1.0/build/simd/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/home/dev/Desktop/ClaraColour/python/crosstoolsng/libjpeg-turbo-3.1.0/build/sharedlib/cmake_install.cmake")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for the subdirectory.
  include("/home/dev/Desktop/ClaraColour/python/crosstoolsng/libjpeg-turbo-3.1.0/build/src/md5/cmake_install.cmake")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "lib" OR NOT CMAKE_INSTALL_COMPONENT)
  foreach(file
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libturbojpeg.so.0.4.0"
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libturbojpeg.so.0"
      )
    if(EXISTS "${file}" AND
       NOT IS_SYMLINK "${file}")
      file(RPATH_CHECK
           FILE "${file}"
           RPATH "/home/dev/Desktop/ClaraColour/python/crosstoolsng/jpeg-install/lib")
    endif()
  endforeach()
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE SHARED_LIBRARY FILES
    "/home/dev/Desktop/ClaraColour/python/crosstoolsng/libjpeg-turbo-3.1.0/build/libturbojpeg.so.0.4.0"
    "/home/dev/Desktop/ClaraColour/python/crosstoolsng/libjpeg-turbo-3.1.0/build/libturbojpeg.so.0"
    )
  foreach(file
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libturbojpeg.so.0.4.0"
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libturbojpeg.so.0"
      )
    if(EXISTS "${file}" AND
       NOT IS_SYMLINK "${file}")
      file(RPATH_CHANGE
           FILE "${file}"
           OLD_RPATH "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
           NEW_RPATH "/home/dev/Desktop/ClaraColour/python/crosstoolsng/jpeg-install/lib")
      if(CMAKE_INSTALL_DO_STRIP)
        execute_process(COMMAND "/home/dev/x-tools/arm-unknown-linux-gnueabihf/bin/arm-unknown-linux-gnueabihf-strip" "${file}")
      endif()
    endif()
  endforeach()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "lib" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE SHARED_LIBRARY FILES "/home/dev/Desktop/ClaraColour/python/crosstoolsng/libjpeg-turbo-3.1.0/build/libturbojpeg.so")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "bin" OR NOT CMAKE_INSTALL_COMPONENT)
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/tjbench" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/tjbench")
    file(RPATH_CHECK
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/tjbench"
         RPATH "/home/dev/Desktop/ClaraColour/python/crosstoolsng/jpeg-install/lib")
  endif()
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin" TYPE EXECUTABLE FILES "/home/dev/Desktop/ClaraColour/python/crosstoolsng/libjpeg-turbo-3.1.0/build/tjbench")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/tjbench" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/tjbench")
    file(RPATH_CHANGE
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/tjbench"
         OLD_RPATH "/home/dev/Desktop/ClaraColour/python/crosstoolsng/libjpeg-turbo-3.1.0/build:"
         NEW_RPATH "/home/dev/Desktop/ClaraColour/python/crosstoolsng/jpeg-install/lib")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/home/dev/x-tools/arm-unknown-linux-gnueabihf/bin/arm-unknown-linux-gnueabihf-strip" "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/tjbench")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "include" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include" TYPE FILE FILES "/home/dev/Desktop/ClaraColour/python/crosstoolsng/libjpeg-turbo-3.1.0/src/turbojpeg.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "bin" OR NOT CMAKE_INSTALL_COMPONENT)
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/rdjpgcom" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/rdjpgcom")
    file(RPATH_CHECK
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/rdjpgcom"
         RPATH "/home/dev/Desktop/ClaraColour/python/crosstoolsng/jpeg-install/lib")
  endif()
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin" TYPE EXECUTABLE FILES "/home/dev/Desktop/ClaraColour/python/crosstoolsng/libjpeg-turbo-3.1.0/build/rdjpgcom")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/rdjpgcom" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/rdjpgcom")
    file(RPATH_CHANGE
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/rdjpgcom"
         OLD_RPATH "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
         NEW_RPATH "/home/dev/Desktop/ClaraColour/python/crosstoolsng/jpeg-install/lib")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/home/dev/x-tools/arm-unknown-linux-gnueabihf/bin/arm-unknown-linux-gnueabihf-strip" "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/rdjpgcom")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "bin" OR NOT CMAKE_INSTALL_COMPONENT)
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/wrjpgcom" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/wrjpgcom")
    file(RPATH_CHECK
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/wrjpgcom"
         RPATH "/home/dev/Desktop/ClaraColour/python/crosstoolsng/jpeg-install/lib")
  endif()
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin" TYPE EXECUTABLE FILES "/home/dev/Desktop/ClaraColour/python/crosstoolsng/libjpeg-turbo-3.1.0/build/wrjpgcom")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/wrjpgcom" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/wrjpgcom")
    file(RPATH_CHANGE
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/wrjpgcom"
         OLD_RPATH "::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::"
         NEW_RPATH "/home/dev/Desktop/ClaraColour/python/crosstoolsng/jpeg-install/lib")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/home/dev/x-tools/arm-unknown-linux-gnueabihf/bin/arm-unknown-linux-gnueabihf-strip" "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/wrjpgcom")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "doc" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/doc/libjpeg-turbo" TYPE FILE FILES
    "/home/dev/Desktop/ClaraColour/python/crosstoolsng/libjpeg-turbo-3.1.0/README.ijg"
    "/home/dev/Desktop/ClaraColour/python/crosstoolsng/libjpeg-turbo-3.1.0/README.md"
    "/home/dev/Desktop/ClaraColour/python/crosstoolsng/libjpeg-turbo-3.1.0/src/example.c"
    "/home/dev/Desktop/ClaraColour/python/crosstoolsng/libjpeg-turbo-3.1.0/src/tjcomp.c"
    "/home/dev/Desktop/ClaraColour/python/crosstoolsng/libjpeg-turbo-3.1.0/src/tjdecomp.c"
    "/home/dev/Desktop/ClaraColour/python/crosstoolsng/libjpeg-turbo-3.1.0/src/tjtran.c"
    "/home/dev/Desktop/ClaraColour/python/crosstoolsng/libjpeg-turbo-3.1.0/doc/libjpeg.txt"
    "/home/dev/Desktop/ClaraColour/python/crosstoolsng/libjpeg-turbo-3.1.0/doc/structure.txt"
    "/home/dev/Desktop/ClaraColour/python/crosstoolsng/libjpeg-turbo-3.1.0/doc/usage.txt"
    "/home/dev/Desktop/ClaraColour/python/crosstoolsng/libjpeg-turbo-3.1.0/doc/wizard.txt"
    "/home/dev/Desktop/ClaraColour/python/crosstoolsng/libjpeg-turbo-3.1.0/LICENSE.md"
    )
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "man" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/man/man1" TYPE FILE FILES
    "/home/dev/Desktop/ClaraColour/python/crosstoolsng/libjpeg-turbo-3.1.0/doc/cjpeg.1"
    "/home/dev/Desktop/ClaraColour/python/crosstoolsng/libjpeg-turbo-3.1.0/doc/djpeg.1"
    "/home/dev/Desktop/ClaraColour/python/crosstoolsng/libjpeg-turbo-3.1.0/doc/jpegtran.1"
    "/home/dev/Desktop/ClaraColour/python/crosstoolsng/libjpeg-turbo-3.1.0/doc/rdjpgcom.1"
    "/home/dev/Desktop/ClaraColour/python/crosstoolsng/libjpeg-turbo-3.1.0/doc/wrjpgcom.1"
    )
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "lib" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/pkgconfig" TYPE FILE FILES "/home/dev/Desktop/ClaraColour/python/crosstoolsng/libjpeg-turbo-3.1.0/build/pkgscripts/libjpeg.pc")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "lib" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/pkgconfig" TYPE FILE FILES "/home/dev/Desktop/ClaraColour/python/crosstoolsng/libjpeg-turbo-3.1.0/build/pkgscripts/libturbojpeg.pc")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "lib" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/cmake/libjpeg-turbo" TYPE FILE FILES
    "/home/dev/Desktop/ClaraColour/python/crosstoolsng/libjpeg-turbo-3.1.0/build/pkgscripts/libjpeg-turboConfig.cmake"
    "/home/dev/Desktop/ClaraColour/python/crosstoolsng/libjpeg-turbo-3.1.0/build/pkgscripts/libjpeg-turboConfigVersion.cmake"
    )
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "lib" OR NOT CMAKE_INSTALL_COMPONENT)
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/cmake/libjpeg-turbo/libjpeg-turboTargets.cmake")
    file(DIFFERENT _cmake_export_file_changed FILES
         "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/cmake/libjpeg-turbo/libjpeg-turboTargets.cmake"
         "/home/dev/Desktop/ClaraColour/python/crosstoolsng/libjpeg-turbo-3.1.0/build/CMakeFiles/Export/f0d506f335508d6549928070f26fb787/libjpeg-turboTargets.cmake")
    if(_cmake_export_file_changed)
      file(GLOB _cmake_old_config_files "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/cmake/libjpeg-turbo/libjpeg-turboTargets-*.cmake")
      if(_cmake_old_config_files)
        string(REPLACE ";" ", " _cmake_old_config_files_text "${_cmake_old_config_files}")
        message(STATUS "Old export file \"$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/cmake/libjpeg-turbo/libjpeg-turboTargets.cmake\" will be replaced.  Removing files [${_cmake_old_config_files_text}].")
        unset(_cmake_old_config_files_text)
        file(REMOVE ${_cmake_old_config_files})
      endif()
      unset(_cmake_old_config_files)
    endif()
    unset(_cmake_export_file_changed)
  endif()
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/cmake/libjpeg-turbo" TYPE FILE FILES "/home/dev/Desktop/ClaraColour/python/crosstoolsng/libjpeg-turbo-3.1.0/build/CMakeFiles/Export/f0d506f335508d6549928070f26fb787/libjpeg-turboTargets.cmake")
  if(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/cmake/libjpeg-turbo" TYPE FILE FILES "/home/dev/Desktop/ClaraColour/python/crosstoolsng/libjpeg-turbo-3.1.0/build/CMakeFiles/Export/f0d506f335508d6549928070f26fb787/libjpeg-turboTargets-release.cmake")
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "include" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include" TYPE FILE FILES
    "/home/dev/Desktop/ClaraColour/python/crosstoolsng/libjpeg-turbo-3.1.0/build/jconfig.h"
    "/home/dev/Desktop/ClaraColour/python/crosstoolsng/libjpeg-turbo-3.1.0/src/jerror.h"
    "/home/dev/Desktop/ClaraColour/python/crosstoolsng/libjpeg-turbo-3.1.0/src/jmorecfg.h"
    "/home/dev/Desktop/ClaraColour/python/crosstoolsng/libjpeg-turbo-3.1.0/src/jpeglib.h"
    )
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
if(CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "/home/dev/Desktop/ClaraColour/python/crosstoolsng/libjpeg-turbo-3.1.0/build/install_local_manifest.txt"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
if(CMAKE_INSTALL_COMPONENT)
  if(CMAKE_INSTALL_COMPONENT MATCHES "^[a-zA-Z0-9_.+-]+$")
    set(CMAKE_INSTALL_MANIFEST "install_manifest_${CMAKE_INSTALL_COMPONENT}.txt")
  else()
    string(MD5 CMAKE_INST_COMP_HASH "${CMAKE_INSTALL_COMPONENT}")
    set(CMAKE_INSTALL_MANIFEST "install_manifest_${CMAKE_INST_COMP_HASH}.txt")
    unset(CMAKE_INST_COMP_HASH)
  endif()
else()
  set(CMAKE_INSTALL_MANIFEST "install_manifest.txt")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "/home/dev/Desktop/ClaraColour/python/crosstoolsng/libjpeg-turbo-3.1.0/build/${CMAKE_INSTALL_MANIFEST}"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
