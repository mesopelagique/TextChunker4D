//%attributes = {}
var $character:=cs.CharacterTextSplitter.new()
var $characterChunks:=$character.splitText("Alpha"+Char(10)+Char(10)+"Beta"+Char(10)+Char(10)+"Gamma"; {chunkSize: 12; chunkOverlap: 0})
ASSERT($characterChunks.length>=2; "Character splitter must split on the configured separator.")

var $singleWord:=$character.splitText("singleword"; {separator: " "; chunkSize: 20; chunkOverlap: 0})
ASSERT(($singleWord.length=1) & ($singleWord[0].text="singleword"); "Character splitter must keep a single word intact when it fits.")

var $safeOverlap:=$character.splitText("hello"; {separator: " "; chunkSize: 5; chunkOverlap: 5})
ASSERT(($safeOverlap.length=1) & ($safeOverlap[0].text="hello"); "Character splitter must handle chunk overlap equal to chunk size safely.")

var $longCharacter:=$character.splitText("foo bar baz a a"; {separator: " "; chunkSize: 3; chunkOverlap: 1})
ASSERT(JSON Stringify($longCharacter.map(Formula($1.value.text)))=JSON Stringify(["foo"; "bar"; "baz"; "a a"]); "Character splitter must match expected long-word chunk grouping.")

var $shortCharacter:=$character.splitText("a a foo bar baz"; {separator: " "; chunkSize: 3; chunkOverlap: 1})
ASSERT(JSON Stringify($shortCharacter.map(Formula($1.value.text)))=JSON Stringify(["a a"; "foo"; "bar"; "baz"]); "Character splitter must keep leading short chunks together.")

var $pythonCode : Text:="class Greeter:"+Char(10)+"    pass"+Char(10)+Char(10)+"def hello():"+Char(10)+"    return 'hi'"
var $pythonChunks:=cs.PythonCodeTextSplitter.new().splitText($pythonCode; {chunkSize: 24; chunkOverlap: 0})
ASSERT(JSON Stringify($pythonChunks.map(Formula($1.value.text)))=JSON Stringify(["class Greeter:"+Char(10)+"    pass"; "hello():"+Char(10)+"    return 'hi'"]); "Python splitter must split around class and function boundaries.")

var $html : Text:="<body><h1>Title</h1><p>Alpha</p><div>Beta</div></body>"
var $htmlChunks:=cs.HtmlTextSplitter.new().splitText($html; {chunkSize: 18; chunkOverlap: 0})
ASSERT($htmlChunks.length>=2; "HTML splitter must split around common HTML tags.")

var $latex : Text:="\\section{Intro} Alpha beta gamma"+Char(10)+"\\subsection{Details} Delta epsilon"
var $latexChunks:=cs.LatexTextSplitter.new().splitText($latex; {chunkSize: 20; chunkOverlap: 0})
ASSERT($latexChunks.length>=2; "Latex splitter must split around section markers.")

var $jsx : Text:="export default function App() {"+Char(10)+"  return <Layout><Card>Alpha</Card></Layout>"+Char(10)+"}"
var $jsxChunks:=cs.JSFrameworkTextSplitter.new().splitText($jsx; {chunkSize: 30; chunkOverlap: 0})
ASSERT($jsxChunks.length>=2; "JS framework splitter must split around JS and component boundaries.")

var $jsxSplitter:=cs.JSFrameworkTextSplitter.new()
var $firstPass:=$jsxSplitter.splitText($jsx; {chunkSize: 30; chunkOverlap: 0})
var $secondPass:=$jsxSplitter.splitText($jsx; {chunkSize: 30; chunkOverlap: 0})
ASSERT(JSON Stringify($firstPass)=JSON Stringify($secondPass); "JS framework splitText must not mutate separator state between calls.")

var $fourDCode : Text:="Class extends Entity"+Char(10)+Char(10)+"Function get title : Text"+Char(10)+Char(9)+"return \"ok\""+Char(10)+Char(10)+"Function saveDoc($doc : Object)"+Char(10)+Char(9)+"var $value : Text:=\"\""+Char(10)+Char(9)+"If ($doc#Null)"+Char(10)+Char(9)+Char(9)+"return"+Char(10)+Char(9)+"End if"
var $fourDChunks:=cs.FourDCodeTextSplitter.new().splitText($fourDCode; {chunkSize: 28; chunkOverlap: 0})
ASSERT(JSON Stringify($fourDChunks.map(Formula($1.value.text)))=JSON Stringify(["Class extends Entity"; "title : Text"+Char(10)+Char(9)+"return \"ok\""; "saveDoc($doc : Object)"; "var $value : Text:=\"\""; "If ($doc#Null)"+Char(10)+Char(9)+Char(9)+"return"; "End if"]); "4D code splitter must split on 4D-specific structural boundaries.")
