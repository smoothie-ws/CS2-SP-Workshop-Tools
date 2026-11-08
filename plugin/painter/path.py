import os
import shutil
import pathlib
import subprocess
import tempfile

from .log import Log


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
        if Path.exists(path) and Path.isdir(path):
            return os.listdir(path)
        return []

    @staticmethod
    def makedirs(path: str) -> None:
        os.makedirs(path)

    @staticmethod
    def cleardir(path: str):
        Path.remove(path)
        Path.makedirs(path)
        return path
    
    @staticmethod
    def copy(src: str, dst: str) -> None:
        shutil.copyfile(src, dst)

    @staticmethod
    def copy_atomic(src: str, dst: str) -> None:
        """Publish a binary file without truncating an existing destination."""
        temporary = None
        try:
            with tempfile.NamedTemporaryFile(dir=os.path.dirname(os.path.abspath(dst)), delete=False) as output:
                temporary = output.name
                with open(src, "rb") as source:
                    shutil.copyfileobj(source, output)
                output.flush()
                os.fsync(output.fileno())
            os.replace(temporary, dst)
            temporary = None
        finally:
            if temporary is not None:
                try:
                    os.unlink(temporary)
                except OSError as error:
                    Log.error(f"Failed to remove temporary copy {temporary}: {error}")
    
    @staticmethod
    def replace(src: str, dst: str) -> bool:
        try:
            os.replace(src, dst)
            return True
        except OSError as error:
            Log.error(f"Failed to replace {src} with {dst}: {error}")
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
            except OSError as error:
                Log.error(f"Failed to remove {path}: {error}")
        return False

    @staticmethod
    def rename(src: str, tgt: str) -> None:
        os.rename(src, tgt)

    @staticmethod
    def filename(path: str) -> str:
        return pathlib.Path(path).stem
    
    @staticmethod
    def show_in_explorer(path: str) -> None:
        path = os.path.normpath(path)
        if os.path.isdir(path):
            subprocess.Popen(["explorer", path])
        elif os.path.isfile(path):
            subprocess.Popen(["explorer", "/select,", path])
        else:
            Log.error(f'Path {path} is invalid')
            
    @staticmethod
    def read(path: str, default: str = "") -> str:
        try:
            with open(Path.norm(path), "r", encoding="utf-8") as f:
                return f.read()
        except (OSError, TypeError, UnicodeError) as error:
            if path:
                Log.error(f"Failed to read {path}: {error}")
            return default
        
    @staticmethod
    def write(path: str, data: str) -> int:
        temporary = None
        try:
            destination = os.path.abspath(path)
            if isinstance(data, str):
                try:
                    with open(destination, "rb") as existing:
                        if existing.read() == data.encode("utf-8"):
                            return len(data)
                except OSError:
                    # A missing or unreadable destination may still be writable.
                    pass
            with tempfile.NamedTemporaryFile(mode="w", encoding="utf-8", newline="\n",
                                             dir=os.path.dirname(destination), delete=False) as output:
                temporary = output.name
                count = output.write(data)
                output.flush()
                os.fsync(output.fileno())
            os.replace(temporary, destination)
            temporary = None
            return count
        except (OSError, TypeError, UnicodeError) as error:
            Log.error(f"Failed to write {path}: {error}")
            return 0
        finally:
            if temporary is not None:
                try:
                    os.unlink(temporary)
                except OSError as error:
                    Log.error(f"Failed to remove temporary file {temporary}: {error}")
