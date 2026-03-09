//%attributes = {}
#DECLARE($folder : 4D.Folder; $query : Text; $config : Object) : Object

ASSERT(Length(String($query))>0; "A query is required.")

var $sourceFolder : 4D.Folder:=$folder
If ($sourceFolder=Null)
	$sourceFolder:=Folder(fk resources folder).folder("folder-import")
End if

var $options : Object:=($config#Null) ? JSON Parse(JSON Stringify($config); Is object) : {}
If ($options=Null)
	$options:={}
End if
If ($options.embedNow=Null)
	$options.embedNow:=True
End if
If ($options.recursive=Null)
	$options.recursive:=True
End if

var $importSummary:=cs.IngestService.new().importFolder($sourceFolder; $options)
ASSERT($importSummary.importedCount>0; "No supported files were imported from the folder.")

var $service:=cs.RAGService.new($options)
var $topK : Integer:=($options.topK#Null) ? Num($options.topK) : 5
var $threshold : Real:=($options.threshold#Null) ? Num($options.threshold) : 0.75
var $answer:=$service.answer($query; $topK; $threshold)

return {question: String($query); importSummary: {importedCount: $importSummary.importedCount; skippedCount: $importSummary.skippedCount; recursive: $importSummary.recursive; extensions: $importSummary.extensions; importedFiles: $importSummary.importedFiles; skippedFiles: $importSummary.skippedFiles; embedded: Bool($options.embedNow)}; rag: $answer}
