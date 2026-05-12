import Foundation

struct FileScanner {
    func scan(urls: [URL]) throws -> [URL] {
        var results: [URL] = []
        for url in urls {
            var isDirectory: ObjCBool = false
            guard FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) else { continue }
            if isDirectory.boolValue {
                results.append(contentsOf: try scanDirectory(url))
            } else {
                results.append(url.standardizedFileURL)
            }
        }
        return results.sorted { $0.path < $1.path }
    }

    private func scanDirectory(_ url: URL) throws -> [URL] {
        guard let enumerator = FileManager.default.enumerator(
            at: url,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        ) else { return [] }

        var files: [URL] = []
        for case let fileURL as URL in enumerator {
            let values = try fileURL.resourceValues(forKeys: [.isRegularFileKey])
            if values.isRegularFile == true {
                files.append(fileURL.standardizedFileURL)
            }
        }
        return files
    }
}
