#include "editor_controllers.h"
#include "editor_frame_loop.h"
#include "frame_timer.h"
#include "picker.h"
#include "graph_wire.h"
#include "graph_wire_picker.h"
#include "graph_arrows.h"
#include "mesh_merger.h"
#include "text_merger.h"

#include <gdextension_interface.h>
#include <godot_cpp/classes/engine.hpp>
#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/core/memory.hpp>
#include <godot_cpp/godot.hpp>
#include <godot_cpp/variant/utility_functions.hpp>

using namespace godot;

namespace {

/// True while the editor itself is starting up. The wrappers are registered in
/// every editor, not only with --xr-mode on: that flag can't be read here
/// (OS.get_cmdline_args() omits the arguments Godot consumed), and without it
/// the editor creates no OpenXR session, so they are never called, only
/// deleted on shutdown. A running game uses the project's own action map.
bool is_editor_startup() {
	if (!Engine::get_singleton()->is_editor_hint()) {
		return false;
	}
	// The editor loads a newly found extension while running, after the OpenXR
	// instance exists, and wrappers can then no longer be registered.
	if (Engine::get_singleton()->get_main_loop() != nullptr) {
		UtilityFunctions::print("XR Editor: native library loaded while the editor was running; restart the editor to use it in VR.");
		return false;
	}
	return true;
}

void initialize_xre_native(ModuleInitializationLevel p_level) {
	if (p_level == MODULE_INITIALIZATION_LEVEL_SCENE) {
		GDREGISTER_CLASS(xre::XREPicker);
		GDREGISTER_CLASS(xre::XREGraphWire);
		GDREGISTER_CLASS(xre::XREGraphWirePicker);
		GDREGISTER_CLASS(xre::XREGraphArrows);
		GDREGISTER_CLASS(xre::XREMeshMerger);
		GDREGISTER_CLASS(xre::XRETextMerger);
		return;
	}
	// OpenXR creates its instance at the servers level and refuses wrappers
	// registered after that, so this has to happen at the core level.
	if (p_level != MODULE_INITIALIZATION_LEVEL_CORE) {
		return;
	}
	GDREGISTER_INTERNAL_CLASS(xre::XREEditorControllers);
	GDREGISTER_INTERNAL_CLASS(xre::XREEditorFrameLoop);
	GDREGISTER_ABSTRACT_CLASS(xre::XREFrameTimer);
	GDREGISTER_ABSTRACT_CLASS(xre::XREEditorHaptics);
	if (is_editor_startup()) {
		// From here the OpenXR module owns the wrappers and deletes them on
		// shutdown (OpenXRAPI::cleanup_extension_wrappers), so they are never freed here.
		memnew(xre::XREEditorFrameLoop)->register_extension_wrapper();
		memnew(xre::XREEditorControllers)->register_extension_wrapper();
	}
}

void uninitialize_xre_native(ModuleInitializationLevel) {
}

} // namespace

extern "C" {

GDExtensionBool GDE_EXPORT xre_native_init(GDExtensionInterfaceGetProcAddress p_get_proc_address, GDExtensionClassLibraryPtr p_library, GDExtensionInitialization *r_initialization) {
	GDExtensionBinding::InitObject init_obj(p_get_proc_address, p_library, r_initialization);
	init_obj.register_initializer(initialize_xre_native);
	init_obj.register_terminator(uninitialize_xre_native);
	init_obj.set_minimum_library_initialization_level(MODULE_INITIALIZATION_LEVEL_CORE);
	return init_obj.init();
}

} // extern "C"
