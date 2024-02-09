import substance_painter.project as sp_project
from ._log import Log

class Project:
    Log.i("The file path of the project is now: '{0}'".format(sp_project.file_path()))