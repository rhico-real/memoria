import Foundation
import PDFKit

struct DocumentTextExtractor {
    func extractText(from url: URL) throws -> String? {
        switch url.pathExtension.lowercased() {
        case "txt", "md", "json", "csv", "rtf":
            return try String(contentsOf: url, encoding: .utf8)
        case "pdf":
            guard let document = PDFDocument(url: url) else { return nil }
            return (0..<document.pageCount)
                .compactMap { document.page(at: $0)?.string }
                .joined(separator: "\n")
        default:
            return nil
        }
    }
}
