"""Install the shader notice and upgrade only the known bundled predecessor."""
import hashlib
import os

from .painter import Log, Path


# SHA256 of the original bundled ui.qml, read with universal newlines.
LEGACY_UI_SHA256 = "9bf765ee18ea2b14a635631e5b8bb0358d88f3e70f3842157d0f962cb425a1d2"
UI_FILENAME = "cs2-workshop-tools-ui.qml"


def install_shader_ui():
    source = Path.read(Path.asset("shader", "ui.qml"))
    if not source:
        raise OSError("Missing shader parameters UI asset")
    # Use a plugin-specific name: the previous generic cs2-ui.qml may belong to
    # another installation or contain user edits and must remain untouched.
    destination = Path.join(Path.documents, "assets", "shaders", "custom-ui", UI_FILENAME)
    if Path.exists(destination):
        previous = Path.read(destination)
        if previous == source:
            return
        if hashlib.sha256(previous.encode("utf-8")).hexdigest() != LEGACY_UI_SHA256:
            Log.warning(f"Preserved modified {UI_FILENAME}; shader parameters UI was not replaced")
            return
    os.makedirs(os.path.dirname(destination), exist_ok=True)
    if not Path.write(destination, source):
        raise OSError(f"Could not install shader parameters UI: {destination}")
