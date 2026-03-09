# TextSplitter

The `cs.textChunker.TextSplitter` class is the abstract parent for text-based splitter classes.

It defines the stable public API shared by the concrete splitters:

- `splitText(...)`
- `splitFile(...)`

Do not instantiate `TextSplitter` directly for real work. Use one of the concrete classes instead.

## Functions

### splitText()

**splitText**(*text* : Text; *options* : Object) : Collection

Abstract function. The base implementation raises an assertion and must be overridden by subclasses.

| Argument | Type | Description |
|----------|------|-------------|
| *text* | Text | Source text to split. |
| *options* | Object | Splitter options. |
| Function result | Collection | Collection of chunk DTOs. |

### splitFile()

**splitFile**(*file* : 4D.File; *options* : Object) : Collection

Reads a `4D.File`, injects `sourceName`, and delegates to the subclass `splitText(...)`.

| Argument | Type | Description |
|----------|------|-------------|
| *file* | [4D.File](https://developer.4d.com/docs/API/FileClass) | File to read and split. |
| *options* | Object | Splitter options. Supports `charSetName` for file reading. |
| Function result | Collection | Collection of chunk DTOs. |

## Returned Chunk Shape

All splitter classes return chunk objects with this shape:

```4d
{
    text: Text;
    chunkIndex: Integer;
    startIndex: Integer;
    charCount: Integer;
    metadata: Object;
    sourceName: Text
}
```
