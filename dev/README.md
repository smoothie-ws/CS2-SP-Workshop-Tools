This is simple python script to decompile the default weapon model textures from `pak01_dir.vpk`.

To decompile weapon model textures:

1. Run `cd dev`
2. Run `python script.py`

Available command line arguments:

-   `--pack` / `-p` - absolute path to the `pack01_dir.vpk` file. Default is `"C:\Program Files (x86)\Steam\steamapps\common\Counter-Strike Global Offensive\game\csgo\pak01_dir.vpk"`
-   `--exclude` / `-e` - model folders to exclude from decompilation. Default is `"c4, knife, granite, shared"`
-   `--scale` / `-s` - decompiled image scale factor. Default is `"1.0"`
-   `--format` / `-f` - decompiled image format. Default is `"png"`
