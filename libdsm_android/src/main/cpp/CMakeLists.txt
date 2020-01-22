cmake_minimum_required(VERSION 3.4.1)
# 设置库名称
project(open_dsm)

# 设置Root目录
get_filename_component(ANDROID_ROOT_DIR ${CMAKE_SOURCE_DIR}/../../../../ ABSOLUTE)

# 设置依赖库路径
get_filename_component(ANDROID_DISTRIBUTION_ANDROID_DIR ${ANDROID_ROOT_DIR}/distribution/android/ ABSOLUTE)

add_subdirectory(${ANDROID_ROOT_DIR}/libdsm_core open_dsm_core)

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
        open_dsm_core
        -landroid
        -llog)