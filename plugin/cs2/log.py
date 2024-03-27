from substance_painter import logging as splog


class Log:
    channel = "CS2 Workshop Tools"

    @staticmethod
    def info(message: any):
        splog.log(splog.INFO, Log.channel, str(message))

    @staticmethod
    def warning(message: any):
        splog.log(splog.WARNING, Log.channel, str(message))

    @staticmethod
    def error(message: any):
        splog.log(splog.ERROR, Log.channel, str(message))
