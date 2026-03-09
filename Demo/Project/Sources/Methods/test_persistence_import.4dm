//%attributes = {}
If (Length(Data file())=0)
	LOG EVENT(Into system standard outputs; "CANNOT TEST WITHOUT DATA, So use 4D app, not tool4D or not 4D with --dataless"; Warning message)
	return 
End if 

var $file:=Folder(fk resources folder).file("sample.md")
var $options : Object:={chunkSize: 160; chunkOverlap: 20}
var $document:=cs.IngestService.new().importMarkdownFile($file; $options)
ASSERT($document#Null; "Import must return a document entity.")
ASSERT($document.sourceName=$file.name; "Stored document source name must match the imported file.")

var $chunks:=ds.Chunks.query("documentID = :1"; $document.ID).orderBy("chunkIndex asc")
ASSERT($chunks.length>1; "Import must store multiple chunks.")

var $expectedChunks:=cs.textChunker.MarkdownTextSplitter.new().splitFile($file; $options)
ASSERT($expectedChunks.length=$chunks.length; "Stored chunk count must match the splitter output.")

var $first:=$chunks.first()
var $expectedFirst : Object:=$expectedChunks[0]
ASSERT($first.chunkIndex=0; "First stored chunk index must be 0.")
ASSERT($first.headers.h1="TextChunker4D Overview"; "Heading metadata must be stored on chunk records.")
ASSERT($first.text=String($expectedFirst.text); "First stored chunk text must match the splitter output.")
ASSERT($first.startIndex=Num($expectedFirst.startIndex); "First stored chunk start index must match the splitter output.")
