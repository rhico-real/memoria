# Memoria Offline AI Design

## Summary
Memoria is a private, offline-first macOS app for organizing personal files with local AI. It indexes references to files on disk, extracts metadata and content, generates local embeddings for text and images, and exposes semantic search and similarity discovery through a SwiftUI interface.

This first version is a single-machine desktop app. It does not sync to phone devices yet, but the architecture leaves clear seams for later iPhone access, selective sync, and offline mobile inference.

## Goals
- Run entirely offline on the Mac.
- Store file references, not duplicate file contents.
- Ingest PDFs, text documents, and images from individual files or folders.
- Extract text from documents and semantic signals from images.
- Auto-tag files using local AI.
- Support unified semantic search across documents and images.
- Support similarity discovery from any selected file.
- Present a native macOS interface with sidebar, search, results, and preview.
- Keep the model layer swappable so Hugging Face-hosted models can be plugged in locally.

## Non-Goals For v1
- Cloud sync.
- Multi-user collaboration.
- Browser-based access.
- OCR as a required hard dependency.
- Advanced document editing.
- Rewriting or copying imported files into a managed vault.

## Product Shape
Memoria behaves like a private Finder-plus-Spotlight hybrid:
- The sidebar exposes dynamic views such as All Files, Tags, Dates, File Types, and saved semantic categories.
- The main pane supports search, browsing, and ranking.
- The preview pane explains why a file matched a query and shows metadata, tags, and related items.

Folders in the UI are not literal filesystem folders. They are computed views over tags and metadata. A single file may appear in multiple views without duplication.

## Core User Flows
### 1. Ingest
The user adds files or imports a folder. Memoria stores the source path, file identity, timestamps, type, and extracted metadata. It does not move or duplicate the original file.

### 2. Analyze
The system extracts text from documents and generates embeddings for documents and images using local models. It also derives auto-tags such as subject, date grouping, and file type.

### 3. Search
The user types natural language like "crocodile images" or "documents about reptiles". Memoria embeds the query locally, compares it against stored vectors, and returns mixed document and image results ranked by relevance.

### 4. Discover Similar Files
When a user selects a file, the app finds nearby items in embedding space across both text and image content.

## Architecture
### App Layer
SwiftUI provides the app shell, navigation, search bar, results grid/list, and preview panel.

### Domain Layer
The domain layer owns file records, tags, views, embeddings, ranking, and relationship logic. It should remain UI-agnostic so the same core can later support iPhone or other clients.

### Ingestion Pipeline
An ingestion worker performs:
- file discovery
- document text extraction
- image preprocessing
- metadata collection
- model inference
- tag generation
- persistence updates

The pipeline should be resumable so indexing can continue after app restarts.

### Storage Layer
SQLite stores the canonical local state:
- file records
- tag records
- many-to-many file-tag relationships
- extracted text
- embedding vectors or vector references
- model version metadata
- indexing status

### AI Layer
The AI layer is a local abstraction over model execution. It hides the runtime choice so the app can use Hugging Face-compatible models through a local runtime such as Core ML, ONNX Runtime, or another embedded inference engine.

The AI layer should expose separate capabilities for:
- text embedding
- image embedding
- lightweight classification or tagging
- optional prompt-style local explanation generation later

## Data Model
### Files
Stores one row per referenced file.
Key fields:
- id
- source_path
- file_name
- file_extension
- mime_type
- size_bytes
- created_at
- modified_at
- indexed_at
- content_hash
- media_kind
- extraction_status

### Tags
Stores semantic and structural labels.
Key fields:
- id
- name
- kind
- source
- created_at

Examples:
- `Crocodiles`
- `Animals`
- `May 2026`
- `PDF`
- `Image`

### FileTags
Many-to-many join table.
Key fields:
- file_id
- tag_id
- confidence
- source

### Embeddings
Stores vector representations and metadata.
Key fields:
- id
- file_id
- modality
- model_id
- vector_blob
- dimension
- created_at

### ExtractionArtifacts
Stores extracted text and analysis outputs.
Key fields:
- file_id
- extracted_text
- summary
- detected_entities
- analysis_json

### ModelRegistry
Tracks local models used by the system.
Key fields:
- id
- name
- source
- version
- modality
- local_path
- checksum
- loaded_at

## Tagging Strategy
Tags come from three sources:
1. Deterministic metadata, such as file type and date groups.
2. AI-generated semantic labels based on content.
3. User-curated tags added manually later.

Auto-tags should be additive rather than destructive. A file may belong to many categories at once. The same file can appear under `Crocodiles`, `Animals`, and `May 2026` without duplication because the UI is driven by filtered views over the same file record.

## Search And Ranking
Search should combine:
- semantic similarity from embeddings
- metadata filters
- tag filters
- file type filters
- recency signals where appropriate

The initial ranking strategy should be simple and explainable:
- embedding similarity as the primary score
- optional boost for exact tag matches
- optional boost for recent or frequently accessed files

Search results should include an explanation panel with the strongest signals, such as:
- matched query embedding
- shared tag
- file type
- source date group
- similar sibling items

## Similarity Discovery
Each file should expose a "Find similar" action. The system compares the selected file's embedding against stored embeddings of the same modality and, where feasible, across modalities using the shared semantic space.

For v1:
- document-to-document similarity is required
- image-to-image similarity is required
- cross-modal similarity is desirable if the chosen model space supports it

## Model Strategy
The model layer must be plug-and-play with Hugging Face assets. The app should not hardcode one model family into the rest of the product.

Recommended abstraction:
- `EmbeddingModel`
- `TaggingModel`
- `Preprocessor`
- `ModelProvider`

That separation allows the app to swap between:
- a Hugging Face model packaged locally
- Core ML compiled artifacts
- ONNX Runtime models

The first release should prioritize a simple, stable model path over a complex multi-model orchestration system.

## UI Design
### Sidebar
Sections:
- All Files
- Tags
- Dates
- File Types
- Saved Views

### Main Pane
Contains:
- search bar
- result list or grid depending on context
- filters

### Preview Pane
Contains:
- file preview
- metadata
- extracted tags
- why-it-matched explanation
- similar files

The interface should feel native to macOS:
- calm spacing
- restrained colors
- consistent sidebar hierarchy
- keyboard-first navigation

## Future Sync Readiness
The app should be designed so the later iPhone version can reuse the same conceptual core.

Prepare for sync by keeping these boundaries clean:
- file identity separate from file storage location
- local indexing separate from network transport
- domain model separate from UI
- model execution separate from persistence

Future mobile sync can add:
- mirrored metadata
- selective file download
- offline search on device
- local AI inference on phone
- conflict handling for tags and user edits

None of that is part of the first implementation.

## Risks And Constraints
- Local AI model availability may affect startup time and memory pressure.
- File references can break if the original file moves or is deleted.
- Cross-modal search quality depends on the chosen model space.
- Large folder imports may require background processing and progress tracking.
- Embedding storage can grow quickly and needs a compact representation.

## Open Design Decisions
- Whether to use Core ML first or ONNX first for local inference.
- Whether image and text embeddings should share one semantic space initially.
- Whether tag generation should be fully automatic or partially user-assisted at first.
- Whether to support OCR in v1 or defer it.

## Proposed Build Order Later
1. SQLite schema and persistence model
2. File ingestion and extraction pipeline
3. Local embedding and tagging abstraction
4. Semantic search and similarity engine
5. SwiftUI shell and navigation
6. Preview and explanation UI
7. Model loading from local Hugging Face assets
8. Future sync architecture stub
