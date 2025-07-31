import os
import shutil
import pathlib
import subprocess


class Path:
    plugin: str = ""
    settings: str = ""
    documents: str = ""

    @staticmethod
    def asset(*paths: str) -> str:
        return Path.join(Path.plugin, "assets", *paths)
    
    @staticmethod
    def to(path: str) -> str:
        return Path.norm(os.path.dirname(path))
    
    @staticmethod
    def norm(path: str) -> str:
        return os.path.normpath(path).replace("\\", "/")
    
    @staticmethod
    def exists(path: str) -> bool:
        return path is not None and os.path.exists(path)
    
    @staticmethod
    def join(*paths) -> str:
        return Path.norm(os.path.join(*paths))
    
    @staticmethod
    def listdir(path: str) -> list:
        return os.listdir(path)

    @staticmethod
    def makedirs(path: str) -> None:
        os.makedirs(path)

    @staticmethod
    def copy(src: str, dst: str) -> None:
        shutil.copyfile(src, dst)
    
    @staticmethod
    def replace(src: str, dst: str) -> bool:
        try:
            os.replace(src, dst)
            return True
        except:
            return False
    
    @staticmethod
    def isdir(path: str) -> bool:
        return os.path.isdir(path)
    
    @staticmethod
    def remove(path: str) -> bool:
        if Path.exists(path):
            try:
                if Path.isdir(path):
                    shutil.rmtree(path)
                else:
                    os.remove(path)
                return True
            except:
                pass
        return False

    @staticmethod
    def rename(src: str, tgt: str) -> None:
        os.rename(src, tgt)

    @staticmethod
    def filename(path: str) -> str:
        return pathlib.Path(path).stem
    
    @staticmethod
    def show_in_explorer(path: str) -> None:
        path = path.replace("/", "\\") # explorer would choke on forward slashes
        if os.path.isdir(path):
            subprocess.run(['explorer', path])
        elif os.path.isfile(path):
            subprocess.run(['explorer', '/select,', path])

    @staticmethod
    def read(path: str, default: str = "") -> str:
        try:
            with open(Path.norm(path), "r", encoding="utf-8") as f:
                return f.read()
        except:
            return default
        
    @staticmethod
    def write(path: str, data: str) -> int:
        try:
            with open(Path.norm(path), "w", encoding="utf-8") as f:
                return f.write(data)
        except:
            return 0
        