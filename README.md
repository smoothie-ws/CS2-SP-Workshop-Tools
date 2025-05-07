# CS2 Workshop Tools for Substance 3D Painter

![cs2sp_logo](https://github.com/user-attachments/assets/edda828a-586c-4fa3-b0c8-c453bde0e0e1)

# **[Overview](#overview)** • **[Getting started](#getting-started)** • **[Guide](#guide)**

# Disclaimer

This project is an **unofficial fan-made tool** for creating **[Counter-Strike 2 Weapon Finishes](https://www.counter-strike.net/workshop/workshopfinishes)** with **[Adobe Substance 3D Painter](https://www.adobe.com/products/substance3d/apps/painter.html)** and in no way affiliated with **[Valve](https://www.valvesoftware.com/)**, **[Counter-Strike 2](https://www.counter-strike.net/cs2)**, **[Adobe](https://www.adobe.com/)** or **[Substance 3D Painter](https://www.adobe.com/products/substance3d/apps/painter.html).**

Since it is currently under active development, there may be some bugs or mistakes.
If you encounter any, please [report them](https://github.com/smoothie-ws/CS2-SP-Workshop-Tools/issues).

# Table of Contents
-   **[Overview](#overview)**
    -   [How it works](#how-it-works)
-   **[Getting started](#getting-started)**
    -   [Installation](#installation)
    -   [Launching](#launching)
    -   [Next steps](#how-it-works)
        -   [Plugin settings](#plugin-settings)
        -   [Base weapon textures](#base-weapon-textures)
-   **[Guide](#guide)**
    -   [Creating Weapon Finish](#creating-weapon-finish)
        -   [New Project](#new-project)
        -   [From existing Project](#from-existing-project)
    -   [Weapon Finish Workflow](#weapon-finish-workflow)

# Overview

## How it works

The **Substance 3D Painter CS2 Worskhop Tools** are distributed as a plugin for [Adobe Substance 3D Painter](https://www.adobe.com/products/substance3d/apps/painter.html).

It manages projects, resources and handles texture exporting via the [Substance 3D Painter Python API](https://helpx.adobe.com/substance-3d-painter-python.html).

It also provides 9 `GLSL` shaders for each of the Weapon Finish Styles, which are:

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

These shaders are used for live previewing the Weapon Finish settings.

# Getting started

## Installation

1. **First you need Substance 3D Painter installed on your PC.**<br />

    > **Please note:** `Substance 3D Painter 8.3.0` and earlier versions are not supported.

2. **[Download](https://github.com/smoothie-ws/CS2-SP-Workshop-Tools/releases) the plugin**

3. **Unpack the plugin:**

    - The plugin should be located in the folder from which `Substance 3D Painter` loads Python plugins.

        > **Example**: `C:\Users\<user>\Documents\Adobe\Adobe Substance 3D Painter\python\plugins`

    - You can get the `python` folder path through the `Python` menu of `Substance 3D Painter` with the `Plugins Folder` option:

        ![image](https://github.com/user-attachments/assets/ec17bc3b-a734-4f29-aec2-6cf40fa55695)

    - Unpack the plugin into the `plugins` folder so that the path to the plugin is `.../python/plugins/CS2 Workshop Tools`

## Launching

1. Once you have installed the plugin, navigate to the `Python` menu. There should be a `CS2 Workshop Tools` button:

    ![image](https://github.com/user-attachments/assets/3f6c96d1-c466-4403-b0c1-ed1a7b78de22)

1. To launch the plugin, just click it:

    ![image](https://github.com/user-attachments/assets/c5396637-edfd-4b0d-844b-feff133464cd)

## Next steps

### Plugin settings

Plugin Settins are available at the `CS2 Workshop Tools` menu:

![image](https://github.com/user-attachments/assets/4bb34f8c-f739-48e2-af08-2cbaea1789d8)

Here you can customize the list of weapons, the path to CS2, etc:

![image](https://github.com/user-attachments/assets/7ad3a91c-0a2c-48f3-b506-d30ca20c3316)

### Base weapon textures

CS2 SP Workshop Tools shaders require a set of base weapon textures to calculate paint wear, dirt, and other effects.

**The plugin does not provide the textures by default due to the large size of the files.**
However, If you have Counter-Strike 2 installed on your computer, you can automatically decompile the textures with the plugin.
Otherwise, you will need to provide the textures manually.

When you launch the plugin it checks the textures and if some of them are missing this popup will open:

![image](https://github.com/user-attachments/assets/4fd40c05-a052-4c45-bcd3-4f787e2436b7)

If you follow the popup with no CS2 path yet configured, the plugin will tell you about it:

![image](https://github.com/user-attachments/assets/57b7f6bd-683d-46be-b901-371bec4c42cc)

Once everything's ready decompilation will start:

![image](https://github.com/user-attachments/assets/a31d7e56-bf70-4454-9da9-e6c50d60c5c1)

> **Please note:** The process may take a couple of minutes. Don't close the plugin until it's finished.

# Guide

## Creating Weapon Finish

### New Project

### From existing Project

## Weapon Finish Workflow
