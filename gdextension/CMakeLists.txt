# Native part of the XR Editor plugin. Built by scripts/build_gdextension.sh;
# the library lands in addons/xr_editor/bin/, next to xr_editor.gdextension.
cmake_minimum_required(VERSION 3.25)
project(xre_native LANGUAGES CXX)

# API of Godot 4.7, bundled with godot-cpp 10.0.0. Identical to the dump from
# the 4.7.2 binary except for the version header (checked 2026-10-05).
set(GODOTCPP_API_VERSION "4.7" CACHE STRING "Godot API version to bind against")
set(GODOTCPP_TARGET "template_debug" CACHE STRING "godot-cpp build target")
add_subdirectory(godot-cpp SYSTEM)

add_library(xre_native SHARED
	src/register_types.cpp
	src/editor_controllers.cpp
	src/editor_controllers.h
	src/editor_frame_loop.cpp
	src/editor_frame_loop.h
	src/frame_timer.cpp
	src/frame_timer.h
	src/picker.cpp
	src/picker.h
)
# Same OpenXR headers as Godot 4.7.2 (thirdparty/openxr, OpenXR SDK 1.1.54).
# No loader is linked: every entry point comes from Godot's instance.
target_include_directories(xre_native PRIVATE thirdparty/openxr/include)
target_compile_definitions(xre_native PRIVATE XR_NO_PROTOTYPES)
target_compile_options(xre_native PRIVATE
	$<$<CXX_COMPILER_ID:MSVC>:/W4 /permissive->
	# Android (clang from the NDK): the same bar as /W4. OpenXR structs are
	# initialized the SDK's way, `XrFoo foo = { XR_TYPE_FOO };`, which zeroes the
	# other fields; -Wextra would flag every one of them.
	$<$<CXX_COMPILER_ID:Clang>:-Wall -Wextra -Wno-missing-field-initializers>
)
target_link_libraries(xre_native PRIVATE godot-cpp)

get_target_property(GODOTCPP_SUFFIX godot-cpp GODOTCPP_SUFFIX)
set(XRE_BIN_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../addons/xr_editor/bin")
set_target_properties(xre_native PROPERTIES
	CXX_STANDARD 17
	CXX_EXTENSIONS OFF
	PREFIX ""
	OUTPUT_NAME "xre_native${GODOTCPP_SUFFIX}"
	# A generator expression keeps multi-config generators from adding a Debug/ subfolder.
	RUNTIME_OUTPUT_DIRECTORY "$<1:${XRE_BIN_DIR}>"
	LIBRARY_OUTPUT_DIRECTORY "$<1:${XRE_BIN_DIR}>"
	PDB_OUTPUT_DIRECTORY "$<1:${XRE_BIN_DIR}>"
)
