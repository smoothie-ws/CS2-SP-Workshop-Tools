from substance_painter.logging import log, INFO, WARNING, ERROR

class Log:
    channel = "CS2 Workshop Tools"

    @classmethod
    def set_channel(cls, channel: str):
        cls.channel = channel
    
    @staticmethod
    def i(message: str):
        log(INFO, Log.channel, message)

    @staticmethod
    def w(message: str):
        log(WARNING, Log.channel, message)

    @staticmethod
    def e(message: str):
        log(ERROR, Log.channel, message)