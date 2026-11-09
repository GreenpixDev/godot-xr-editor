# The spike's Vulkan layer (D-154). Not part of the plugin's build.
cmake_minimum_required(VERSION 3.25)
project(xre_dlss_layer LANGUAGES CXX)

set(SDK "${CMAKE_CURRENT_SOURCE_DIR}/../sdk")
add_library(xre_dlss_layer SHARED xre_dlss_layer.cpp)
target_include_directories(xre_dlss_layer PRIVATE "${SDK}/include" "${SDK}/vk/include")
target_compile_definitions(xre_dlss_layer PRIVATE _CRT_SECURE_NO_WARNINGS NOMINMAX)
set_target_properties(xre_dlss_layer PROPERTIES CXX_STANDARD 17 CXX_EXTENSIONS OFF MSVC_RUNTIME_LIBRARY "MultiThreadedDLL")
# The _d library is the one for the dynamic CRT.
target_link_libraries(xre_dlss_layer PRIVATE "${SDK}/lib/nvsdk_ngx_d.lib")
