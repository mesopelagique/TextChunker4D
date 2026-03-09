# RecursiveJsonSplitter

The `cs.textChunker.RecursiveJsonSplitter` class splits JSON while preserving nested structure.

It can operate on an in-memory object, JSON text, or a file containing JSON.

## Default Configuration

| Property | Value |
|----------|-------|
| `defaultMaxChunkSize` | `2000` |
| `defaultMinChunkSize` | `1800` |

## Functions

### splitObject()

**splitObject**(*jsonData*; *options* : Object) : Collection

Split an in-memory JSON value into chunk DTOs.

| Argument | Type | Description |
|----------|------|-------------|
| *jsonData* | Object, Collection, or scalar | JSON-compatible value to split. |
| *options* | Object | Splitter options. |
| Function result | Collection | Collection of chunk DTOs. |

### splitText()

**splitText**(*jsonText* : Text; *options* : Object) : Collection

Parse JSON text, then delegate to `splitObject(...)`.

| Argument | Type | Description |
|----------|------|-------------|
| *jsonText* | Text | JSON source text. |
| *options* | Object | Splitter options. |
| Function result | Collection | Collection of chunk DTOs. |

### splitFile()

**splitFile**(*file* : 4D.File; *options* : Object) : Collection

Inherited from [TextSplitter](TextSplitter.md). Reads the file and delegates to `splitText(...)`.

Supported options:

| Option | Type | Description |
|--------|------|-------------|
| `maxChunkSize` | Integer | Target upper bound for one JSON chunk. |
| `minChunkSize` | Integer | Minimum size before opening a new chunk. |
| `convertLists` | Boolean | Convert collections to keyed objects before splitting. |
| `sourceName` | Text | Source name copied to each chunk. |

This splitter sets `metadata.format = "json"` on returned chunks.

## Example

```4d
var $splitter:=cs.textChunker.RecursiveJsonSplitter.new()
var $chunks:=$splitter.splitText($jsonText; {maxChunkSize: 1500; convertLists: True})
```
