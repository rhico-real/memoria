import Foundation

final class IngestionService {
    private let repository: MemoriaRepositoryProtocol
    private let scanner: FileScanner
    private let documentTextExtractor: DocumentTextExtractor
    private let imageFeatureExtractor: ImageFeatureExtractor

    init(
        repository: MemoriaRepositoryProtocol,
        scanner: FileScanner = FileScanner(),
        documentTextExtractor: DocumentTextExtractor = DocumentTextExtractor(),
        imageFeatureExtractor: ImageFeatureExtractor = ImageFeatureExtractor()
    ) {
        self.repository = repository
        self.scanner = scanner
        self.documentTextExtractor = documentTextExtractor
        self.imageFeatureExtractor = imageFeatureExtractor
    }

    func ingest(urls: [URL]) throws -> [FileRecord] {
        let fileURLs = try scanner.scan(urls: urls)
        var records: [FileRecord] = []

        for url in fileURLs {
            let identity = try FileIdentity(url: url)
            var extractionStatus: ExtractionStatus = .pending

            switch identity.mediaKind {
            case .document:
                _ = try documentTextExtractor.extractText(from: url)
                extractionStatus = .ready
            case .image:
                _ = try imageFeatureExtractor.extractFeatures(from: url)
                extractionStatus = .ready
            }

            let record = identity.makeFileRecord(extractionStatus: extractionStatus)
            try repository.upsert(record)
            records.append(record)
        }

        return records
    }
}
