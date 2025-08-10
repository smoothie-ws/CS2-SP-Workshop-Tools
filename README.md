# CS2 Workshop Tools for Substance 3D Painter

![cs2sp_logo](https://github.com/user-attachments/assets/7df2705d-59c6-4dbd-b700-7c1aa8fcd2ed)

# **[Overview](#overview)** • **[Getting Started](#getting-started)** • **[Guide](#guide)**

# Table of Contents
-   **[Overview](#overview)**
    -   [Disclaimer](#disclaimer)
    -   [How It Works](#how-it-works)
-   **[Getting Started](#getting-started)**
    -   [Installation](#installation)
    -   [Launching](#launching)
    -   [Next Steps](#next-steps)
        -   [Plugin Settings](#plugin-settings)
        -   [Base Weapon Textures](#base-weapon-textures)
            -   [Option 1: Decompilation](#option-1-decompilation)
            -   [Option 2: Manual Provision](#option-2-manual-provision)
-   **[Guide](#guide)**
    -   [Creating a Weapon Finish Project](#creating-a-weapon-finish-project)
        -   [Option 1: New Project](#option-1-new-project)
        -   [Option 2: From Existing Project](#option-2-from-existing-project)
    -   [Weapon Finish Workflow](#weapon-finish-workflow)
        -   [Live Previewing](#live-previewing)
            -   [PBR Validation](#pbr-validation)
            -   [Weapon Model](#weapon-model)
            -   [Finish Style](#finish-style)
        -   [Publishing](#publishing)
            -   [Econitem Synchronization](#econitem-synchronization)
            -   [Texture Exporting](#texture-exporting)

# Overview

## Disclaimer

This project is an **unofficial fan-made tool** for creating **[Counter-Strike 2 Weapon Finishes](https://www.counter-strike.net/workshop/workshopfinishes)** with **[Adobe Substance 3D Painter](https://www.adobe.com/products/substance3d/apps/painter.html)**. It is not affiliated with **[Valve](https://www.valvesoftware.com/)**, **[Counter-Strike 2](https://www.counter-strike.net/cs2)**, **[Adobe](https://www.adobe.com/)**, or **[Substance 3D Painter](https://www.adobe.com/products/substance3d/apps/painter.html).**

This plugin is currently under active development. There may be bugs or issues.  
If you encounter any, please [report them](https://github.com/smoothie-ws/CS2-SP-Workshop-Tools/issues).

## How It Works

The **CS2 Workshop Tools** are distributed as a plugin for [Adobe Substance 3D Painter](https://www.adobe.com/products/substance3d/apps/painter.html).

It manages projects, resources, and handles texture exporting via the [Substance 3D Painter Python API](https://helpx.adobe.com/substance-3d-painter-python.html).

It also provides 9 [GLSL](https://helpx.adobe.com/substance-3d-painter/scripting-and-development/api-reference/shader-api.html) shaders corresponding to each of the Weapon Finish styles:

-   [Solid Color](https://www.counter-strike.net/workshop/workshopfinishes#solidcolorstyle)
-   [Hydrographic](https://www.counter-strike.net/workshop/workshopfinishes#hydrographic)
-   [Spray-Paint](https://www.counter-strike.net/workshop/workshopfinishes#spraypaint)
-   [Anodized](https://www.counter-strike.net/workshop/workshopfinishes#anodized)
-   [Anodized Multicolored](https://www.counter-strike.net/workshop/workshopfinishes#anodizedmulticolored)
-   [Anodized Airbrushed](https://www.counter-strike.net/workshop/workshopfinishes#anodizedairbrushed)
-   [Custom Paint Job](https://www.counter-strike.net/workshop/workshopfinishes#custompaint)
-   [Patina](https://www.counter-strike.net/workshop/workshopfinishes#patina)
-   [Gunsmith](https://www.counter-strike.net/workshop/workshopfinishes#gunsmith)

![image](https://github.com/user-attachments/assets/f25275d3-6d65-40ac-91c1-9b3d47fc3eaa)

These shaders are used to preview Weapon Finish settings live inside Substance Painter.

Base weapon texture decompilation has been released using the [Valve Resource Format](https://github.com/ValveResourceFormat/ValveResourceFormat) (VRF) CLI tool.

# Getting Started

## Installation

1. **Make sure you have Substance 3D Painter installed on your PC.**<br />

    > **Note:** Supported Substance 3D Painter versions are `9.1.1 - 11.0.2`. **Earlier versions may be unstable!**

2. **[Download the plugin](https://github.com/smoothie-ws/CS2-SP-Workshop-Tools/releases/latest)**

3. **Unpack the plugin:**

    - Place the plugin in the folder used by Substance 3D Painter to load Python plugins.

        > **Example** (Windows): `C:/Users/<user>/Documents/Adobe/Adobe Substance 3D Painter/python/plugins`

    - You can find this folder via the Python menu in Substance 3D Painter by selecting "Plugins Folder":

        ![image](https://github.com/user-attachments/assets/ec17bc3b-a734-4f29-aec2-6cf40fa55695)

    - Unpack the plugin so the path becomes: `.../python/plugins/CS2 Workshop Tools`

## Launching

1. After installing the plugin, go to the Python menu. You should see the **CS2 Workshop Tools** button:

    ![image](https://github.com/user-attachments/assets/3f6c96d1-c466-4403-b0c1-ed1a7b78de22)

2. Click it to launch:

    ![image](https://github.com/user-attachments/assets/c5396637-edfd-4b0d-844b-feff133464cd)

## Next Steps

### Plugin Settings

Plugin settings are available in the **CS2 Workshop Tools** menu:

![Plugin Settings in menu](https://imgur.com/mUx2YQA.png)

Here you can configure the CS2 path, list of available weapons, default weapon finish settings, and more:

![Plugin Settings](https://i.imgur.com/8uRCPDM.png)

### Base Weapon Textures

The plugin shaders require a set of base weapon textures to calculate paint wear, dirt, and other surface effects.

**These textures are not bundled with the plugin.**

If you have CS2 installed, the plugin can automatically decompile and extract them. Otherwise, you need to provide them manually.

In the plugin settings, you'll see a warning icon next to any weapon missing textures:

![Weapon warning icons](https://imgur.com/ZYz3AyH.png)

This means required textures could not be found.

#### Option 1: Decompilation

To automatically extract base textures:

1. Set the CS2 path:

![CS2 Path](https://imgur.com/kB7NCnL.png)

2. Click the **Decompile** button:

![Decompile button](https://imgur.com/g10GhyR.png)

This will begin the decompilation process:

![Decompilation](https://imgur.com/DPF74Ak.png)

> **Note:** This may take several minutes. Do not close the plugin during this process.

#### Option 2: Manual Provision

To manually provide the textures:

1. Place them in the `.../CS2 Workshop Tools/assets/textures/models/...` directory.  
> **Important:** Filenames must follow the format  
> `<weapon id>/<weapon id>_[cavity|color|masks|rough|surface].png`  
> e.g. `ak47/ak47_cavity.png`, `taser/taser_surface.png`, etc.

2. Click **Refresh** to reload and validate textures:

![Refresh](https://imgur.com/9WlFs38.png)

# Guide

This section covers the main features of the plugin and how to work with **Weapon Finish Projects** (i.e., Substance Painter projects adapted for CS2 weapon finishes).

The plugin interface is a dockable widget located in the right tab bar:

![Plugin icon](https://imgur.com/4BsseJX.png)

You can move and dock it wherever you prefer:

![Docked](https://imgur.com/1IFwEU5.png)

## Creating a Weapon Finish Project

Weapon Finish Projects require a texture set with 5 channels:

- Base Color (Albedo)
- Roughness
- Material Masks
- Alpha
- Pearlescence

...and one of the 9 provided shaders.

No manual setup is necessary — the plugin handles everything.

### Option 1: New Project

To create a brand-new Weapon Finish project:

1. Go to the plugin widget and click **New Weapon Finish**:

![New Weapon Finish button](https://imgur.com/JOPpVCq.png)

2. Fill in the required fields and click **Create**:

![New Weapon Finish window](https://imgur.com/5sFznDp.png)

3. Wait for the project setup to complete.

### Option 2: From Existing Project

You can also set up an existing Substance Painter project:

1. Open the project in Substance 3D Painter.

2. Go to the plugin tools and click **Set up as Weapon Finish**:

![Set up Weapon Finish button](https://imgur.com/Qvtf3xl.png)

3. Complete the form and click **Proceed**:

![Set up Weapon Finish window](https://imgur.com/Rah6Iax.png)

4. Wait for the process to finish.

## Weapon Finish Workflow

![workflow](https://github.com/user-attachments/assets/408e9dcb-17bb-4c1f-98af-bd6ae86968b4)

### Live Previewing

You can preview Weapon Finishes with live settings by clicking **Live Preview** or pressing **G** on your keyboard.

Most of the settings mimic the official [CS2 Workshop Tools](https://developer.valvesoftware.com/wiki/Counter-Strike_2_Workshop_Tools/Weapon_Finishes), so they won't be explained in detail here.

![Live Preview button](https://imgur.com/Y5vPdWZ.png)

#### PBR Validation

According to the [official guide](https://www.counter-strike.net/workshop/workshopfinishes#pbr), Weapon Finishes should use values within the effective PBR range:

- **Metallic**: 180–250  
- **Non-metallic**: 55–220

Enable validation by clicking **PBR Validation** or pressing **V**. This feature works **only in Live Preview mode**.

![PBR Validation button](https://imgur.com/9jQC0X3.png)

Colors indicate the range status:
- 🟥 Red — above valid range
- 🟦 Blue — below valid range

#### Weapon Model

The selected weapon determines which base textures are required.

> **Note:** Switching weapons triggers a re-import of textures, which can take time. Avoid changing frequently.

![Weapon model](https://imgur.com/aTH8LqC.png)

You can only work with weapons that have base textures. Otherwise, **Live Preview** will be disabled:

![Base textures missing](https://imgur.com/HnWioSa.png)

#### Finish Style

Each Weapon Finish style has its own shader and parameters. Switching styles requires changing the shader, which may take time.

![Finish styles](https://imgur.com/vQddoyi.png)

### Publishing

The plugin provides tools to make publishing easier and reduce repetitive tasks like copying files or paths.

> **Note:** CS2 must be installed to use publishing tools.

#### Econitem Synchronization

You can sync your Weapon Finish with its `.econitem` file:

- **Import** (`.econitem` → Weapon Finish): Automatic on open and manual via **Import** button.
- **Export** (Weapon Finish → `.econitem`): Automatic on save.

![Econitem](https://imgur.com/qgfqhjM.png)

> **Important:** The official CS2 Workshop Tools **block** and **overwrite** `.econitem` files. Be sure to **close it** before exporting to avoid conflicts.

#### Texture Exporting

Use the **Export Textures** button to export maps using the preset format compatible with CS2 Workshop Tools.

![Textures folder](https://imgur.com/SK2ULne.png)

Enjoy!
