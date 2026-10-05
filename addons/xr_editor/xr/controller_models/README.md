# Controller models

One folder per controller, each with `left.glb`, `right.glb` and the source `profile.json`, taken unchanged from the WebXR Input Profiles assets: npm package `@webxr-input-profiles/assets` 1.0.20, `dist/profiles/<profile id>/` (https://github.com/immersive-web/webxr-input-profiles).

| Folder | Profile id | Controller |
|---|---|---|
| `oculus_touch_v3` | `oculus-touch-v3` | Meta Quest 2 Touch |

The assets are MIT licensed, see `LICENSE.md`. The license does not cover the manufacturers' trademarks the models depict.

The `*.png` / `*.jpg` files and every `*.import` are written by Godot's glTF import: textures are extracted so that they get mipmaps and VRAM compression, set explicitly in their `.import` files.

`XREControllerModel` (`../controller_model.gd`) maps OpenXR interaction profiles to these folders; its class docs say how to add a controller. It also moves the trigger, grip, thumbstick and buttons: `profile.json` names, per control, the node to move and the two nodes that bound its motion (`*_value` between `*_min` and `*_max`).
