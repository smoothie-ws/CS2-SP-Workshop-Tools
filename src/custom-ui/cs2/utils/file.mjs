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
}
