import substance_painter.project as sp_project


class Project:
    def __init__(self):
        self.metadata = sp_project.Metadata("CS2WT")

    def save(self):
        sp_project.save()

    def save_as_econitem(self):
        pass
