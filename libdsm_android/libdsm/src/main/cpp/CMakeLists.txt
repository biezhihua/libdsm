cmake_minimum_required(VERSION 3.4.1)
# 设置库名称
project(open_dsm)

get_filename_component(ROOT_DIR ${CMAKE_SOURCE_DIR}/../../../ ABSOLUTE)
get_filename_component(JNI_DIR ${ROOT_DIR}/src/main/jniLibs/ ABSOLUTE)

add_library(lib_dsm STATIC IMPORTED)
set_target_properties(lib_dsm PROPERTIES IMPORTED_LOCATION ${JNI_DIR}/${ANDROID_ABI}/libdsm.a)

add_library(lib_iconv STATIC IMPORTED)
set_target_properties(lib_iconv PROPERTIES IMPORTED_LOCATION ${JNI_DIR}/${ANDROID_ABI}/libiconv.a)

add_library(lib_tasn1 STATIC IMPORTED)
set_target_properties(lib_tasn1 PROPERTIES IMPORTED_LOCATION ${JNI_DIR}/${ANDROID_ABI}/libtasn1.a)

# Creates and names a library, sets it as either STATIC
# or SHARED, and provides the relative paths to its source code.
# You can define multiple libraries, and CMake builds them for you.
# Gradle automatically packages shared libraries with your APK.

add_library( # Sets the name of the library.
        ${PROJECT_NAME}

        # Sets the library as a shared library.
        SHARED

        # Provides a relative path to your source file(s).
        jni-dsm.cpp
        Dsm.cpp
        JniHelp.cpp)

# 链接头文件
target_include_directories(${PROJECT_NAME} PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}
        ${CMAKE_CURRENT_SOURCE_DIR}/dsm
        ${CMAKE_CURRENT_SOURCE_DIR}/json
        )

# Specifies libraries CMake should link to your target library. You
# can link multiple libraries, such as libraries you define in this
# build script, prebuilt third-party libraries, or system libraries.

target_link_libraries(${PROJECT_NAME}
        android
        lib_dsm
        lib_iconv
        lib_tasn1
        log)