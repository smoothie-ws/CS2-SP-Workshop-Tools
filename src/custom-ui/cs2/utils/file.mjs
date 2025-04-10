export class File {
    static read(url) {
        var req = new XMLHttpRequest();
        req.open("GET", url, false);
        req.send();
        if (req.status !== 200)
            throw new Error("Error reading file: ", req.status, req.statusText);
        return req.responseText;
    }

    static write(url, content) {
        var req = new XMLHttpRequest();
        req.open("PUT", url, false);
        req.setRequestHeader("Content-Type", "text/plain;charset=UTF-8");
        req.send(content);
        if (req.status !== 201 && req.status !== 204)
            throw new Error("Error writing file: ", req.status, req.statusText);
    }

    static getFileName(url) {
        return url.toString().split("/").pop().split(".")[0];
    }

    static exists(url) {
        return new Promise((resolve, reject) => {
            const xhr = new XMLHttpRequest();
            xhr.open("HEAD", url, true);
            xhr.onreadystatechange = function () {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    if (xhr.status === 200 || xhr.status === 304) resolve(true);
                    else if (xhr.status === 404) resolve(false);
                    else
                        reject(
                            new Error(
                                `Error checking file existence: ${xhr.status} ${xhr.statusText}`
                            )
                        );
                }
            };
            xhr.send();
        });
    }
}
