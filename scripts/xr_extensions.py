#!/usr/bin/env python3
"""List the instance extensions of an OpenXR runtime, without a headset or Godot.

Loads the runtime library named in a runtime manifest, negotiates the
loader-runtime interface the way the OpenXR loader does and calls
xrEnumerateInstanceExtensionProperties without an instance. The list is what
any application, Godot included, can enable on this runtime (docs/decisions.md,
D-010). Windows only, standard library only.

The manifest (omitted or "") defaults to XR_RUNTIME_JSON, then to the active runtime in the
registry (HKLM\\SOFTWARE\\Khronos\\OpenXR\\1\\ActiveRuntime). An optional filter
keeps the extensions whose name contains it, case-insensitive.

Usage: py scripts/xr_extensions.py [runtime manifest.json] [filter]
  e.g. py scripts/xr_extensions.py "C:/Program Files (x86)/Steam/steamapps/common/SteamVR/steamxr_win64.json" model
"""

from __future__ import annotations

import ctypes
import json
import os
import sys
import winreg
from ctypes import POINTER, byref, c_char, c_char_p, c_int32, c_size_t, c_uint32, c_uint64, c_void_p
from typing import Any, NamedTuple

XR_LOADER_INTERFACE_STRUCT_LOADER_INFO = 1
XR_LOADER_INTERFACE_STRUCT_RUNTIME_REQUEST = 3
XR_TYPE_EXTENSION_PROPERTIES = 2


def xr_make_version(major: int, minor: int, patch: int) -> int:
    return ((major & 0xFFFF) << 48) | ((minor & 0xFFFF) << 32) | (patch & 0xFFFFFFFF)


def xr_version_string(version: int) -> str:
    return f"{version >> 48}.{(version >> 32) & 0xFFFF}.{version & 0xFFFFFFFF}"


class NegotiateLoaderInfo(ctypes.Structure):
    _fields_ = [
        ("structType", c_int32),
        ("structVersion", c_uint32),
        ("structSize", c_size_t),
        ("minInterfaceVersion", c_uint32),
        ("maxInterfaceVersion", c_uint32),
        ("minApiVersion", c_uint64),
        ("maxApiVersion", c_uint64),
    ]


class NegotiateRuntimeRequest(ctypes.Structure):
    _fields_ = [
        ("structType", c_int32),
        ("structVersion", c_uint32),
        ("structSize", c_size_t),
        ("runtimeInterfaceVersion", c_uint32),
        ("runtimeApiVersion", c_uint64),
        ("getInstanceProcAddr", c_void_p),
    ]


class ExtensionProperties(ctypes.Structure):
    _fields_ = [
        ("type", c_int32),
        ("next", c_void_p),
        ("extensionName", c_char * 128),
        ("extensionVersion", c_uint32),
    ]


PFN_GetInstanceProcAddr = ctypes.CFUNCTYPE(c_int32, c_uint64, c_char_p, POINTER(c_void_p))
PFN_EnumerateInstanceExtensionProperties = ctypes.CFUNCTYPE(
    c_int32, c_char_p, c_uint32, POINTER(c_uint32), POINTER(ExtensionProperties))


def default_manifest() -> str:
    if os.environ.get("XR_RUNTIME_JSON"):
        return os.environ["XR_RUNTIME_JSON"]
    with winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, r"SOFTWARE\Khronos\OpenXR\1") as key:
        return winreg.QueryValueEx(key, "ActiveRuntime")[0]


class Runtime(NamedTuple):
    name: str
    library: str
    api_version: int
    get_instance_proc_addr: Any  # PFN_GetInstanceProcAddr


def load_runtime(manifest_path: str) -> Runtime:
    """Loads the runtime library named in a manifest and negotiates the
    loader-runtime interface with it, as the OpenXR loader does. Raises
    RuntimeError if the runtime refuses."""
    with open(manifest_path, encoding="utf-8") as f:
        runtime = json.load(f)["runtime"]
    library = os.path.normpath(os.path.join(os.path.dirname(manifest_path), runtime["library_path"]))
    os.add_dll_directory(os.path.dirname(library))
    dll = ctypes.WinDLL(library)

    loader_info = NegotiateLoaderInfo(
        XR_LOADER_INTERFACE_STRUCT_LOADER_INFO, 1, ctypes.sizeof(NegotiateLoaderInfo),
        1, 1, xr_make_version(1, 0, 0), xr_make_version(1, 0x3FF, 0xFFF))
    request = NegotiateRuntimeRequest(
        XR_LOADER_INTERFACE_STRUCT_RUNTIME_REQUEST, 1, ctypes.sizeof(NegotiateRuntimeRequest), 0, 0, None)
    negotiate_name = runtime.get("functions", {}).get("xrNegotiateLoaderRuntimeInterface", "xrNegotiateLoaderRuntimeInterface")
    negotiate = getattr(dll, negotiate_name)
    negotiate.restype = c_int32
    result = negotiate(byref(loader_info), byref(request))
    if result != 0:
        raise RuntimeError(f"xrNegotiateLoaderRuntimeInterface failed: {result}")
    return Runtime(runtime.get("name", "?"), library, request.runtimeApiVersion,
                   PFN_GetInstanceProcAddr(request.getInstanceProcAddr))


def main() -> int:
    manifest_path = os.path.abspath(sys.argv[1] if len(sys.argv) > 1 and sys.argv[1] else default_manifest())
    name_filter = sys.argv[2].lower() if len(sys.argv) > 2 else ""
    try:
        runtime = load_runtime(manifest_path)
    except RuntimeError as error:
        print(error)
        return 1
    print(f"runtime: {runtime.name} ({runtime.library})")
    print(f"OpenXR API version: {xr_version_string(runtime.api_version)}")

    get_proc = runtime.get_instance_proc_addr
    function = c_void_p()
    result = get_proc(0, b"xrEnumerateInstanceExtensionProperties", byref(function))
    if result != 0:
        print(f"xrGetInstanceProcAddr failed: {result}")
        return 1
    enumerate_extensions = PFN_EnumerateInstanceExtensionProperties(function.value)

    count = c_uint32(0)
    result = enumerate_extensions(None, 0, byref(count), None)
    if result != 0:
        print(f"xrEnumerateInstanceExtensionProperties failed: {result}")
        return 1
    properties = (ExtensionProperties * count.value)()
    for p in properties:
        p.type = XR_TYPE_EXTENSION_PROPERTIES
    result = enumerate_extensions(None, count.value, byref(count), properties)
    if result != 0:
        print(f"xrEnumerateInstanceExtensionProperties failed: {result}")
        return 1

    extensions = sorted((p.extensionName.decode(), p.extensionVersion) for p in properties)
    shown = [(name, version) for name, version in extensions if name_filter in name.lower()]
    print(f"extensions: {len(extensions)}" + (f", {len(shown)} matching '{name_filter}'" if name_filter else ""))
    for name, version in shown:
        print(f"  {name} v{version}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
