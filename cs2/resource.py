import substance_painter as sp


def search(callback, shelf: str="", usage: str="", name: str=""):
    def cb(e):
        if e.shelf_name == shelf:
            callback(sp.resource.search(f's: {shelf} u: {usage} n: {name}'))
            sp.event.DISPATCHER.disconnect(sp.event.ShelfCrawlingEnded, cb)

    if not sp.resource.Shelf(shelf).is_crawling():
        sp.resource.Shelves.refresh_all()

    sp.event.DISPATCHER.connect_strong(sp.event.ShelfCrawlingEnded, cb)
