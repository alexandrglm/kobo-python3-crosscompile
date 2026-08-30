# Install script for directory: /home/dev/Desktop/ClaraColour/python/crosstoolsng/libjpeg-turbo-3.1.0/sharedlib

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

if(CMAKE_INSTALL_COMPONENT STREQUAL "lib" OR NOT CMAKE_INSTALL_COMPONENT)
  foreach(file
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libjpeg.so.62.4.0"
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libjpeg.so.62"
      )
    if(EXISTS "${file}" AND
       NOT IS_SYMLINK "${file}")
      file(RPATH_CHECK
           FILE "${file}"
           RPATH "/home/dev/Desktop/ClaraColour/python/crosstoolsng/jpeg-install/lib")
    endif()
  endforeach()
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE SHARED_LIBRARY FILES
    "/home/dev/Desktop/ClaraColour/python/crosstoolsng/libjpeg-turbo-3.1.0/build/libjpeg.so.62.4.0"
    "/home/dev/Desktop/ClaraColour/python/crosstoolsng/libjpeg-turbo-3.1.0/build/libjpeg.so.62"
    )
  foreach(file
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libjpeg.so.62.4.0"
      "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/lib/libjpeg.so.62"
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
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib" TYPE SHARED_LIBRARY FILES "/home/dev/Desktop/ClaraColour/python/crosstoolsng/libjpeg-turbo-3.1.0/build/libjpeg.so")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "bin" OR NOT CMAKE_INSTALL_COMPONENT)
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/cjpeg" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/cjpeg")
    file(RPATH_CHECK
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/cjpeg"
         RPATH "/home/dev/Desktop/ClaraColour/python/crosstoolsng/jpeg-install/lib")
  endif()
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin" TYPE EXECUTABLE FILES "/home/dev/Desktop/ClaraColour/python/crosstoolsng/libjpeg-turbo-3.1.0/build/cjpeg")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/cjpeg" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/cjpeg")
    file(RPATH_CHANGE
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/cjpeg"
         OLD_RPATH "/home/dev/Desktop/ClaraColour/python/crosstoolsng/libjpeg-turbo-3.1.0/build:"
         NEW_RPATH "/home/dev/Desktop/ClaraColour/python/crosstoolsng/jpeg-install/lib")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/home/dev/x-tools/arm-unknown-linux-gnueabihf/bin/arm-unknown-linux-gnueabihf-strip" "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/cjpeg")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "bin" OR NOT CMAKE_INSTALL_COMPONENT)
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/djpeg" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/djpeg")
    file(RPATH_CHECK
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/djpeg"
         RPATH "/home/dev/Desktop/ClaraColour/python/crosstoolsng/jpeg-install/lib")
  endif()
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin" TYPE EXECUTABLE FILES "/home/dev/Desktop/ClaraColour/python/crosstoolsng/libjpeg-turbo-3.1.0/build/djpeg")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/djpeg" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/djpeg")
    file(RPATH_CHANGE
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/djpeg"
         OLD_RPATH "/home/dev/Desktop/ClaraColour/python/crosstoolsng/libjpeg-turbo-3.1.0/build:"
         NEW_RPATH "/home/dev/Desktop/ClaraColour/python/crosstoolsng/jpeg-install/lib")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/home/dev/x-tools/arm-unknown-linux-gnueabihf/bin/arm-unknown-linux-gnueabihf-strip" "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/djpeg")
    endif()
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "bin" OR NOT CMAKE_INSTALL_COMPONENT)
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/jpegtran" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/jpegtran")
    file(RPATH_CHECK
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/jpegtran"
         RPATH "/home/dev/Desktop/ClaraColour/python/crosstoolsng/jpeg-install/lib")
  endif()
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/bin" TYPE EXECUTABLE FILES "/home/dev/Desktop/ClaraColour/python/crosstoolsng/libjpeg-turbo-3.1.0/build/jpegtran")
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/jpegtran" AND
     NOT IS_SYMLINK "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/jpegtran")
    file(RPATH_CHANGE
         FILE "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/jpegtran"
         OLD_RPATH "/home/dev/Desktop/ClaraColour/python/crosstoolsng/libjpeg-turbo-3.1.0/build:"
         NEW_RPATH "/home/dev/Desktop/ClaraColour/python/crosstoolsng/jpeg-install/lib")
    if(CMAKE_INSTALL_DO_STRIP)
      execute_process(COMMAND "/home/dev/x-tools/arm-unknown-linux-gnueabihf/bin/arm-unknown-linux-gnueabihf-strip" "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/bin/jpegtran")
    endif()
  endif()
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
if(CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "/home/dev/Desktop/ClaraColour/python/crosstoolsng/libjpeg-turbo-3.1.0/build/sharedlib/install_local_manifest.txt"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
