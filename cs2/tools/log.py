from substance_painter.logging import INFO, WARNING, ERROR
from substance_painter.logging import log as sp_log

class Log:
    channel = "CS2 Workshop Tools"
    
    @staticmethod
    def i(message: any):
        sp_log(INFO, Log.channel, str(message))

    @staticmethod
    def w(message: any):
        sp_log(WARNING, Log.channel, str(message))

    @staticmethod
    def e(message: any):
        sp_log(ERROR, Log.channel, str(message))
