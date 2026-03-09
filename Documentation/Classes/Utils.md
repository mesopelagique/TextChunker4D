# `cs.textChunker.Utils`

Singleton helper used internally by the splitter classes.

Access it with:

```4d
var $utils:=cs.textChunker.Utils.me
```

## Purpose

`Utils` centralizes the shared helper behavior used across the splitter library:

- object and collection copying
- option merging
- format separator lookup
- JS/JSX tag-aware separator expansion
- text normalization
- file reading through `4D.File.getText(...)`
- chunk trimming and chunk object construction
- chunk renumbering
- checksum and timestamp helpers
- source-name title extraction

## Main Functions

- `copyObject($source : Object) : Object`
- `copyCollection($source : Collection) : Collection`
- `mergeOptions($defaults : Object; $overrides : Object) : Object`
- `separatorsForFormat($format : Text) : Collection`
- `jsFrameworkSeparators($text : Text; $customSeparators : Collection) : Collection`
- `normalizeText($text : Text) : Text`
- `readTextFile($file : 4D.File; $options : Object) : Object`
- `trimChunk($text : Text; $baseStartIndex : Integer) : Object`
- `buildChunk($text : Text; $chunkIndex : Integer; $startIndex : Integer; $metadata : Object; $sourceName : Text) : Object`
- `renumberChunks($chunks : Collection) : Collection`
- `digest($text : Text) : Text`
- `isoTimestamp() : Text`
- `titleFromSourceName($sourceName : Text) : Text`

## Notes

- `Utils` is a singleton class.
- Most callers use it indirectly through splitter classes.
- It is mainly useful directly when building custom splitters or ingestion helpers on top of `TextChunker4D`.
