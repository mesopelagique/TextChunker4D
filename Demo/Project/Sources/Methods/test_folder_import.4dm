//%attributes = {}
If (Length(Data file())=0)
	LOG EVENT(Into system standard outputs; "CANNOT TEST WITHOUT DATA, So use 4D app, not tool4D or not 4D with --dataless"; Warning message)
	return 
End if 

var $folder:=Folder(fk resources folder).folder("folder-import")
var $service:=cs.IngestService.new()

var $codeFile : 4D.File:=$folder.file("SampleService.4dm")
var $codeDocument:=$service.importFourDCodeFile($codeFile; {chunkSize: 80; chunkOverlap: 10})
ASSERT($codeDocument#Null; "4D code import must return a document entity.")
ASSERT($codeDocument.sourceType="4dcode"; "4D code files must be stored with sourceType='4dcode'.")
ASSERT(ds.Chunks.query("documentID = :1"; $codeDocument.ID).length>0; "4D code import must persist chunks.")

_resetData

var $recursiveSummary:=$service.importFolder($folder; {recursive: True; extensions: [".md"; ".4dm"]})
ASSERT($recursiveSummary.importedCount=3; "Recursive folder import must ingest supported nested files.")
ASSERT($recursiveSummary.skippedCount=1; "Unsupported files must be reported as skipped.")
ASSERT(ds.Documents.all().length=3; "Recursive folder import must persist one document per imported file.")
ASSERT(ds.Documents.query("sourceType = :1"; "markdown").length=2; "Recursive folder import must persist Markdown files.")
ASSERT(ds.Documents.query("sourceType = :1"; "4dcode").length=1; "Recursive folder import must persist 4D code files.")
ASSERT(ds.Documents.query("sourceName = :1"; "nested").length=1; "Recursive folder import must include nested files.")

_resetData

var $flatSummary:=$service.importFolder($folder; {recursive: False; extensions: [".md"; ".4dm"]})
ASSERT($flatSummary.importedCount=2; "Non-recursive folder import must ignore nested files.")
ASSERT(ds.Documents.query("sourceName = :1"; "nested").length=0; "Non-recursive folder import must not import nested files.")
