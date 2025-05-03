import os
import shutil
import pathlib
import subprocess


class Path:
    @staticmethod
    def norm(path: str) -> str:
        return os.path.normpath(path).replace("\\", "/")
    
    @staticmethod
    def exists(path:str) -> bool:
        return path and os.path.exists(path)
    
    @staticmethod
    def join(*paths) -> str:
        return Path.norm(os.path.join(*paths))
    
    @staticmethod
    def listdir(path:str) -> list:
        return os.listdir(path)

    @staticmethod
    def makedirs(path:str):
        os.makedirs(path)

    @staticmethod
    def replace(src:str, dst:str):
        os.replace(src, dst)
    
    @staticmethod
    def isdir(path:str):
        return os.path.isdir(path)
    
    @staticmethod
    def remove(path:str):
        if Path.exists(path):
            try:
                if Path.isdir(path):
                    shutil.rmtree(path)
                else:
                    os.remove(path)
            except:
                pass

    @staticmethod
    def rename(src: str, tgt: str):
        os.rename(src, tgt)

    @staticmethod
    def filename(path:str):
        return pathlib.Path(path).stem
    
    @staticmethod
    def show_in_explorer(path:str):
        # explorer would choke on forward slashes
        path = os.path.normpath(path)

        if os.path.isdir(path):
            subprocess.run(['explorer', path])
        elif os.path.isfile(path):
            subprocess.run(['explorer', '/select,', path])
    