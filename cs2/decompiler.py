import os
import shutil
import threading
import subprocess
from concurrent.futures import ThreadPoolExecutor

from .settings import Settings


class Decompiler:
    progress = 0.0
    vrf_path = ""

    @staticmethod
    def decompile(pak_path:str, out_path:str, weapon_list:dict, state_callback, update_callback):
        Decompiler.progress = 0.0
        Decompiler.vrf_path = Settings.get_asset_path("vrf")
        weapon_list_len = len(weapon_list)

        models_path = os.path.join(out_path, "models")
        if not os.path.exists(models_path):
            os.makedirs(models_path)

        def task():
            # extract
            temp_path = os.path.join(out_path, "temp")
            temp_models_path = os.path.join(temp_path, "weapons", "models")
            state_callback("Extracting textures from pak01_dir.vpk")
            run(f'Source2Viewer-CLI.exe -i "{pak_path}" --vpk_filepath "weapons\models" -e "vtex_c" -o "{temp_path}"', Decompiler.vrf_path)
            with ThreadPoolExecutor(max_workers=12) as executor:
                futures = []
                # decompile
                def ucb(w):
                    Decompiler.progress += 1 / weapon_list_len
                    update_callback(Decompiler.progress, w)

                for w in os.listdir(temp_models_path):
                    w_path = os.path.join(temp_models_path, w)
                    mat_path = os.path.join(w_path, "materials")
                    if weapon_list.get(w) is None or not os.path.exists(mat_path):
                        rmdir(w_path)
                        continue
                    futures.append(executor.submit(Decompiler.process, w, w_path, mat_path, state_callback, ucb))

                for future in futures:
                    future.result()

            for w in os.listdir(temp_models_path):
                w_path = os.path.join(temp_models_path, w)
                os.replace(w_path, os.path.join(models_path, w))

            rmdir(temp_path)
            state_callback("Finished")

        threading.Thread(target=task).start()

    @staticmethod
    def process(w, w_path, mat_path, state_callback, update_callback):
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
                        name = f'{w}_{tex.split("_")[-1]}.png'
                        state_callback(f'Converting {name}')
                        Decompiler.decompile_vtex(w_path, wf, name)
                        flag = True
                        break
                if not flag:
                    os.remove(wf_path)
            else:
                os.remove(wf_path)
        
        update_callback(w)

    @staticmethod
    def decompile_vtex(folder: str, name: str, tgt_name: str):
        # decompile
        src = os.path.join(folder, name)
        tgt = src.replace("vtex_c", "png")
        run(f'Source2Viewer-CLI.exe -i "{src}" -o "{tgt}"', Decompiler.vrf_path)
        tgt_path = os.path.join(folder, tgt_name)
        if os.path.exists(tgt_path):
            os.remove(tgt_path)
        os.rename(tgt, tgt_path)
        # clear
        os.remove(src)


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
