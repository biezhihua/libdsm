cmake_minimum_required(VERSION 3.4.1)
# 设置库名称
project(open_dsm)

# 设置Root目录
get_filename_component(ANDROID_ROOT_DIR ${CMAKE_SOURCE_DIR}/../../../../ ABSOLUTE)

# 设置依赖库路径
get_filename_component(ANDROID_DISTRIBUTION_ANDROID_DIR ${ANDROID_ROOT_DIR}/distribution/android/ ABSOLUTE)

#add_library(lib_dsm STATIC IMPORTED)
#set_target_properties(lib_dsm PROPERTIES IMPORTED_LOCATION ${ANDROID_DISTRIBUTION_ANDROID_DIR}/libdsm/${ANDROID_ABI}/libdsm.a)
#
#add_library(lib_iconv STATIC IMPORTED)
#set_target_properties(lib_iconv PROPERTIES IMPORTED_LOCATION ${ANDROID_DISTRIBUTION_ANDROID_DIR}/libdsm/${ANDROID_ABI}/libiconv.a)
#
#add_library(lib_tasn1 STATIC IMPORTED)
#set_target_properties(lib_tasn1 PROPERTIES IMPORTED_LOCATION ${ANDROID_DISTRIBUTION_ANDROID_DIR}/libdsm/${ANDROID_ABI}/libtasn1.a)

add_subdirectory(${ANDROID_ROOT_DIR}/libdsm_core libdsm_core)

# Creates and names a library, sets it as either STATIC
# or SHARED, and provides the relative paths to its source code.
# You can define multiple libraries, and CMake builds them for you.
# Gradle automatically packages shared libraries with your APK.

# 设置头文件
include_directories(
        ${CMAKE_CURRENT_SOURCE_DIR}

        ${ANDROID_DISTRIBUTION_ANDROID_DIR}/libdsm/include
)


add_library( # Sets the name of the library.
        ${PROJECT_NAME}

        # Sets the library as a shared library.
        SHARED

        # Provides a relative path to your source file(s).
        jni-dsm.cpp
        JniHelp.cpp)

# 链接头文件
target_include_directories(${PROJECT_NAME} PRIVATE

        ${ANDROID_DISTRIBUTION_ANDROID_DIR}/libdsm/include

        ${ANDROID_ROOT_DIR}/libdsm_core

        ${CMAKE_CURRENT_SOURCE_DIR}
        )

# Specifies libraries CMake should link to your target library. You
# can link multiple libraries, such as libraries you define in this
# build script, prebuilt third-party libraries, or system libraries.

target_link_libraries(${PROJECT_NAME}
        android
        libdsm_core
        -landroid
        -llog)