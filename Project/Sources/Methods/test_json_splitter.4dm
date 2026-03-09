//%attributes = {}
var $json : Text:="{\"intro\":{\"title\":\"Alpha\",\"summary\":\"Short\"},\"details\":{\"items\":[{\"label\":\"One\",\"value\":\"A\"},{\"label\":\"Two\",\"value\":\"B\"}],\"notes\":\"Gamma Delta Epsilon Zeta Eta Theta\"}}"
var $splitter:=cs.RecursiveJsonSplitter.new()

var $textChunks:=$splitter.splitText($json; {maxChunkSize: 70; minChunkSize: 40; convertLists: True})
ASSERT($textChunks.length>=2; "JSON splitter must emit more than one structured chunk when the payload is large enough.")
ASSERT(Position("\"intro\""; $textChunks[0].text)>0; "First JSON chunk must preserve the root structure.")
ASSERT($textChunks[0].metadata.format="json"; "JSON chunks must carry JSON metadata.")

var $withoutLists:=$splitter.splitText($json; {maxChunkSize: 70; minChunkSize: 40; convertLists: False})
ASSERT($textChunks.length>=$withoutLists.length; "List conversion must not reduce JSON chunk coverage.")

var $firstCall:=$splitter.splitText("{\"a\":1,\"b\":2}"; {maxChunkSize: 80; minChunkSize: 50; convertLists: False})
var $secondCall:=$splitter.splitText("{\"c\":3,\"d\":4}"; {maxChunkSize: 80; minChunkSize: 50; convertLists: False})
ASSERT(($firstCall.length=1) & (Position("\"a\":1"; $firstCall[0].text)>0); "First JSON split call must preserve its own payload.")
ASSERT(($secondCall.length=1) & (Position("\"c\":3"; $secondCall[0].text)>0); "Second JSON split call must not mutate the previous result.")
