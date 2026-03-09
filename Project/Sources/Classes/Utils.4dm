property whitespace : Collection
property formatSeparators : Object

singleton Class constructor
	This.whitespace:=[Char(9); Char(10); Char(13); " "]
	This.formatSeparators:={}
	This.formatSeparators.html:=["<body"; "<div"; "<p"; "<br"; "<li"; "<h1"; "<h2"; "<h3"; "<h4"; "<h5"; "<h6"; "<span"; "<table"; "<tr"; "<td"; "<th"; "<ul"; "<ol"; "<header"; "<footer"; "<nav"; "<head"; "<style"; "<script"; "<meta"; "<title"; ""]
	This.formatSeparators.js:=["\nexport "; " export "; "\nfunction "; "\nasync function "; " async function "; "\nconst "; "\nlet "; "\nvar "; "\nclass "; " class "; "\nif "; " if "; "\nfor "; " for "; "\nwhile "; " while "; "\nswitch "; " switch "; "\ncase "; " case "; "\ndefault "; " default "; "<>"; "\n\n"; "&&\n"; "||\n"; "\n"; " "; ""]
	This.formatSeparators.latex:=["\n\\\\chapter{"; "\n\\\\section{"; "\n\\\\subsection{"; "\n\\\\subsubsection{"; "\n\\\\begin{enumerate}"; "\n\\\\begin{itemize}"; "\n\\\\begin{description}"; "\n\\\\begin{list}"; "\n\\\\begin{quote}"; "\n\\\\begin{quotation}"; "\n\\\\begin{verse}"; "\n\\\\begin{verbatim}"; "\n\\\\begin{align}"; "$$"; "$"; " "; ""]
	This.formatSeparators.markdown:=["\n#{1,6} "; "```\n"; "\n***\n"; "\n---\n"; "\n___\n"; "\n\n"; "\n"; " "; ""]
	This.formatSeparators.python:=["\nclass "; "\ndef "; "\n\tdef "; "\n\n"; "\n"; " "; ""]
	This.formatSeparators.fourd:=["\nClass extends "; "\nshared singleton Class constructor"; "\nsingleton Class constructor"; "\nClass constructor"; "\nFunction get "; "\nFunction set "; "\nFunction "; "\n#DECLARE"; "\nvar "; "\nIf "; "\nCase of"; "\nFor each "; "\nFor ("; "\nWhile "; "\nRepeat"; "\nTry"; "\n\n"; "\n"; " "; ""]

Function copyObject($source : Object) : Object
	If ($source=Null)
		return {}
	End if

	var $json : Text:=JSON Stringify($source)
	var $copy:=Try(JSON Parse($json; Is object))
	If ($copy=Null)
		return {}
	End if

	return $copy

Function copyCollection($source : Collection) : Collection
	If ($source=Null)
		return []
	End if

	var $json : Text:=JSON Stringify($source)
	var $copy:=Try(JSON Parse($json; Is collection))
	If ($copy=Null)
		return []
	End if

	return $copy

Function mergeOptions($defaults : Object; $overrides : Object) : Object
	var $merged : Object:=This.copyObject($defaults)
	If ($merged=Null)
		$merged:={}
	End if

	If ($overrides=Null)
		return $merged
	End if

	var $key : Text
	For each ($key; $overrides)
		If ($overrides[$key]#Null)
			$merged[$key]:=$overrides[$key]
		End if
	End for each

	return $merged

Function separatorsForFormat($format : Text) : Collection
	var $key : Text:=Lowercase(Trim($format))
	Case of
		: (($key="javascript") | ($key="typescript") | ($key="jsx") | ($key="tsx") | ($key="jsframework"))
			$key:="js"
		: (($key="4d") | ($key="4dcode") | ($key="code4d"))
			$key:="fourd"
		: ($key="py")
			$key:="python"
	End case

	If (($key#"") & (This.formatSeparators[$key]#Null))
		return This.copyCollection(This.formatSeparators[$key])
	End if

	return []

Function jsFrameworkSeparators($text : Text; $customSeparators : Collection) : Collection
	var $separators : Collection:=This.copyCollection($customSeparators)
	$separators.combine(This.separatorsForFormat("js"))

	var $cursor : Integer:=1
	While ($cursor<=Length($text))
		var $lt : Integer:=Position("<"; $text; $cursor)
		If ($lt=0)
			$cursor:=Length($text)+1
		Else
			var $tagStart : Integer:=$lt+1
			While (($tagStart<=Length($text)) & This._isWhitespace(Substring($text; $tagStart; 1)))
				$tagStart:=$tagStart+1
			End while

			var $firstChar : Text:=($tagStart<=Length($text)) ? Substring($text; $tagStart; 1) : ""
			If ((Length($firstChar)=0) | ($firstChar="/") | ($firstChar="!") | ($firstChar="?"))
				$cursor:=$lt+1
			Else
				var $tagEnd : Integer:=$tagStart
				While (($tagEnd<=Length($text)) & This._isTagNameCharacter(Substring($text; $tagEnd; 1)))
					$tagEnd:=$tagEnd+1
				End while

				If ($tagEnd>$tagStart)
					This._appendUniqueText($separators; "<"+Substring($text; $tagStart; $tagEnd-$tagStart))
				End if
				$cursor:=$tagEnd
			End if
		End if
	End while

	return $separators

Function normalizeText($text : Text) : Text
	var $normalized : Text:=String($text)
	$normalized:=Replace string($normalized; Char(13)+Char(10); Char(10))
	$normalized:=Replace string($normalized; Char(13); Char(10))
	return $normalized

Function readTextFile($file : 4D.File; $options : Object) : Object
	ASSERT($file#Null; "A 4D.File input is required.")
	ASSERT($file.exists; "File not found: "+String($file.path))

	var $text : Text:=""
	var $charSetName : Text:=""
	If (($options#Null) & ($options.charSetName#Null))
		$charSetName:=String($options.charSetName)
	End if

	Try
		If (Length($charSetName)>0)
			$text:=$file.getText($charSetName; Document with LF)
		Else
			var $readDefault:=Try($file.getText())
			If ($readDefault#Null)
				$text:=String($readDefault)
			Else
				$text:=$file.getText("UTF-8"; Document with LF)
			End if
		End if
	Catch
		var $msg : Text:="Unable to read file '"+String($file.path)+"': "+Last errors.last().message
		ASSERT(False; $msg)
		$text:=""
	End try

	return {text: This.normalizeText($text); sourceName: $file.name}

Function trimChunk($text : Text; $baseStartIndex : Integer) : Object
	var $startOffset : Integer:=1
	var $endOffset : Integer:=Length($text)

	While (($startOffset<=Length($text)) & This._isWhitespace(Substring($text; $startOffset; 1)))
		$startOffset:=$startOffset+1
	End while

	While (($endOffset>=$startOffset) & This._isWhitespace(Substring($text; $endOffset; 1)))
		$endOffset:=$endOffset-1
	End while

	If ($endOffset<$startOffset)
		return {text: ""; startIndex: $baseStartIndex}
	End if

	return {text: Substring($text; $startOffset; $endOffset-$startOffset+1); startIndex: $baseStartIndex+$startOffset-1}

Function buildChunk($text : Text; $chunkIndex : Integer; $startIndex : Integer; $metadata : Object; $sourceName : Text) : Object
	return {\
		text: $text; \
		chunkIndex: $chunkIndex; \
		startIndex: $startIndex; \
		charCount: Length($text); \
		metadata: This.copyObject($metadata); \
		sourceName: String($sourceName) \
	}

Function renumberChunks($chunks : Collection) : Collection
	var $index : Integer:=0
	var $chunk : Object
	For each ($chunk; $chunks)
		$chunk.chunkIndex:=$index
		$index:=$index+1
	End for each
	return $chunks

Function digest($text : Text) : Text
	return Generate digest($text; SHA256 digest)

Function isoTimestamp() : Text
	return String(Current date; ISO date)+"T"+String(Current time; ISO time)

Function titleFromSourceName($sourceName : Text) : Text
	var $title : Text:=String($sourceName)
	var $lastDot : Integer:=0
	var $searchPos : Integer:=1
	var $nextDot : Integer:=Position("." ; $title; $searchPos)

	While ($nextDot>0)
		$lastDot:=$nextDot
		$searchPos:=$nextDot+1
		$nextDot:=Position("." ; $title; $searchPos)
	End while

	If ($lastDot>1)
		return Substring($title; 1; $lastDot-1)
	End if

	return $title

Function _appendUniqueText($values : Collection; $value : Text)
	If ((Length($value)>0) & (Not($values.includes($value))))
		$values.push($value)
	End if

Function _isTagNameCharacter($char : Text) : Boolean
	If (Length($char)=0)
		return False
	End if
	return Match regex("^[A-Za-z0-9]$"; $char)

Function _isWhitespace($char : Text) : Boolean
	return This.whitespace.includes($char)
