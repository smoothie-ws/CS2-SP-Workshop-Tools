import os
import shutil
import threading
import subprocess
from concurrent.futures import ThreadPoolExecutor

from .path import Path
from .settings import Settings


class Decompiler:
    progress = 0.0
    vrf_path = ""

    @staticmethod
    def decompile(pak_path:str, out_path:str, weapon_list:dict, state_callback, update_callback):
        Decompiler.progress = 0.0
        Decompiler.vrf_path = Settings.get_asset_path("vrf")
        weapon_list_len = len(weapon_list)

        models_path = Path.join(out_path, "models")
        if not Path.exists(models_path):
            Path.makedirs(models_path)

        def task():
            # extract
            temp_path = Path.join(out_path, "temp")
            temp_models_path = Path.join(temp_path, "weapons", "models")
            state_callback("Extracting textures from pak01_dir.vpk")
            run(f'Source2Viewer-CLI.exe -i "{pak_path}" --vpk_filepath "weapons\models" -e "vtex_c" -o "{temp_path}"', Decompiler.vrf_path)
            with ThreadPoolExecutor(max_workers=12) as executor:
                futures = []
                # decompile
                def ucb(w):
                    Decompiler.progress += 1 / weapon_list_len
                    update_callback(Decompiler.progress, w)

                for w in Path.listdir(temp_models_path):
                    w_path = Path.join(temp_models_path, w)
                    mat_path = Path.join(w_path, "materials")
                    if weapon_list.get(w) is None or not Path.exists(mat_path):
                        rmdir(w_path)
                        continue
                    futures.append(executor.submit(Decompiler.process, w, w_path, mat_path, state_callback, ucb))

                for future in futures:
                    future.result()

            for w in Path.listdir(temp_models_path):
                w_path = Path.join(temp_models_path, w)
                Path.replace(w_path, Path.join(models_path, w))

            rmdir(temp_path)
            state_callback("Finished")

        threading.Thread(target=task).start()

    @staticmethod
    def process(w, w_path, mat_path, state_callback, update_callback):
        for wf in Path.listdir(mat_path):
            wf_path = Path.join(w_path, "materials", wf)
            if Path.isdir(wf_path):
                if wf == "composite_inputs":
                    for cif in Path.listdir(wf_path):
                        Path.replace(Path.join(wf_path, cif), Path.join(w_path, cif))
                else:
                    rmdir(wf_path)
            else:
                Path.replace(wf_path, Path.join(w_path, wf))

        for wf in Path.listdir(w_path):
            wf_path = Path.join(w_path, wf)
            if Path.isdir(wf_path):
                rmdir(wf_path)
            elif "vtex_c" in wf:
                flag = False
                for tex in [
                        "default_color", f'{w}_color', "substrate_color", "masks", "cavity", "rough", "surface"
                    ]:
                    if tex in wf:
                        name = f'{w}_{tex.split("_")[-1]}.png'
                        state_callback(f'Converting {name}')
                        Decompiler.decompile_vtex(w_path, wf, name)
                        flag = True
                        break
                if not flag:
                    Path.remove(wf_path)
            else:
                Path.remove(wf_path)
        
        update_callback(w)

    @staticmethod
    def decompile_vtex(folder: str, name: str, tgt_name: str):
        # decompile
        src = Path.join(folder, name)
        tgt = src.replace("vtex_c", "png")
        run(f'Source2Viewer-CLI.exe -i "{src}" -o "{tgt}"', Decompiler.vrf_path)
        tgt_path = Path.join(folder, tgt_name)
        if Path.exists(tgt_path):
            Path.remove(tgt_path)
        Path.rename(tgt, tgt_path)
        # clear
        Path.remove(src)


def rmdir(path):
    try:
        shutil.rmtree(path)
    except:
        pass


def run(cmd:str, cwd:str=None):
    process = subprocess.Popen(
        cmd,
        shell=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        cwd=cwd,
        creationflags=subprocess.CREATE_NO_WINDOW if os.name == 'nt' else 0
    )
    stdout, stderr = process.communicate()
    return process.returncode, stdout.decode('utf-8'), stderr.decode('utf-8')
