# A56 To Flagship

This module brings S25FE features to the Galaxy A56.

## Highlights

### Galaxy AI

- Call Assist
- Writing Assist
- Interpreter
- Note Assist
- Transcript Assist
- Browsing Assist
- Photo Assist
- Creative Studio
- Weather Wallpaper
- Now Brief
- Health Assist

### Other

- Live Blur works.
- The launcher has flagship animations.
- The quick center icons have animations.
- S25FE wallpapers are added.

### Camera

- 4K60 recording on the rear and front cameras.
- RAW is working with LEVEL_3 enabled (patched with [Camera-Patcher](https://github.com/TBM13/Camera-Patcher)).

## Requirements

- KernelSU with [Magic Mount-rs](https://github.com/Tools-cx-app/meta-magic_mount-rs/releases/latest) is mandatory.

## Recommendation

- Consider using [BackDownload](https://github.com/ducthoe/BackDownload) to keep Download mode available with a screen lock enabled. Requires root and Zygisk.

## Install

1. Install [Magic Mount-rs](https://github.com/Tools-cx-app/meta-magic_mount-rs/releases/latest) through KernelSU Manager, then soft reboot to activate it. Skip this step if it is already installed and active.
2. Open **Modules** in KernelSU Manager and install `A56-To-Flagship-2.0.1.zip`.
3. Wait for installation to finish successfully, then perform another **soft reboot**.
4. Unlock the phone and let the Samsung apps finish loading. Open Galaxy Store to download any additional AI components or language packs you need.

For temporary or late-loaded root, use your root setup's soft-reboot workflow so KernelSU and the module are reloaded. The reboot also refreshes the SM-S731B model spoof used for Galaxy Store compatibility checks.

If you are switching from an OverlayFS build, finish uninstalling the old module and metamodule first, then restart before following these steps. Use one metamodule at a time.

## Uninstall

**Run the uninstaller while the module and KernelSU are still installed.** It resets the settings and private data of the Samsung apps replaced by the port, removes the added AI apps, and clears their cached APK metadata so the stock apps can load correctly after reboot. No backups are created. Gallery photos and launcher layout are not reset.

1. Open **Modules** in KernelSU Manager, find **A56 To Flagship**, and tap **Action**.
2. Read the prompt and press the physical **Volume Down** button once to confirm. **Volume Up** or waiting 30 seconds cancels without uninstalling anything.
3. Wait until you see **Stock restore prepared. This module is marked for removal.** The uninstaller has completed cleanup and marked the module for removal automatically.
4. Reboot to finish returning to stock. If you also want to remove KernelSU, you can do that after the success message and before this reboot. Nothing needs to run with root afterward.

If cleanup reports an error, keep KernelSU installed, resolve the reported problem, and run **Action** again. Use the Action before deleting the module or removing root; deleting it first skips the app cleanup.
