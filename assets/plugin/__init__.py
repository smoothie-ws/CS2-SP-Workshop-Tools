from substance_painter.logging import log, INFO


def start_plugin():
    log(INFO, "CS2 Workshop Tools", "The plugin was loaded successfully!")


def close_plugin():
    pass


if __name__ == "__main__":
    start_plugin()
