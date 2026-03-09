# HtmlTextSplitter

The `cs.textChunker.HtmlTextSplitter` class is a recursive splitter preconfigured with HTML-oriented separators.

It uses common tag boundaries such as body, div, paragraph, headings, table nodes, and script/style sections before falling back to generic recursive splitting.

## Functions

### splitText()

**splitText**(*html* : Text; *options* : Object) : Collection

Split HTML or markup-like text into chunk DTOs.

| Argument | Type | Description |
|----------|------|-------------|
| *html* | Text | HTML source text. |
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
var $splitter:=cs.textChunker.HtmlTextSplitter.new()
var $chunks:=$splitter.splitText($html; {chunkSize: 1000; chunkOverlap: 100})
```
