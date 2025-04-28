import os


class Path:
    @staticmethod
    def norm(path: str) -> str:
        return os.path.normpath(path).replace("\\", "/")
    
    @staticmethod
    def exists(path:str) -> bool:
        return os.path.exists(path)
    
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
    def remove(path:str):
        os.remove(path)
