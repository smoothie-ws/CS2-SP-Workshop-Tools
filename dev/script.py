import os
import shutil
from PIL import Image
from concurrent.futures import ThreadPoolExecutor


def rmdir(path):
    try:
        shutil.rmtree(path)
    except:
        pass


def decompile_vtex(folder: str, name: str, tgt_size: tuple, tgt_name: str):
    # decompile
    src = os.path.join(folder, name)
    tgt = src.replace("vtex_c", "png")
    os.system(f'Source2Viewer-CLI.exe -i "{src}" -o "{tgt}"')

    # convert
    with Image.open(tgt) as img:
        img = img.convert("RGB")
        img = img.resize(tgt_size)
        img.save(os.path.join(folder, f'{tgt_name}.jpg'))

    # clear
    os.remove(src)
    os.remove(tgt)


def process(w_path, mat_path):
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
            if "masks" in wf:
                decompile_vtex(w_path, wf, (1024, 1024), "masks")
            elif "cavity" in wf:
                decompile_vtex(w_path, wf, (2048, 2048), "cavity")
            elif "default_color" in wf:
                decompile_vtex(w_path, wf, (2048, 2048), "color")
            elif "default_rough" in wf:
                decompile_vtex(w_path, wf, (2048, 2048), "rough")
            elif "default_normal" in wf:
                decompile_vtex(w_path, wf, (2048, 2048), "normal")
            else:
                os.remove(wf_path)
        else:
            os.remove(wf_path)


if __name__ == "__main__":
    path = "../src/custom-ui/cs2/assets/textures"
    path = os.path.abspath(path)

    models_path = os.path.join(path, "models")
    if os.path.exists(models_path) and os.path.isdir(models_path):
        rmdir(models_path)

    # extract
    pak_path = "C:\Program Files (x86)\Steam\steamapps\common\Counter-Strike Global Offensive\game\csgo\pak01_dir.vpk"
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
            if w in ["c4", "knife", "grenade", "shared"] or not os.path.exists(mat_path):
                rmdir(w_path)
                continue

            futures.append(executor.submit(process, w_path, mat_path))

        for future in futures:
            future.result()

        for w in os.listdir(temp_models_path):
            w_path = os.path.join(temp_models_path, w)
            os.replace(w_path, os.path.join(models_path, w))

    rmdir(temp_path)
