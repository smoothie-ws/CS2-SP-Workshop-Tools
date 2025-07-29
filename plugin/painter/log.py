import traceback
import substance_painter as sp


class Log:
    channel = "Plugin"

    @staticmethod
    def info(msg: str):
        sp.logging.log(sp.logging.INFO, Log.channel, msg)
    
    @staticmethod
    def error(msg: str):
        sp.logging.log(sp.logging.ERROR, Log.channel, msg)
    
    @staticmethod
    def warning(msg: str):
        sp.logging.log(sp.logging.WARNING, Log.channel, msg)

    @staticmethod
    def fatal():
        Log.error(traceback.format_exc())
        