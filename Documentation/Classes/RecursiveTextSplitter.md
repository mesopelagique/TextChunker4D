# RecursiveTextSplitter

The `cs.textChunker.RecursiveTextSplitter` class is the general-purpose splitter for arbitrary text.

It tries separators in order and recursively falls back to smaller separators until each chunk fits the configured size.

## Default Configuration

| Property | Value |
|----------|-------|
| `defaultChunkSize` | `1200` |
| `defaultChunkOverlap` | `150` |
| `defaultSeparators` | `["\n\n"; "\n"; " "; ""]` |

## Functions

### splitText()

**splitText**(*text* : Text; *options* : Object) : Collection

Split arbitrary text into chunk DTOs using recursive separator fallback.

| Argument | Type | Description |
|----------|------|-------------|
| *text* | Text | Source text to split. |
| *options* | Object | Splitter options. |
| Function result | Collection | Collection of chunk DTOs. |

Supported options:

| Option | Type | Description |
|--------|------|-------------|
| `chunkSize` | Integer | Maximum target size of a chunk. |
| `chunkOverlap` | Integer | Overlap reused between adjacent chunks. |
| `separators` | Collection | Separator priority list. |
| `sourceName` | Text | Source name copied to each chunk. |

### splitFile()

**splitFile**(*file* : 4D.File; *options* : Object) : Collection

Inherited from [TextSplitter](TextSplitter.md). Reads the file and delegates to `splitText(...)`.

## Example

```4d
var $splitter:=cs.textChunker.RecursiveTextSplitter.new()
var $chunks:=$splitter.splitText($text; {chunkSize: 1200; chunkOverlap: 150})
```
