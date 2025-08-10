import os, io, json, zipfile, shutil, tempfile

from urllib import error as urlerror
from urllib import request as urlrequest

from .log import Log


def fetch_json(url, timeout=5):
    with urlrequest.urlopen(urlrequest.Request(
            url=url, 
            headers={
                "Accept": "application/vnd.github+json",
                "User-Agent": "Substance 3D Painter"
            }
        ), timeout=timeout) as r:
        return json.loads(r.read().decode()), r.headers


class Updates:
    @staticmethod
    def check_for_updates(repo: str, tag: str):
        def fmt(commits):
            return [{
                "sha": c.get("sha",""),
                "author": (c.get("author") or {}).get("login", "unknown"),
                "message": c.get("commit",{}).get("message","").strip()
            } for c in commits]

        def all_commits_to(tag_with_v, limit=100, timeout=5):
            url = f'https://api.github.com/repos/{repo}/commits?sha={tag_with_v}&per_page=100'
            acc = []
            while url and len(acc) < limit:
                data, headers = fetch_json(url, timeout)
                if not isinstance(data, list) or not data: break
                acc.extend(data)
                nxt = None
                link = headers.get("Link", "")
                if link:
                    for part in link.split(","):
                        part = part.strip()
                        if 'rel="next"' in part:
                            nxt = part[part.find("<")+1:part.find(">")]
                            break
                url = nxt
            return fmt(acc)

        data, _ = fetch_json(f'https://api.github.com/repos/{repo}/releases/latest', timeout=3)
        latest = data.get("tag_name")
        if latest and latest != tag: 
            Log.warning(f'New version available: {latest}. Download: https://github.com/{repo}/releases')
            compare_url = f'https://api.github.com/repos/{repo}/compare/{tag}...{latest}'
            try:
                cmp_data, _ = fetch_json(compare_url, timeout=3)
                return latest, fmt(cmp_data.get("commits", []))
            except urlerror.HTTPError as ex:
                if ex.code == 404:
                    return latest, all_commits_to(latest, limit=100, timeout=5)
                
        return None, None
    
    @staticmethod
    def update(repo: str, tag: str, dest: str):
        def download_bytes(url, timeout=30):
            with urlrequest.urlopen(url, timeout=timeout) as r:
                return r.read()

        def extract_zip_bytes(blob: bytes, out_dir: str) -> str:
            with zipfile.ZipFile(io.BytesIO(blob)) as z:
                top = z.namelist()[0].split("/")[0]
                z.extractall(out_dir)
            return os.path.join(out_dir, top)

        def copy_overwrite(src: str, dst: str):
            for root, dirs, files in os.walk(src):
                rel = os.path.relpath(root, src)
                target_root = os.path.join(dst, rel) if rel != "." else dst
                os.makedirs(target_root, exist_ok=True)
                for d in dirs:
                    os.makedirs(os.path.join(target_root, d), exist_ok=True)
                for f in files:
                    shutil.copy2(os.path.join(root, f), os.path.join(target_root, f))

        try:
            rel = fetch_json(f'https://api.github.com/repos/{repo}/releases/tags/{tag}')
        except Exception:
            Log.fatal()
            return False

        asset_url = None
        for a in rel.get("assets") or []:
            name = (a.get("name") or "").lower()
            if name.endswith(".zip"):
                asset_url = a.get("browser_download_url")
                break
        if not asset_url:
            asset_url = rel.get("zipball_url")
        if not asset_url:
            Log.fatal()
            return False

        try:
            blob = download_bytes(asset_url)
        except Exception:
            Log.fatal()
            return False

        tmpdir = tempfile.mkdtemp(prefix="plugin_update_")
        try:
            unpack_root = extract_zip_bytes(blob, tmpdir)
            copy_overwrite(unpack_root, dest)
        except Exception:
            Log.fatal()
            return False
        finally:
            shutil.rmtree(tmpdir, ignore_errors=True)

        Log.info(f'Installed version {tag}. Please restart the plugin to apply.')
        return True
