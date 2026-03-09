# PythonCodeTextSplitter

The `cs.textChunker.PythonCodeTextSplitter` class is a recursive splitter preconfigured for Python code.

It prefers `class` and `def` boundaries, then falls back to line and character-level splitting.

## Functions

### splitText()

**splitText**(*python* : Text; *options* : Object) : Collection

Split Python code into chunk DTOs.

| Argument | Type | Description |
|----------|------|-------------|
| *python* | Text | Python source code. |
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
var $splitter:=cs.textChunker.PythonCodeTextSplitter.new()
var $chunks:=$splitter.splitText($python; {chunkSize: 800; chunkOverlap: 80})
```
