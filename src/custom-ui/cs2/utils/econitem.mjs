import { File } from "./file.mjs";

export class EconItem {
    static importFrom(url) {
        var fileContent = File.read(url);
        alg.log.warning(
            `Imported parameters from ${File.getFileName(url)}.econitem`
        );
    }

    static exportTo(url) {
        File.write(url);
        alg.log.warning(
            `Exported parameters to ${File.getFileName(url)}.econitem`
        );
    }
}
