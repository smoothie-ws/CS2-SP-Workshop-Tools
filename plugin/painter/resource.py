import substance_painter as sp


class Resource:
    Usage = sp.resource.Usage
    
    @staticmethod
    def import_session_resource(path: str, usage: Usage, name: str = None, group: str = None):
        return sp.resource.import_session_resource(path, usage, name, group)
    
    @staticmethod
    def import_project_resource(path: str, usage: Usage, name: str = None, group: str = None):
        return sp.resource.import_project_resource(path, usage, name, group)
    
    @staticmethod
    def refresh():
        sp.resource.Shelves.refresh_all()
    
    @staticmethod
    def search_resource(callback, shelf: str = "", usage: str = "", name: str = "", retries: int = 1):
        delayed = False

        def search_shelf():
            resources = sp.resource.search(f's: {shelf} u: {usage} n: {name}')
            if len(resources) > 0:
                callback(resources)
            elif retries > 0:
                Resource.refresh()
                Resource.search_resource(callback, shelf, usage, name, retries - 1)
            else:
                callback([])

        def cb(e):
            if delayed:
                if e.shelf_name == shelf:
                    sp.event.DISPATCHER.disconnect(sp.event.ShelfCrawlingEnded, cb)
                    search_shelf()
            else:
                callback(sp.resource.search(f's: {shelf} u: {usage} n: {name}'))

        if sp.resource.Shelf(shelf).is_crawling():
            delayed = True
            sp.event.DISPATCHER.connect_strong(sp.event.ShelfCrawlingEnded, cb)
        else:
            search_shelf()
        