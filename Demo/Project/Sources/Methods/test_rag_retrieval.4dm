//%attributes = {}
If (Length(Data file())=0)
	LOG EVENT(Into system standard outputs; "CANNOT TEST WITHOUT DATA, So use 4D app, not tool4D or not 4D with --dataless"; Warning message)
	return 
End if 

var $document:=ds.Documents.new()
$document.title:="offline-rag"
$document.sourceType:="markdown"
$document.sourceName:="offline-rag.md"
$document.rawText:="offline test"
$document.checksum:="offline"
$document.createdAt:=cs.textChunker.Utils.me.isoTimestamp()
$document.save()

var $chunk1:=ds.Chunks.new()
$chunk1.documentID:=$document.ID
$chunk1.chunkIndex:=0
$chunk1.text:="Chunking breaks long text into reusable segments."
$chunk1.charCount:=Length($chunk1.text)
$chunk1.startIndex:=0
$chunk1.headers:={h1: "Chunking"}
$chunk1.embeddingModel:="seed"
$chunk1.embedding:=4D.Vector.new([1; 0; 0])
$chunk1.save()

var $chunk2:=ds.Chunks.new()
$chunk2.documentID:=$document.ID
$chunk2.chunkIndex:=1
$chunk2.text:="Retrieval compares a query vector with stored chunk vectors."
$chunk2.charCount:=Length($chunk2.text)
$chunk2.startIndex:=60
$chunk2.headers:={h1: "Retrieval"}
$chunk2.embeddingModel:="seed"
$chunk2.embedding:=4D.Vector.new([0; 1; 0])
$chunk2.save()

var $chunk3:=ds.Chunks.new()
$chunk3.documentID:=$document.ID
$chunk3.chunkIndex:=2
$chunk3.text:="Persistence keeps document and chunk rows available for later search."
$chunk3.charCount:=Length($chunk3.text)
$chunk3.startIndex:=120
$chunk3.headers:={h1: "Storage"}
$chunk3.embeddingModel:="seed"
$chunk3.embedding:=4D.Vector.new([0; 0; 1])
$chunk3.save()

var $queryVector : 4D.Vector:=4D.Vector.new([0; 1; 0])
var $service:=cs.RAGService.new({queryVector: $queryVector})
var $selection:=$service.retrieve("How does retrieval work?"; 2; 0.2)
var $matches:=$service.matchesToCollection($selection; $queryVector)

ASSERT($matches.length>=1; "Retrieval must return at least one match.")
ASSERT(Position("Retrieval compares a query vector"; $matches[0].text)>0; "Top match must be the retrieval chunk.")
ASSERT(($matches[0].similarity>0.99) & ($matches[0].similarity<=1); "Top match similarity must be near 1.")
