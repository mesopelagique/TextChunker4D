# TextChunker4D Demo

`Demo/` is a separate 4D project that shows how to use `TextChunker4D` in a persistence and RAG workflow.

It is intentionally separate from the root splitter library:

- root project: splitters only
- `Demo/`: ORDA storage, embeddings, retrieval, and answer generation

## Dependencies

The demo depends on:

- `TextChunker4D`
- `4D AIKit`

`environment4d.json` currently maps the local dependency like this:

```json
{
  "dependencies": {
    "TextChunker4D": { "path": "../" }
  }
}
```

## What The Demo Covers

- split a Markdown document with `cs.textChunker.MarkdownTextSplitter`
- store a `Document` row and related `Chunk` rows with ORDA
- create embeddings with `4D AIKit`
- store vectors directly in `Chunks.embedding` as `4D.Vector`
- retrieve matching chunks with vector search
- assemble context and ask a chat model for an answer

## Main Classes

### `cs.IngestService`

Entry point for importing Markdown into the demo datastore.

Methods:
- `importMarkdownText($sourceText : Text; $sourceName : Text; $options : Object) : Object`
- `importMarkdownFile($file : 4D.File; $options : Object) : Object`
- `importFourDCodeText($sourceText : Text; $sourceName : Text; $options : Object) : Object`
- `importFourDCodeFile($file : 4D.File; $options : Object) : Object`
- `importFile($file : 4D.File; $options : Object) : Object`
- `importFolder($folder : 4D.Folder; $options : Object) : Object`

It routes supported extensions to the matching splitter, creates the `Documents` entity, then persists one `Chunks` entity per returned chunk.

Supported extensions in `importFile(...)` and `importFolder(...)`:
- `.md`, `.markdown`
- `.4dm`
- `.py`
- `.html`, `.htm`
- `.tex`
- `.json`
- `.js`, `.ts`, `.jsx`, `.tsx`, `.vue`, `.svelte`
- `.txt`

Useful folder-import options:
- `recursive`
- `extensions`
- `format`
- `embedNow`

### `cs.EmbeddingService`

Thin wrapper around `4D AIKit` embedding calls.

Methods:
- `embedChunks($chunks : Collection; $config : Object) : Collection`
- `embedQuery($query : Text; $config : Object) : 4D.Vector`

Default config keys:
- `embeddingModel`
- `chatModel`
- `apiKey`
- `baseURL`

### `cs.RAGService`

Retrieval and answer assembly service.

Methods:
- `retrieve($query : Text; $topK : Integer; $threshold : Real) : Object`
- `answer($query : Text; $topK : Integer; $threshold : Real) : Object`
- `matchesToCollection($selection; $queryVector : 4D.Vector) : Collection`

It supports either:
- generating a query embedding through `EmbeddingService`
- or using `config.queryVector` directly for offline retrieval tests

## Demo Methods

- `ImportMarkdownFile($file; $config)`
- `ImportFolder($folder; $config)`
- `ImportFolderAndAnswer($folder; $query; $config)`
- `Search($query; $config)`
- `Answer($query; $config)`

Typical flow:

1. Open the `Demo` project.
2. Ensure `TextChunker4D` resolves through `environment4d.json`.
3. Ensure `4D AIKit` is available.
4. Run `ImportMarkdownFile(...)` or `ImportFolder(...)`.
5. Run `Search(...)` or `Answer(...)`.

For a single-call flow, `ImportFolderAndAnswer(...)` imports the folder, embeds the new chunks, then runs a RAG answer for the supplied question.

## Notes

- If `4D AIKit` is missing, the demo project will not compile fully because `EmbeddingService` and `RAGService` depend on `cs.AIKit`.
- The splitter tests belong to the root project. The demo project contains the datastore and retrieval example.
