# FourDCodeTextSplitter

The `cs.textChunker.FourDCodeTextSplitter` class is a recursive splitter preconfigured for 4D source code.

It prefers 4D-specific boundaries such as class declarations, constructors, `Function`, `#DECLARE`, local variable blocks, and common control-flow markers.

## Functions

### splitText()

**splitText**(*code* : Text; *options* : Object) : Collection

Split 4D code into chunk DTOs.

| Argument | Type | Description |
|----------|------|-------------|
| *code* | Text | 4D source code. |
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
var $splitter:=cs.textChunker.FourDCodeTextSplitter.new()
var $chunks:=$splitter.splitFile($file; {chunkSize: 800; chunkOverlap: 80})
```
