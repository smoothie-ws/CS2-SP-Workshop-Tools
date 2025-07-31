import os
import threading
import subprocess
from concurrent.futures import ThreadPoolExecutor

from ..painter import Path


class Decompiler:    
    @staticmethod
    def check_weapon_textures(weapon:str) -> bool:
        weapon_path = Path.asset("textures", "models", weapon)
        for tex in ["color", "cavity", "masks", "rough", "surface"]:
            if not Path.exists(Path.join(weapon_path, f'{weapon}_{tex}.png')):
                return False
        return True
    
    @staticmethod
    def decompile(pak_path: str, out_path: str, weapon_list: list, state_callback, update_callback):
        weapon_list_len = len(weapon_list)

        models_path = Path.join(out_path, "models")
        Path.remove(models_path) # clear
        Path.makedirs(models_path)

        progress = 0.0
        
        def task():
            # extract
            temp_path = Path.join(out_path, "temp")
            temp_models_path = Path.join(temp_path, "weapons", "models")
            state_callback("Extracting textures from pak01_dir.vpk")
            Decompiler.run(f'-i "{pak_path}" --vpk_filepath "weapons/models" -e "vtex_c" -o "{temp_path}"')
            
            with ThreadPoolExecutor() as executor:
                futures = []
                
                def ucb(w):
                    nonlocal progress
                    progress += 1 / weapon_list_len
                    update_callback(progress, w)

                # decompile
                for w in Path.listdir(temp_models_path):
                    w_path = Path.join(temp_models_path, w)
                    mat_path = Path.join(w_path, "materials")
                    if not (w in weapon_list and Path.exists(mat_path)) or Decompiler.check_weapon_textures(w):
                        Path.remove(w_path)
                        continue
                    futures.append(executor.submit(Decompiler.process, w, w_path, mat_path, state_callback, ucb))

                for future in futures:
                    future.result()

            for w in Path.listdir(temp_models_path):
                w_path = Path.join(temp_models_path, w)
                Path.replace(w_path, Path.join(models_path, w))

            Path.remove(temp_path)
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
                    Path.remove(wf_path)
            else:
                Path.replace(wf_path, Path.join(w_path, wf))

        for wf in Path.listdir(w_path):
            wf_path = Path.join(w_path, wf)
            if Path.isdir(wf_path):
                Path.remove(wf_path)
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
        src = Path.join(folder, name)
        tgt = src.replace("vtex_c", "png")
        Decompiler.run(f'-i "{src}" -o "{tgt}"')
        
        tgt_path = Path.join(folder, tgt_name)
        if Path.exists(tgt_path):
            Path.remove(tgt_path)
            
        Path.rename(tgt, tgt_path)
        Path.remove(src)

    @staticmethod
    def run(cmd: str):
        subprocess.run(
            f'Source2Viewer-CLI.exe {cmd}',
            shell=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            cwd=Path.asset("vrf"),
            creationflags=subprocess.CREATE_NO_WINDOW if os.name == 'nt' else 0
        )
        