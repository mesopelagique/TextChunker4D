//%attributes = {}
var $lf : Text:=Char(10)
var $splitter:=cs.MarkdownTextSplitter.new()

var $case1Document : Text:="# Foo"+$lf+$lf+\
"    ## Bar"+$lf+$lf+\
"Hi this is Jim"+$lf+$lf+\
"Hi this is Joe"+$lf+$lf+\
" ## Baz"+$lf+$lf+\
" Hi this is Molly"
var $case1:=$splitter.splitText($case1Document; {chunkSize: 500; chunkOverlap: 0; headingLevels: [1; 2]})
ASSERT($case1.length=2; "Markdown header case 1 must produce two chunks.")
ASSERT($case1[0].text=("Hi this is Jim"+$lf+$lf+"Hi this is Joe"); "Markdown header case 1 first chunk text mismatch.")
ASSERT($case1[0].metadata.h1="Foo"; "Markdown header case 1 first chunk must keep h1 metadata.")
ASSERT($case1[0].metadata.h2="Bar"; "Markdown header case 1 first chunk must keep h2 metadata.")
ASSERT($case1[1].text="Hi this is Molly"; "Markdown header case 1 second chunk text mismatch.")
ASSERT($case1[1].metadata.h1="Foo"; "Markdown header case 1 second chunk must keep h1 metadata.")
ASSERT($case1[1].metadata.h2="Baz"; "Markdown header case 1 second chunk must keep h2 metadata.")

var $case2Document : Text:="# Foo"+$lf+$lf+\
"    ## Bar"+$lf+$lf+\
"Hi this is Jim"+$lf+$lf+\
"Hi this is Joe"+$lf+$lf+\
" ### Boo "+$lf+$lf+\
" Hi this is Lance "+$lf+$lf+\
" ## Baz"+$lf+$lf+\
" Hi this is Molly"
var $case2:=$splitter.splitText($case2Document; {chunkSize: 500; chunkOverlap: 0; headingLevels: [1; 2; 3]})
ASSERT($case2.length=3; "Markdown header case 2 must produce three chunks.")
ASSERT($case2[0].text=("Hi this is Jim"+$lf+$lf+"Hi this is Joe"); "Markdown header case 2 first chunk text mismatch.")
ASSERT($case2[0].metadata.h1="Foo"; "Markdown header case 2 first chunk must keep h1 metadata.")
ASSERT($case2[0].metadata.h2="Bar"; "Markdown header case 2 first chunk must keep h2 metadata.")
ASSERT($case2[1].text="Hi this is Lance"; "Markdown header case 2 second chunk text mismatch.")
ASSERT($case2[1].metadata.h1="Foo"; "Markdown header case 2 second chunk must keep h1 metadata.")
ASSERT($case2[1].metadata.h2="Bar"; "Markdown header case 2 second chunk must keep h2 metadata.")
ASSERT($case2[1].metadata.h3="Boo"; "Markdown header case 2 second chunk must keep h3 metadata.")
ASSERT($case2[2].text="Hi this is Molly"; "Markdown header case 2 third chunk text mismatch.")
ASSERT($case2[2].metadata.h1="Foo"; "Markdown header case 2 third chunk must keep h1 metadata.")
ASSERT($case2[2].metadata.h2="Baz"; "Markdown header case 2 third chunk must keep h2 metadata.")

var $case3Document : Text:="# Foo"+$lf+$lf+\
"    ## Bar"+$lf+$lf+\
"Hi this is Jim"+$lf+$lf+\
"Hi this is Joe"+$lf+$lf+\
" ### Boo "+$lf+$lf+\
" Hi this is Lance "+$lf+$lf+\
" #### Bim "+$lf+$lf+\
" Hi this is John "+$lf+$lf+\
" ## Baz"+$lf+$lf+\
" Hi this is Molly"
var $case3:=$splitter.splitText($case3Document; {chunkSize: 500; chunkOverlap: 0; headingLevels: [1; 2; 3; 4]})
ASSERT($case3.length=4; "Markdown header case 3 must produce four chunks.")
ASSERT($case3[0].text=("Hi this is Jim"+$lf+$lf+"Hi this is Joe"); "Markdown header case 3 first chunk text mismatch.")
ASSERT($case3[0].metadata.h1="Foo"; "Markdown header case 3 first chunk must keep h1 metadata.")
ASSERT($case3[0].metadata.h2="Bar"; "Markdown header case 3 first chunk must keep h2 metadata.")
ASSERT($case3[1].text="Hi this is Lance"; "Markdown header case 3 second chunk text mismatch.")
ASSERT($case3[1].metadata.h1="Foo"; "Markdown header case 3 second chunk must keep h1 metadata.")
ASSERT($case3[1].metadata.h2="Bar"; "Markdown header case 3 second chunk must keep h2 metadata.")
ASSERT($case3[1].metadata.h3="Boo"; "Markdown header case 3 second chunk must keep h3 metadata.")
ASSERT($case3[2].text="Hi this is John"; "Markdown header case 3 third chunk text mismatch.")
ASSERT($case3[2].metadata.h1="Foo"; "Markdown header case 3 third chunk must keep h1 metadata.")
ASSERT($case3[2].metadata.h2="Bar"; "Markdown header case 3 third chunk must keep h2 metadata.")
ASSERT($case3[2].metadata.h3="Boo"; "Markdown header case 3 third chunk must keep h3 metadata.")
ASSERT($case3[2].metadata.h4="Bim"; "Markdown header case 3 third chunk must keep h4 metadata.")
ASSERT($case3[3].text="Hi this is Molly"; "Markdown header case 3 fourth chunk text mismatch.")
ASSERT($case3[3].metadata.h1="Foo"; "Markdown header case 3 fourth chunk must keep h1 metadata.")
ASSERT($case3[3].metadata.h2="Baz"; "Markdown header case 3 fourth chunk must keep h2 metadata.")

var $preserve1Document : Text:="# Foo"+$lf+$lf+\
"    ## Bat"+$lf+$lf+\
"Hi this is Jim"+$lf+$lf+\
"Hi Joe"+$lf+$lf+\
"## Baz"+$lf+$lf+\
"# Bar"+$lf+$lf+\
"This is Alice"+$lf+$lf+\
"This is Bob"
var $preserve1:=$splitter.splitText($preserve1Document; {stripHeaders: False; headingLevels: [1]; chunkSize: 500; chunkOverlap: 0})
ASSERT($preserve1.length=2; "Preserve-headers case 1 must produce two top-level chunks.")
ASSERT($preserve1[0].text=("# Foo"+$lf+$lf+"    ## Bat"+$lf+$lf+"Hi this is Jim"+$lf+$lf+"Hi Joe"+$lf+$lf+"## Baz"); "Preserve-headers case 1 first chunk text mismatch.")
ASSERT($preserve1[0].metadata.h1="Foo"; "Preserve-headers case 1 first chunk must keep only h1 metadata.")
ASSERT($preserve1[1].text=("# Bar"+$lf+$lf+"This is Alice"+$lf+$lf+"This is Bob"); "Preserve-headers case 1 second chunk text mismatch.")
ASSERT($preserve1[1].metadata.h1="Bar"; "Preserve-headers case 1 second chunk must keep only h1 metadata.")

var $preserve2Document : Text:="# Foo"+$lf+$lf+\
"    ## Bar"+$lf+$lf+\
"Hi this is Jim"+$lf+$lf+\
"Hi this is Joe"+$lf+$lf+\
"### Boo "+$lf+$lf+\
"Hi this is Lance"+$lf+$lf+\
"## Baz"+$lf+$lf+\
"Hi this is Molly"+$lf+\
"    ## Buz"+$lf+\
"# Bop"
var $preserve2:=$splitter.splitText($preserve2Document; {stripHeaders: False; headingLevels: [1; 2; 3]; chunkSize: 500; chunkOverlap: 0})
ASSERT($preserve2.length=5; "Preserve-headers case 2 must produce five chunks.")
ASSERT($preserve2[0].text=("# Foo"+$lf+$lf+"    ## Bar"+$lf+$lf+"Hi this is Jim"+$lf+$lf+"Hi this is Joe"); "Preserve-headers case 2 first chunk text mismatch.")
ASSERT($preserve2[0].metadata.h1="Foo"; "Preserve-headers case 2 first chunk must keep h1 metadata.")
ASSERT($preserve2[0].metadata.h2="Bar"; "Preserve-headers case 2 first chunk must keep h2 metadata.")
ASSERT($preserve2[1].text=("### Boo "+$lf+$lf+"Hi this is Lance"); "Preserve-headers case 2 second chunk text mismatch.")
ASSERT($preserve2[1].metadata.h1="Foo"; "Preserve-headers case 2 second chunk must keep h1 metadata.")
ASSERT($preserve2[1].metadata.h2="Bar"; "Preserve-headers case 2 second chunk must keep h2 metadata.")
ASSERT($preserve2[1].metadata.h3="Boo"; "Preserve-headers case 2 second chunk must keep h3 metadata.")
ASSERT($preserve2[2].text=("## Baz"+$lf+$lf+"Hi this is Molly"); "Preserve-headers case 2 third chunk text mismatch.")
ASSERT($preserve2[2].metadata.h1="Foo"; "Preserve-headers case 2 third chunk must keep h1 metadata.")
ASSERT($preserve2[2].metadata.h2="Baz"; "Preserve-headers case 2 third chunk must keep h2 metadata.")
ASSERT($preserve2[3].text="## Buz"; "Preserve-headers case 2 fourth chunk text mismatch.")
ASSERT($preserve2[3].metadata.h1="Foo"; "Preserve-headers case 2 fourth chunk must keep h1 metadata.")
ASSERT($preserve2[3].metadata.h2="Buz"; "Preserve-headers case 2 fourth chunk must keep h2 metadata.")
ASSERT($preserve2[4].text="# Bop"; "Preserve-headers case 2 fifth chunk text mismatch.")
ASSERT($preserve2[4].metadata.h1="Bop"; "Preserve-headers case 2 fifth chunk must keep h1 metadata.")

var $recursiveMarkdown : Text:="# Foo"+$lf+$lf+\
"## Bar"+$lf+$lf+\
"Alpha paragraph."+$lf+$lf+\
"```4d"+$lf+\
"# Not a header"+$lf+\
"```"+$lf+$lf+\
"### Baz"+$lf+$lf+\
"Gamma Gamma Gamma Gamma Gamma Gamma Gamma Gamma Gamma Gamma"
var $recursiveChunks:=$splitter.splitText($recursiveMarkdown; {chunkSize: 45; chunkOverlap: 5})
ASSERT($recursiveChunks.length>=3; "Oversized markdown sections must recurse into multiple chunks.")
ASSERT($recursiveChunks[0].metadata.h1="Foo"; "Recursive markdown chunks must keep h1 metadata.")
ASSERT($recursiveChunks[0].metadata.h2="Bar"; "Recursive markdown chunks must keep h2 metadata.")
ASSERT(Position("# Not a header"; JSON Stringify($recursiveChunks))>0; "Fenced code blocks must keep non-heading lines as content.")

var $hasLevel3 : Boolean:=False
var $recursiveChunk : Object
For each ($recursiveChunk; $recursiveChunks)
	If ($recursiveChunk.metadata#Null)
		If (($recursiveChunk.metadata.h3#Null) & ($recursiveChunk.metadata.h3="Baz"))
			$hasLevel3:=True
		End if
	End if
End for each
ASSERT($hasLevel3; "Recursive markdown splitting must preserve nested h3 metadata.")

var $withInvisible : Text:=Char(65279)+"# Foo"+$lf+$lf+"foo()"+$lf+Char(65279)+"## Bar"+$lf+$lf+"bar()"
var $invisibleChunks:=$splitter.splitText($withInvisible; {chunkSize: 100; chunkOverlap: 0})
ASSERT($invisibleChunks.length=2; "Invisible leading characters must not break markdown heading detection.")
ASSERT($invisibleChunks[0].metadata.h1="Foo"; "Invisible characters must be ignored for level 1 headings.")
ASSERT($invisibleChunks[1].metadata.h2="Bar"; "Invisible characters must be ignored for nested headings.")

var $interleavedFence : Text:="# Header"+$lf+$lf+"```"+$lf+"foo"+$lf+"# Not a header"+$lf+"~~~"+$lf+"# Still not a header"+$lf+"```"
var $fencedChunks:=$splitter.splitText($interleavedFence; {chunkSize: 200; chunkOverlap: 0})
ASSERT($fencedChunks.length=1; "Interleaved fenced content must stay in a single markdown section.")
ASSERT(Position("# Still not a header"; $fencedChunks[0].text)>0; "Fence markers inside an open block must not create markdown headers.")
