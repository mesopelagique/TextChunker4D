//%attributes = {}
#DECLARE($file : 4D.File; $config : Object) : Object

var $sourceFile : 4D.File:=$file
If ($sourceFile=Null)
	$sourceFile:=Folder(fk resources folder).file("sample.md")
End if

var $options : Object:=($config#Null) ? JSON Parse(JSON Stringify($config); Is object) : {}
If ($options=Null)
	$options:={}
End if
If ($options.embedNow=Null)
	$options.embedNow:=False
End if

var $document:=cs.IngestService.new().importMarkdownFile($sourceFile; $options)
var $chunkCount : Integer:=ds.Chunks.query("documentID = :1"; $document.ID).length

return {documentID: $document.ID; title: $document.title; sourceName: $document.sourceName; chunkCount: $chunkCount; embedded: Bool($options.embedNow)}
