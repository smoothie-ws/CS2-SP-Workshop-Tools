import substance_painter as sp


def search(callback, shelf: str="", usage: str="", name: str="", retries: int = 1):
    delayed = False

    def search_shelf():
        resources = sp.resource.search(f's: {shelf} u: {usage} n: {name}')
        if len(resources) > 0:
            callback(resources)
        elif retries > 0:
            sp.resource.Shelves.refresh_all()
            search(callback, shelf, usage, name, retries - 1)
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
