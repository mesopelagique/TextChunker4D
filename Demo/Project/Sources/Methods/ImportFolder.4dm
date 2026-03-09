//%attributes = {}
#DECLARE($folder : 4D.Folder; $config : Object) : Object

var $sourceFolder : 4D.Folder:=$folder
If ($sourceFolder=Null)
	$sourceFolder:=Folder(fk resources folder).folder("folder-import")
End if

var $options : Object:=($config#Null) ? JSON Parse(JSON Stringify($config); Is object) : {}
If ($options=Null)
	$options:={}
End if
If ($options.embedNow=Null)
	$options.embedNow:=False
End if
If ($options.recursive=Null)
	$options.recursive:=True
End if

var $summary:=cs.IngestService.new().importFolder($sourceFolder; $options)
return {importedCount: $summary.importedCount; skippedCount: $summary.skippedCount; recursive: $summary.recursive; extensions: $summary.extensions; importedFiles: $summary.importedFiles; skippedFiles: $summary.skippedFiles; embedded: Bool($options.embedNow)}
