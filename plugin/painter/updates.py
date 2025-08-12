import os, io, json, zipfile, shutil, tempfile, threading

from datetime import datetime
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
            def get_date(c: dict):
                raw_date = c.get("commit", {}).get("committer", {}).get("date")
                if not raw_date:
                    return None
                return datetime.strptime(raw_date, "%Y-%m-%dT%H:%M:%SZ").strftime("%d %b %Y")
            
            return [{
                "sha": c.get("sha",""),
                "author": (c.get("author") or {}).get("login", "unknown"),
                "date": get_date(c),
                "message": c.get("commit",{}).get("message","").strip()
            } for c in commits]

        def all_commits_to(tag, limit=100, timeout=5):
            url = f'https://api.github.com/repos/{repo}/commits?sha={tag}&per_page=100'
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
    def update(repo: str, tag: str, dest: str, state_callback, update_callback):
        def task():
            try:
                # release info
                try:
                    rel, _ = fetch_json(f'https://api.github.com/repos/{repo}/releases/tags/{tag}')
                except Exception as e:
                    Log.error(f'Failed to download an update: {e}')
                    state_callback("Error"); return

                asset_url = None
                for a in rel.get("assets") or []:
                    name = (a.get("name") or "").lower()
                    if name.endswith(".zip"):
                        asset_url = a.get("browser_download_url"); break
                if not asset_url:
                    asset_url = rel.get("zipball_url")
                if not asset_url:
                    Log.error("Failed to download an update")
                    state_callback("Error"); return

                # download (30%)
                try:
                    state_callback("Downloading")
                    req = urlrequest.Request(asset_url, headers={"User-Agent": "CS2-SP-Workshop-Tools"})
                    with urlrequest.urlopen(req, timeout=30) as r:
                        total = r.headers.get("Content-Length")
                        total = int(total) if total and total.isdigit() else None
                        buf = io.BytesIO()
                        read = 0
                        chunk = 1024 * 64
                        while True:
                            b = r.read(chunk)
                            if not b: break
                            buf.write(b)
                            read += len(b)
                            if total:
                                update_callback(min(0.3 * (read / total), 0.3))
                        blob = buf.getvalue()
                    if not total:
                        update_callback(0.3)
                except Exception as e:
                    Log.error(f'Failed to download an update: {e}')
                    state_callback("Error"); return

                # install (70%)
                state_callback("Installing")
                tmpdir = tempfile.mkdtemp(prefix="plugin_update_")
                try:
                    with zipfile.ZipFile(io.BytesIO(blob)) as z:
                        z.extractall(tmpdir)
                        top = z.namelist()[0].split("/")[0]
                    unpack_root = os.path.join(tmpdir, top)

                    total_files = 0
                    for _, _, files in os.walk(unpack_root):
                        total_files += len(files)
                    processed = 0
                    weight_base = 0.3
                    weight_install = 0.7

                    for root, dirs, files in os.walk(unpack_root):
                        relp = os.path.relpath(root, unpack_root)
                        target_root = os.path.join(dest, relp) if relp != "." else dest
                        os.makedirs(target_root, exist_ok=True)
                        for d in dirs:
                            os.makedirs(os.path.join(target_root, d), exist_ok=True)
                        for f in files:
                            shutil.copy2(os.path.join(root, f), os.path.join(target_root, f))
                            processed += 1
                            frac = processed / total_files if total_files else 1.0
                            update_callback(weight_base + weight_install * frac)
                except Exception as e:
                    Log.error(f'Failed to install update: {e}')
                    state_callback("Error"); return
                finally:
                    shutil.rmtree(tmpdir, ignore_errors=True)

                state_callback("Finished")

            except Exception as e:
                Log.error(f'Unexpected update error: {e}')
                state_callback("Error")

        threading.Thread(target=task, daemon=True).start()
