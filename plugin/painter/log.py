import traceback
import substance_painter as sp


class Log:
    channel = "Plugin"

    @staticmethod
    def info(msg: any):
        sp.logging.log(sp.logging.INFO, Log.channel, str(msg))
    
    @staticmethod
    def error(msg: any):
        sp.logging.log(sp.logging.ERROR, Log.channel, str(msg))
    
    @staticmethod
    def warning(msg: any):
        sp.logging.log(sp.logging.WARNING, Log.channel, str(msg))

    @staticmethod
    def fatal():
        Log.error(traceback.format_exc())
        