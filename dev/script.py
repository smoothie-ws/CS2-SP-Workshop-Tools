import os
import shutil
import sys
from PIL import Image, ImageChops
from concurrent.futures import ThreadPoolExecutor


def rmdir(path):
    try:
        shutil.rmtree(path)
    except:
        pass


def decompile_vtex(folder: str, name: str, scale: float, tgt_name: str):
    # decompile
    src = os.path.join(folder, name)
    tgt = src.replace("vtex_c", "png")
    os.system(f'Source2Viewer-CLI.exe -i "{src}" -o "{tgt}"')

    # convert
    with Image.open(tgt) as img:
        try:
            if (scale != 1.0):
                img = img.resize((int(img.size[0] * scale), int(img.size[1] * scale)))
            # swap channels for cavity texture
            if "cavity" in name:
                img = Image.merge("RGB", (
                    img.getchannel("R"), 
                    img.getchannel("G"), 
                    img.getchannel("A")
                ))
            # swap channels for surface texture
            elif "surface" in name:
                img = Image.merge("RGB", (
                    img.getchannel("R"), 
                    img.getchannel("B"), 
                    ImageChops.invert(img.getchannel("G"))
                ))
            else:
                img = img.convert("RGB")
            img.save(os.path.join(folder, tgt_name))
        except:
            pass

    # clear
    os.remove(src)
    os.remove(tgt)


def process(w, w_path, mat_path, img_scale, img_format):
    for wf in os.listdir(mat_path):
        wf_path = os.path.join(w_path, "materials", wf)
        if os.path.isdir(wf_path):
            if wf == "composite_inputs":
                for cif in os.listdir(wf_path):
                    os.replace(os.path.join(wf_path, cif), os.path.join(w_path, cif))
            else:
                rmdir(wf_path)
        else:
            os.replace(wf_path, os.path.join(w_path, wf))

    for wf in os.listdir(w_path):
        wf_path = os.path.join(w_path, wf)
        if os.path.isdir(wf_path):
            rmdir(wf_path)
        elif "vtex_c" in wf:
            flag = False
            for tex in [
                    "default_color", f'{w}_color', "substrate_color", "masks", "cavity", "rough", "surface"
                ]:
                if tex in wf:
                    decompile_vtex(w_path, wf, img_scale, f'{w}_{tex.split("_")[-1]}.{img_format}')
                    flag = True
                    break
            if not flag:
                os.remove(wf_path)
        else:
            os.remove(wf_path)


def decompile(pak_path, exclude, img_scale, img_format):
    path = "../src/custom-ui/cs2/assets/textures"
    path = os.path.abspath(path)

    models_path = os.path.join(path, "models")
    if os.path.exists(models_path) and os.path.isdir(models_path):
        rmdir(models_path)

    # extract
    temp_path = os.path.join(path, "temp")
    os.system(f'Source2Viewer-CLI.exe -i "{pak_path}" --vpk_filepath "weapons\models" -e "vtex_c" -o "{temp_path}"')

    os.makedirs(models_path)

    with ThreadPoolExecutor(max_workers=12) as executor:
        futures = []

        # decompile
        temp_models_path = os.path.join(temp_path, "weapons", "models")
        for w in os.listdir(temp_models_path):
            w_path = os.path.join(temp_models_path, w)
            mat_path = os.path.join(w_path, "materials")
            if w in exclude or not os.path.exists(mat_path):
                rmdir(w_path)
                continue

            futures.append(executor.submit(process, w, w_path, mat_path, img_scale, img_format))

        for future in futures:
            future.result()

        for w in os.listdir(temp_models_path):
            w_path = os.path.join(temp_models_path, w)
            os.replace(w_path, os.path.join(models_path, w))

    rmdir(temp_path)


if __name__ == "__main__":
    args = sys.argv[1:]

    pak_path = "C:\Program Files (x86)\Steam\steamapps\common\Counter-Strike Global Offensive\game\csgo\pak01_dir.vpk"
    exclude = "c4, knife, grenade, shared"
    img_scale = 1.0
    img_format = "png"

    try:
        for i in range(0, len(args), 2):
            if args[i] == "--pack" or args[i] == "-p":
                exclude = args[i + 1]
            elif args[i] == "--exclude" or args[i] == "-e":
                exclude = args[i + 1]
            elif args[i] == "--scale" or args[i] == "-s":
                img_scale = float(args[i + 1])
            elif args[i] == "--format" or args[i] == "-f":
                img_format = args[i + 1]
            else:
                print(f'Unknown argument: {args[i]}')
                sys.exit(1)
    except (IndexError, ValueError):
        print("Invalid command line arguments")
        sys.exit(1)

    decompile(pak_path, exclude, img_scale, img_format)
