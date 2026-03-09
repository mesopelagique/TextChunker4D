# JSFrameworkTextSplitter

The `cs.textChunker.JSFrameworkTextSplitter` class is a recursive splitter for JavaScript, TypeScript, JSX, and TSX.

It merges JavaScript-oriented separators with tag openings detected in the provided source text.

## Functions

### splitText()

**splitText**(*sourceText* : Text; *options* : Object) : Collection

Split JS framework source into chunk DTOs.

| Argument | Type | Description |
|----------|------|-------------|
| *sourceText* | Text | JavaScript, TypeScript, JSX, or TSX source text. |
| *options* | Object | Splitter options. |
| Function result | Collection | Collection of chunk DTOs. |

Supported options:

| Option | Type | Description |
|--------|------|-------------|
| `separators` | Collection | Optional custom separators merged before detected framework separators. |
| `chunkSize` | Integer | Maximum target size of a chunk. |
| `chunkOverlap` | Integer | Overlap reused between adjacent chunks. |
| `sourceName` | Text | Source name copied to each chunk. |

### splitFile()

**splitFile**(*file* : 4D.File; *options* : Object) : Collection

Inherited from [TextSplitter](TextSplitter.md). Reads the file and delegates to `splitText(...)`.

## Example

```4d
var $splitter:=cs.textChunker.JSFrameworkTextSplitter.new()
var $chunks:=$splitter.splitText($source; {chunkSize: 1000; chunkOverlap: 100})
```
