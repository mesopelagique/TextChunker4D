# MarkdownTextSplitter

The `cs.textChunker.MarkdownTextSplitter` class is a Markdown-aware splitter.

It splits by heading sections first, ignores headings inside fenced code blocks, preserves heading metadata on each chunk, and recursively re-splits oversized sections.

## Default Configuration

| Property | Value |
|----------|-------|
| `defaultStripHeaders` | `True` |
| `defaultHeadingLevels` | `[1; 2; 3; 4]` |

## Functions

### splitText()

**splitText**(*markdown* : Text; *options* : Object) : Collection

Split Markdown text into chunks with heading-aware metadata.

| Argument | Type | Description |
|----------|------|-------------|
| *markdown* | Text | Markdown source text. |
| *options* | Object | Splitter options. |
| Function result | Collection | Collection of chunk DTOs. |

Supported options:

| Option | Type | Description |
|--------|------|-------------|
| `stripHeaders` | Boolean | Remove heading lines from chunk text while keeping heading metadata. |
| `headingLevels` | Collection | Heading levels to detect, such as `[1; 2; 3; 4]`. |
| `chunkSize` | Integer | Maximum target size used when large sections are recursively re-split. |
| `chunkOverlap` | Integer | Overlap reused during recursive re-splitting. |
| `sourceName` | Text | Source name copied to each chunk. |

Metadata keys produced by this splitter:

- `h1`
- `h2`
- `h3`
- `h4`

### splitFile()

**splitFile**(*file* : 4D.File; *options* : Object) : Collection

Inherited from [TextSplitter](TextSplitter.md). Reads the file and delegates to `splitText(...)`.

## Example

```4d
var $splitter:=cs.textChunker.MarkdownTextSplitter.new()
var $chunks:=$splitter.splitFile($file; {stripHeaders: True; headingLevels: [1; 2; 3; 4]})
```
