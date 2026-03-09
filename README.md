# TextChunker4D

`TextChunker4D` is the splitter library project. It focuses on turning text-like inputs into stable chunk collections that can be reused for indexing, embeddings, or downstream RAG pipelines.

The public namespace is:

- `cs.textChunker.TextSplitter`
- `cs.textChunker.RecursiveTextSplitter`
- `cs.textChunker.CharacterTextSplitter`
- `cs.textChunker.MarkdownTextSplitter`
- `cs.textChunker.RecursiveJsonSplitter`
- `cs.textChunker.HtmlTextSplitter`
- `cs.textChunker.LatexTextSplitter`
- `cs.textChunker.PythonCodeTextSplitter`
- `cs.textChunker.FourDCodeTextSplitter`
- `cs.textChunker.JSFrameworkTextSplitter`
- `cs.textChunker.Utils`

RAG, ORDA persistence, and embedding examples now live in [`Demo/README.md`](Demo/README.md).

## Scope

- Split plain text with overlap
- Split files through `4D.File.getText()`
- Split Markdown by headers, then recursively re-split large sections
- Split JSON while preserving object structure
- Split code and markup with format-specific separator lists
- Return a shared chunk DTO that can be stored or embedded elsewhere

## Chunk Shape

All splitter classes return a `Collection` of objects with the same structure:

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

## Quick Start

```4d
var $splitter:=cs.textChunker.RecursiveTextSplitter.new()
var $chunks : Collection:=$splitter.splitText($text; {chunkSize: 1200; chunkOverlap: 150})
```

```4d
var $markdown:=cs.textChunker.MarkdownTextSplitter.new()
var $chunks : Collection:=$markdown.splitFile($file; {stripHeaders: True; headingLevels: [1; 2; 3; 4]})
```

## Common Options

Most splitter classes accept an `$options : Object`.

- `chunkSize`: maximum chunk size for recursive splitting
- `chunkOverlap`: overlap reused between adjacent chunks
- `sourceName`: explicit source name to place in returned chunks
- `charSetName`: optional charset passed to `4D.File.getText(...)` for `splitFile(...)`

Format-specific classes may add their own options.

## Class Reference

### `cs.textChunker.TextSplitter`

Abstract parent for text-oriented splitter classes.

Methods:
- `splitText($text : Text; $options : Object) : Collection`
- `splitFile($file : 4D.File; $options : Object) : Collection`

Behavior:
- `splitText(...)` asserts unless the subclass overrides it
- `splitFile(...)` is implemented once in the parent and delegates to the subclass `splitText(...)`

Use it as the shared contract for custom splitters. Concrete callers should instantiate a subclass instead of `TextSplitter` itself.

### `cs.textChunker.RecursiveTextSplitter`

Base recursive splitter for arbitrary text.

Methods:
- `splitText($text : Text; $options : Object) : Collection`
- `splitFile($file : 4D.File; $options : Object) : Collection`

Defaults:
- `chunkSize = 1200`
- `chunkOverlap = 150`
- `separators = ["\n\n"; "\n"; " "; ""]`

Use it when you want a general-purpose splitter and already know the separator priority you want.

### `cs.textChunker.CharacterTextSplitter`

Small wrapper around `RecursiveTextSplitter` for a single preferred separator with recursive fallback to character slicing.

Methods:
- `splitText($text : Text; $options : Object) : Collection`
- `splitFile($file : 4D.File; $options : Object) : Collection`

Specific options:
- `separator`: preferred separator, default `Char(10)+Char(10)`

Use it when you want predictable chunking around one delimiter such as blank lines or commas.

### `cs.textChunker.MarkdownTextSplitter`

Markdown-aware splitter. It detects headings first, keeps heading metadata on each returned chunk, ignores headings inside fenced code blocks, and recursively re-splits oversized sections.

Methods:
- `splitText($markdown : Text; $options : Object) : Collection`
- `splitFile($file : 4D.File; $options : Object) : Collection`

Specific options:
- `stripHeaders`: default `True`
- `headingLevels`: default `[1; 2; 3; 4]`

Metadata:
- `h1`
- `h2`
- `h3`
- `h4`

Use it for Markdown notes, manuals, and docs where section structure matters.

### `cs.textChunker.RecursiveJsonSplitter`

Structured splitter for JSON objects, JSON text, and JSON files. It keeps nested paths grouped until a size threshold is reached, then starts a new JSON chunk.

Methods:
- `splitObject($jsonData; $options : Object) : Collection`
- `splitText($jsonText : Text; $options : Object) : Collection`
- `splitFile($file : 4D.File; $options : Object) : Collection`

Specific options:
- `maxChunkSize`: default `2000`
- `minChunkSize`: default `1800`
- `convertLists`: convert collections into keyed objects before splitting

Metadata:
- `format = "json"`

Use it when flattening to plain text would lose too much structural context.

### `cs.textChunker.HtmlTextSplitter`

Recursive splitter preconfigured with common HTML tag separators such as `<body`, `<div`, `<p`, heading tags, table tags, and script/style blocks.

Methods:
- `splitText($html : Text; $options : Object) : Collection`
- `splitFile($file : 4D.File; $options : Object) : Collection`

Use it for HTML pages, fragments, and exported rich-text content.

### `cs.textChunker.LatexTextSplitter`

Recursive splitter preconfigured for LaTeX section commands, list environments, quote environments, math delimiters, and plain text fallback.

Methods:
- `splitText($latex : Text; $options : Object) : Collection`
- `splitFile($file : 4D.File; $options : Object) : Collection`

Use it for `.tex` source where section boundaries are stronger than raw paragraph breaks.

### `cs.textChunker.PythonCodeTextSplitter`

Recursive splitter with Python-oriented separators such as `class`, `def`, nested `def`, blank lines, and whitespace fallback.

Methods:
- `splitText($python : Text; $options : Object) : Collection`
- `splitFile($file : 4D.File; $options : Object) : Collection`

Use it for Python modules, notebooks exported as scripts, or doc generation inputs.

### `cs.textChunker.FourDCodeTextSplitter`

Recursive splitter with 4D-specific separators including class declarations, constructors, `Function`, `#DECLARE`, variable declarations, and common control-flow blocks.

Methods:
- `splitText($code : Text; $options : Object) : Collection`
- `splitFile($file : 4D.File; $options : Object) : Collection`

Use it for `.4dm` source or other 4D code extracts where chunking should follow language structure first.

### `cs.textChunker.JSFrameworkTextSplitter`

Recursive splitter for JavaScript, TypeScript, JSX, and TSX. It combines a JS-oriented separator list with detected tag openings from the provided source text.

Methods:
- `splitText($sourceText : Text; $options : Object) : Collection`
- `splitFile($file : 4D.File; $options : Object) : Collection`

Specific options:
- `separators`: optional custom separators merged ahead of detected JS and JSX separators

Use it for component files where both code and markup boundaries matter.

### `cs.textChunker.Utils`

Singleton helper used by the splitter classes.

Access:

```4d
var $utils:=cs.textChunker.Utils.me
```

Useful public helpers:
- `copyObject(...)`
- `copyCollection(...)`
- `mergeOptions(...)`
- `separatorsForFormat(...)`
- `jsFrameworkSeparators(...)`
- `normalizeText(...)`
- `readTextFile(...)`
- `trimChunk(...)`
- `buildChunk(...)`
- `renumberChunks(...)`
- `digest(...)`
- `isoTimestamp()`
- `titleFromSourceName(...)`

You usually do not need to call this class directly unless you are building your own splitter or ingestion layer on top of the library.

## Tests

The root project test methods cover:

- recursive text splitting
- markdown header splitting
- file wrappers
- format-specific splitters
- JSON splitting
