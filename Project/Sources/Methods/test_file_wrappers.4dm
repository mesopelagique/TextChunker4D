//%attributes = {}
var $file:=Folder(fk resources folder).file("sample.md")
ASSERT($file.exists; "Sample markdown file must exist.")

var $markdownSplitter:=cs.MarkdownTextSplitter.new()
var $fromText:=$markdownSplitter.splitText($file.getText("UTF-8"; Document with LF); {sourceName: $file.name; chunkSize: 160; chunkOverlap: 20})
var $fromFile:=$markdownSplitter.splitFile($file; {chunkSize: 160; chunkOverlap: 20})
ASSERT(JSON Stringify($fromText)=JSON Stringify($fromFile); "Markdown splitFile must delegate to splitText on file content.")

var $recursiveSplitter:=cs.RecursiveTextSplitter.new()
var $textChunks:=$recursiveSplitter.splitText($file.getText("UTF-8"; Document with LF); {sourceName: $file.name; chunkSize: 120; chunkOverlap: 10})
var $fileChunks:=$recursiveSplitter.splitFile($file; {chunkSize: 120; chunkOverlap: 10})
ASSERT(JSON Stringify($textChunks)=JSON Stringify($fileChunks); "Recursive splitFile must delegate to splitText on file content.")
