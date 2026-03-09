//%attributes = {}
var $splitter:=cs.RecursiveTextSplitter.new()

var $empty:=$splitter.splitText("" ; {})
ASSERT($empty.length=0; "Empty input must not produce chunks.")

var $chunks:=$splitter.splitText("foo bar baz 123"; {chunkSize: 7; chunkOverlap: 3})
ASSERT($chunks.length=3; "Expected three overlapping chunks.")
ASSERT($chunks[0].text="foo bar"; "First chunk must preserve words.")
ASSERT($chunks[1].text="bar baz"; "Second chunk must overlap on text.")
ASSERT($chunks[2].text="baz 123"; "Third chunk must contain the tail.")
ASSERT($chunks[0].startIndex=0; "First chunk start index must be 0.")

var $longWord:=$splitter.splitText("supercalifragilistic"; {chunkSize: 5; chunkOverlap: 0})
ASSERT($longWord.length=4; "Long tokens must fall back to fixed-length slices.")
ASSERT($longWord[0].text="super"; "First fallback chunk mismatch.")
ASSERT($longWord[3].text="istic"; "Last fallback chunk mismatch.")

var $whitespaceOnly:=$splitter.splitText("   "; {chunkSize: 5; chunkOverlap: 0})
ASSERT($whitespaceOnly.length=0; "Whitespace-only input must not produce empty chunks.")

var $iterative : Text:="Hi."+Char(10)+Char(10)+"I'm Harrison."+Char(10)+Char(10)+"How? Are? You?"+Char(10)+"Okay then f f f f."+Char(10)+"This is a weird text to write, but gotta test the splittingggg some how."+Char(10)+Char(10)+"Bye!"+Char(10)+Char(10)+"-H."
var $iterativeChunks:=$splitter.splitText($iterative; {chunkSize: 10; chunkOverlap: 1})
var $iterativeCount : Integer:=$iterativeChunks.length
ASSERT($iterativeCount>9; "Recursive splitter must keep producing small iterative chunks on mixed text.")
var $firstIterativeText : Text:=String($iterativeChunks[0].text)
ASSERT($firstIterativeText="Hi."; "Iterative recursive split must preserve the first sentence.")
var $lastChunkIndex : Integer:=$iterativeChunks.length-1
var $lastIterativeText : Text:=String($iterativeChunks[$lastChunkIndex].text)
var $expectedTail : Text:="Bye!"+Char(10)+Char(10)+"-H."
ASSERT($lastIterativeText=$expectedTail; "Iterative recursive split must keep the trailing signoff in the final chunk.")
