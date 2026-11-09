# Проба DLSS/DLAA (D-154)

Vulkan-слой вызывает NGX вместо dispatch из `CompositorEffect`. Godot не форкается, плагин этим не пользуется.

## Подготовка

SDK в репозиторий класть нельзя (лицензия NVIDIA), `sdk/` в `.gitignore`. Из [NVIDIA/DLSS](https://github.com/NVIDIA/DLSS), тег `v310.9.16`:

- `include/*.h` → `sdk/include/`;
- `lib/Windows_x86_64/x64/nvsdk_ngx_d.lib` → `sdk/lib/`;
- `lib/Windows_x86_64/rel/nvngx_dlss.dll` → `sdk/`.

Из [Vulkan-Headers](https://github.com/KhronosGroup/Vulkan-Headers) `v1.4.309`: папка `include` → `sdk/vk/include`.

## Запуск

```bash
bash spikes/dlss_probe/build.sh
```

Сравнение режимов в моно:

```bash
bash spikes/dlss_probe/run.sh --j=-1,-1 --m=-1,-1
```

В стерео через `MobileVRInterface`:

```bash
bash spikes/dlss_probe/run.sh --stereo --j=-1,-1 --m=-1,-1
```

`--j` и `--m` — знаки джиттера и векторов движения. `--only-dlaa` — только DLAA, `--rig-jitter` — джиттер поворотом рига, `--speed=X,0` — скорость вращения. Этапы и коды NGX пишутся в `build/layer.log`, снимки — в папку `user://` проекта пробы.
