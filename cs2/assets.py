import os
import shutil


class AssetBundle(dict):
    """ Represents a bundle asset, which contains multiple assets. """

    def __init__(self, url=None):
        super().__init__()
        self._root_folder = None
        if url:
            if isinstance(url, str):
                url = os.path.abspath(url)
                self._root_folder = url
                self._load(url)
            elif isinstance(url, bytes):
                try:
                    url = os.path.abspath(url.decode('utf-8'))
                    self._root_folder = url
                    self._load(url)
                except UnicodeDecodeError:
                    pass
            elif isinstance(url, (dict, AssetBundle)):
                self.update(url)
            else:
                raise TypeError(f'{type(url)} is incompatible type')

    def _load(self, directory):
        """ Load assets from the specified directory. """

        def traverse(path, tree):
            for entry in os.listdir(path):
                full_path = os.path.join(path, entry)
                if os.path.isdir(full_path):
                    tree[entry] = AssetBundle()
                    traverse(full_path, tree[entry])
                else:
                    tree[entry] = full_path

        traverse(directory, self)

    @property
    def fullpath(self):
        """ Return the full path to the folder represented by the class. """

        return self._root_folder

    def fetch(self, key, default=None):
        try:
            return self[key]
        except KeyError:
            for value in self.values():
                if isinstance(value, AssetBundle):
                    result = value.fetch(key, default)
                    if result is not default:
                        return result
            return default

    def copy_assets(self, dest_dir):
        """ Copy the asset bundle to a new directory. """

        dest_dir = os.path.abspath(dest_dir)

        for key, value in self.items():
            src_path = value
            dest_path = os.path.join(dest_dir, key)

            if isinstance(value, dict):
                os.makedirs(dest_path, exist_ok=True)
                sub_bundle = AssetBundle(src_path)
                sub_bundle.copy_assets(dest_path)
            else:
                shutil.copy2(src_path, dest_path)

    def __call__(self, child_name):
        child = AssetBundle(self[child_name])
        child._root_folder = os.path.join(self.fullpath, child_name)
        return child

    def __eq__(self, other):
        other_tree = AssetBundle(other)
        return self.keys() == other_tree.keys()

    def __ne__(self, other):
        return not self == other

    def __lt__(self, other):
        other_tree = AssetBundle(other)
        return set(self.keys()) < set(other_tree.keys())

    def __le__(self, other):
        other_tree = AssetBundle(other)
        return set(self.keys()) <= set(other_tree.keys())

    def __gt__(self, other):
        other_tree = AssetBundle(other)
        return set(self.keys()) > set(other_tree.keys())

    def __ge__(self, other):
        other_tree = AssetBundle(other)
        return set(self.keys()) >= set(other_tree.keys())
