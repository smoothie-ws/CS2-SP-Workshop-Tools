from substance_painter.logging import INFO, WARNING, ERROR
from substance_painter.logging import log as sp_log

class Log:
    channel = "CS2 Workshop Tools"
    
    @staticmethod
    def i(message: str):
        sp_log(INFO, Log.channel, message)

    @staticmethod
    def w(message: str):
        sp_log(WARNING, Log.channel, message)

    @staticmethod
    def e(message: str):
        sp_log(ERROR, Log.channel, message)
