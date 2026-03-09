# LatexTextSplitter

The `cs.textChunker.LatexTextSplitter` class is a recursive splitter preconfigured for LaTeX source files.

It prefers section commands, environments, and math delimiters before falling back to generic recursive splitting.

## Functions

### splitText()

**splitText**(*latex* : Text; *options* : Object) : Collection

Split LaTeX text into chunk DTOs.

| Argument | Type | Description |
|----------|------|-------------|
| *latex* | Text | LaTeX source text. |
| *options* | Object | Splitter options. |
| Function result | Collection | Collection of chunk DTOs. |

Supported options:

| Option | Type | Description |
|--------|------|-------------|
| `chunkSize` | Integer | Maximum target size of a chunk. |
| `chunkOverlap` | Integer | Overlap reused between adjacent chunks. |
| `sourceName` | Text | Source name copied to each chunk. |

### splitFile()

**splitFile**(*file* : 4D.File; *options* : Object) : Collection

Inherited from [TextSplitter](TextSplitter.md). Reads the file and delegates to `splitText(...)`.

## Example

```4d
var $splitter:=cs.textChunker.LatexTextSplitter.new()
var $chunks:=$splitter.splitFile($file; {chunkSize: 1200; chunkOverlap: 100})
```
