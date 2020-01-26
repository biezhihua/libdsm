
# 设置cmake最低版本
cmake_minimum_required(VERSION 3.4.1)

# 设置库名称
project(open_dsm_core)

# 指定C++版本
set(CMAKE_CXX_STANDARD 11)

# 设置根目录
get_filename_component(CORE_ROOT_DIR ${CMAKE_CURRENT_SOURCE_DIR}/../ ABSOLUTE)

if (${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
    set(CORE_DISTRIBUTION_DIR ${CORE_ROOT_DIR}/distribution/macos)
elseif (${CMAKE_SYSTEM_NAME} MATCHES "Windows")
    set(CORE_DISTRIBUTION_DIR ${CORE_ROOT_DIR}/distribution/windows)
elseif (${CMAKE_SYSTEM_NAME} MATCHES "Linux")
    set(CORE_DISTRIBUTION_DIR ${CORE_ROOT_DIR}/distribution/linux)
elseif (${CMAKE_SYSTEM_NAME} MATCHES "Android")
    set(CORE_DISTRIBUTION_DIR ${CORE_ROOT_DIR}/distribution/android)
elseif (${CMAKE_SYSTEM_NAME} MATCHES "iOS")
    set(CORE_DISTRIBUTION_DIR ${CORE_ROOT_DIR}/distribution/ios)
endif ()

# 打印消息
message("LOG ENGINE CORE_ROOT_DIR = ${CORE_ROOT_DIR}")
message("LOG ENGINE CORE_DISTRIBUTION_DIR = ${CORE_DISTRIBUTION_DIR}")
message("LOG ENGINE CMAKE_SYSTEM_NAME = ${CMAKE_SYSTEM_NAME}")

# 设置子文件夹源码依赖
# https://discourse.urho3d.io/t/how-do-you-include-source-in-subdirectories/871

# 添加源码子目录
file(GLOB CPP_FILES
        *.cpp
        )

# 添加头文件子目录
file(GLOB H_FILES
        nlohmann/*.h
        *.h
        )

# 设置源文件集合
set(SOURCE_FILES ${CPP_FILES})

# 设置库
add_library(${PROJECT_NAME} SHARED ${SOURCE_FILES})

# 链接头文件
target_include_directories(${PROJECT_NAME} PRIVATE

        # 引入 libdsm 头文件
        ${CORE_DISTRIBUTION_DIR}/libdsm/include

        # 引入自有代码头文件
        ${CMAKE_CURRENT_SOURCE_DIR}

        )

# 链接子模块
target_link_libraries(${PROJECT_NAME})

# 链接 libdsm 模块
if (${CMAKE_SYSTEM_NAME} MATCHES "Darwin")
elseif (${CMAKE_SYSTEM_NAME} MATCHES "Windows")
elseif (${CMAKE_SYSTEM_NAME} MATCHES "Linux")
elseif (${CMAKE_SYSTEM_NAME} MATCHES "Android")

    add_library(lib_dsm STATIC IMPORTED)
    set_target_properties(lib_dsm PROPERTIES IMPORTED_LOCATION ${CORE_DISTRIBUTION_DIR}/libdsm/lib/${ANDROID_ABI}/libdsm.a)

    add_library(lib_iconv STATIC IMPORTED)
    set_target_properties(lib_iconv PROPERTIES IMPORTED_LOCATION ${CORE_DISTRIBUTION_DIR}/libdsm/lib/${ANDROID_ABI}/libiconv.a)

    add_library(lib_tasn1 STATIC IMPORTED)
    set_target_properties(lib_tasn1 PROPERTIES IMPORTED_LOCATION ${CORE_DISTRIBUTION_DIR}/libdsm/lib/${ANDROID_ABI}/libtasn1.a)

    add_library(lib_charset STATIC IMPORTED)
    set_target_properties(lib_charset PROPERTIES IMPORTED_LOCATION ${CORE_DISTRIBUTION_DIR}/libdsm/lib/${ANDROID_ABI}/libcharset.a)

    target_link_libraries(${PROJECT_NAME}
            lib_dsm
            lib_iconv
            lib_tasn1
            lib_charset
            -landroid
            -llog
            )
elseif (${CMAKE_SYSTEM_NAME} MATCHES "iOS")
endif ()