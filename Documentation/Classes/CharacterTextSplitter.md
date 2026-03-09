# CharacterTextSplitter

The `cs.textChunker.CharacterTextSplitter` class is a small wrapper around `RecursiveTextSplitter`.

It starts with one preferred separator, then falls back to fixed-length splitting when needed.

## Default Configuration

| Property | Value |
|----------|-------|
| `defaultSeparator` | `Char(10)+Char(10)` |

## Functions

### splitText()

**splitText**(*text* : Text; *options* : Object) : Collection

Split text using a single preferred separator and recursive fallback.

| Argument | Type | Description |
|----------|------|-------------|
| *text* | Text | Source text to split. |
| *options* | Object | Splitter options. |
| Function result | Collection | Collection of chunk DTOs. |

Supported options:

| Option | Type | Description |
|--------|------|-------------|
| `separator` | Text | Preferred separator to use first. |
| `chunkSize` | Integer | Maximum target size of a chunk. |
| `chunkOverlap` | Integer | Overlap reused between adjacent chunks. |
| `sourceName` | Text | Source name copied to each chunk. |

### splitFile()

**splitFile**(*file* : 4D.File; *options* : Object) : Collection

Inherited from [TextSplitter](TextSplitter.md). Reads the file and delegates to `splitText(...)`.

## Example

```4d
var $splitter:=cs.textChunker.CharacterTextSplitter.new()
var $chunks:=$splitter.splitText($text; {separator: ","; chunkSize: 200; chunkOverlap: 20})
```
