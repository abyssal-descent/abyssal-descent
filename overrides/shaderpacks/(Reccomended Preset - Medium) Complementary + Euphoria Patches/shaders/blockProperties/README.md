
# Block Properties: Instructions & Guidelines

This directory contains subfolders for different Minecraft versions and other categories. Inside each version folder, you will find the relevant `block.properties` files. Some are split into smaller fragments for easier management.

## Directory Structure

- Each Minecraft version (e.g., `1.7.10`, `1.8+`, `1.13+`) has its own folder.
- Other folders (like `instructions`, `renderlayers`, `tags`) contain additional property files.
- For most versions, there is a single `block.properties` file inside the version folder.
- **For `1.13+`, the block properties are further split into multiple files by block ID range.**
	- The `1.13+` folder also contains an `index.md` file listing the contents and block types covered by each fragment.

## How the System Works

- The main `block.properties` file used in-game is **auto-generated** by the Euphoria Patcher mod when the `autoMergeBlockProperties` option is enabled in its config.
- **Do not edit the generated `block.properties` file directly!** Any manual changes will be overwritten.
- Instead, make all edits in the split files inside the appropriate version folder (e.g., `1.13+/block.10083-10159.properties`).
- When the auto-merge option is enabled, any changes you make here will be automatically merged into the main file for use in-game.

## Adding or Editing Blocks

1. **Navigate to the correct version folder** for the Minecraft version you want to edit or add blocks to.
2. **For `1.13+`**, consult the `index.md` file to find the right fragment file for your block type or ID range.
3. **Add or update block entries** in the appropriate file. Follow the existing formatting and conventions.
4. **Save your changes.**
5. **Enable** the `autoMergeBlockProperties` option in the Euphoria Patcher mod config (found at `config/euphoria_patcher/settings.toml`) if it is not already enabled.
	- **Note:** If you enable this option for the first time, you must restart the game for auto-merge mode to take effect.
6. The mod will automatically merge your changes into the main `block.properties` file for use in-game.

## Tips

- Always edit the split files inside the version folders, never the generated file.
- Double-check block ID ranges and version folders to avoid duplicates or overlaps.
- For `1.13+`, use the `index.md` to help locate the correct file.

---
For more details, see the main project README or contact the maintainer (**SpacEagle17**).
