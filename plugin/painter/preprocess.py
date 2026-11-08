"""Synchronize generated views without rewriting unchanged files."""
from pathlib import Path as FilePath

from .path import Path


def sync_views(source, destination):
    source, destination = FilePath(source), FilePath(destination)
    if not source.is_dir():
        return
    if source.is_symlink() or destination.is_symlink():
        raise ValueError("View directories must not be symbolic links")
    source, destination = source.resolve(), destination.resolve()
    if source == destination or source in destination.parents or destination in source.parents:
        raise ValueError("Source and generated views must be separate directories")
    existing = list(destination.rglob("*")) if destination.exists() else []
    if any(path.is_symlink() for path in existing):
        raise ValueError("Generated views must not contain symbolic links")
    if any(not path.resolve().is_relative_to(destination) for path in existing):
        raise ValueError("Generated views must not escape their directory")
    assets = list(source.rglob("*"))
    if any(asset.is_symlink() for asset in assets):
        raise ValueError("View assets must not be symbolic links")
    # Structural changes need a clean generated tree, just as the original
    # full rebuild did. Ordinary edits still preserve unchanged output files.
    collisions = any(
        (asset.is_dir() and (destination / asset.relative_to(source)).is_file()) or
        (asset.is_file() and (destination / asset.relative_to(source)).is_dir())
        for asset in assets)
    if collisions:
        for path in sorted(existing, key=lambda item: len(item.parts), reverse=True):
            if path.is_file():
                path.unlink()
            elif path.is_dir():
                path.rmdir()
        existing = []
    expected = set()
    for asset in assets:
        if not asset.is_file():
            continue
        target = destination / asset.relative_to(source)
        expected.add(target)
        data = asset.read_bytes()
        if target.is_file() and target.read_bytes() == data:
            continue
        target.parent.mkdir(parents=True, exist_ok=True)
        Path.copy_atomic(str(asset), str(target))
    # Prune only this resolved generated tree, after successful generation.
    for path in sorted(existing, key=lambda item: len(item.parts), reverse=True):
        if not path.resolve().is_relative_to(destination):
            raise ValueError(f"Generated path escaped its directory: {path}")
        if path.is_file() and path not in expected:
            path.unlink()
        elif path.is_dir() and not any(path.iterdir()):
            path.rmdir()
