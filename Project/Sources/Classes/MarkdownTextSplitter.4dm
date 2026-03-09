// MarkdownTextSplitter
// Split Markdown by heading sections first, then recursively split oversized sections.
Class extends TextSplitter

property defaultStripHeaders : Boolean
property defaultHeadingLevels : Collection

// Initialize default heading behavior for Markdown section detection.
Class constructor()
	This.defaultStripHeaders:=True
	This.defaultHeadingLevels:=[1; 2; 3; 4]
	
	// Split Markdown text into chunks while preserving heading metadata on each result.
Function splitText($markdown : Text; $options : Object) : Collection
	var $utils:=cs.Utils.me
	var $recursive:=cs.RecursiveTextSplitter.new()
	var $recursiveOptions : Object:=$recursive._normalizedOptions($options)
	var $markdownOptions : Object:=This._normalizedOptions($options)
	var $normalizedMarkdown : Text:=$utils.normalizeText($markdown)
	
	If (Length($normalizedMarkdown)=0)
		return []
	End if 
	
	var $sections:=This._splitSections($normalizedMarkdown; $markdownOptions)
	If ($sections.length=0)
		$sections.push({text: $normalizedMarkdown; startIndex: 0; metadata: {}})
	End if 
	
	var $chunks : Collection:=[]
	var $section : Object
	For each ($section; $sections)
		If (Length($section.text)<=$recursiveOptions.chunkSize)
			$chunks.push($utils.buildChunk($section.text; 0; $section.startIndex; $section.metadata; $recursiveOptions.sourceName))
		Else 
			$chunks.combine($recursive._splitInternal($section.text; $recursiveOptions; $section.metadata; $section.startIndex))
		End if 
	End for each 
	
	return $utils.renumberChunks($chunks)
	
Function _normalizedOptions($options : Object) : Object
	var $stripHeaders : Boolean:=This.defaultStripHeaders
	var $headingLevels : Collection:=This.defaultHeadingLevels
	
	If ($options#Null)
		If ($options.stripHeaders#Null)
			$stripHeaders:=Bool($options.stripHeaders)
		End if 
		If (($options.headingLevels#Null) & ($options.headingLevels.length>0))
			$headingLevels:=$options.headingLevels
		End if 
	End if 
	
	return {stripHeaders: $stripHeaders; headingLevels: $headingLevels}
	
Function _splitSections($markdown : Text; $options : Object) : Collection
	var $sections : Collection:=[]
	var $buffer : Collection:=[]
	var $activeHeadings : Object:={}
	var $lineStart : Integer:=1
	var $sectionStart : Integer:=-1
	var $inCodeBlock : Boolean:=False
	var $openingFence : Text:=""
	var $utils:=cs.Utils.me
	
	While ($lineStart<=Length($markdown))
		var $lineEnd : Integer:=Position(Char(10); $markdown; $lineStart)
		var $rawLine : Text
		If ($lineEnd=0)
			$rawLine:=Substring($markdown; $lineStart)
			$lineEnd:=Length($markdown)+1
		Else 
			$rawLine:=Substring($markdown; $lineStart; $lineEnd-$lineStart)
		End if 
		
		var $trimmedLine : Text:=Trim($rawLine)
		var $cleanLine : Text:=Replace string($trimmedLine; Char(65279); "")
		var $isFenceLine : Boolean:=False
		
		If (Not($inCodeBlock))
			If (Position("```"; $cleanLine)=1)
				$inCodeBlock:=True
				$openingFence:="```"
				$isFenceLine:=True
			Else 
				If (Position("~~~"; $cleanLine)=1)
					$inCodeBlock:=True
					$openingFence:="~~~"
					$isFenceLine:=True
				End if 
			End if 
		Else 
			If ((Length($openingFence)>0) & (Position($openingFence; $cleanLine)=1))
				$isFenceLine:=True
				$inCodeBlock:=False
				$openingFence:=""
			End if 
		End if 
		
		var $level : Integer:=0
		If ((Not($isFenceLine)) & (Not($inCodeBlock)))
			$level:=This._headerLevel($cleanLine; $options.headingLevels)
		End if 
		
		If ($level>0)
			var $shouldAppend : Boolean:=$options.stripHeaders
			If (Not($shouldAppend))
				If (This._bufferHasBodyContent($buffer; $options.headingLevels))
					$shouldAppend:=True
				Else 
					var $lastBufferedHeaderLevel : Integer:=This._lastBufferedHeaderLevel($buffer; $options.headingLevels)
					$shouldAppend:=($lastBufferedHeaderLevel>=$level) & ($lastBufferedHeaderLevel>0)
				End if 
			End if 
			
			If ($shouldAppend)
				This._appendSection($sections; $buffer; $activeHeadings; $sectionStart)
				$buffer:=[]
				$sectionStart:=-1
			End if 
			
			var $removeLevel : Integer
			For ($removeLevel; $level; 4)
				OB REMOVE($activeHeadings; "h"+String($removeLevel))
			End for 
			$activeHeadings["h"+String($level)]:=This._headerText($cleanLine; $level)
			
			If (Not($options.stripHeaders))
				$buffer.push($rawLine)
				$sectionStart:=$lineStart-1
			End if 
		Else 
			If (($sectionStart<0) & (($trimmedLine#"") | $isFenceLine | $inCodeBlock))
				$sectionStart:=$lineStart-1
			End if 
			
			If (($buffer.length>0) | ($trimmedLine#"") | $isFenceLine | $inCodeBlock)
				$buffer.push($rawLine)
			End if 
		End if 
		
		$lineStart:=$lineEnd+1
	End while 
	
	This._appendSection($sections; $buffer; $activeHeadings; $sectionStart)
	
	return $sections
	
Function _appendSection($sections : Collection; $buffer : Collection; $metadata : Object; $sectionStart : Integer)
	If (($buffer=Null) | ($buffer.length=0) | ($sectionStart<0))
		return 
	End if 
	
	var $utils:=cs.Utils.me
	var $joined : Text:=$buffer.join(Char(10))
	var $trimmed:=$utils.trimChunk($joined; $sectionStart)
	If (Length($trimmed.text)>0)
		$sections.push({text: $trimmed.text; startIndex: $trimmed.startIndex; metadata: $utils.copyObject($metadata)})
	End if 
	
Function _bufferHasBodyContent($buffer : Collection; $headingLevels : Collection) : Boolean
	If (($buffer=Null) | ($buffer.length=0))
		return False
	End if 
	
	var $line : Text
	For each ($line; $buffer)
		var $trimmedLine : Text:=Trim($line)
		If (Length($trimmedLine)>0)
			If (This._headerLevel($trimmedLine; $headingLevels)=0)
				return True
			End if 
		End if 
	End for each 
	
	return False
	
Function _lastBufferedHeaderLevel($buffer : Collection; $headingLevels : Collection) : Integer
	If (($buffer=Null) | ($buffer.length=0))
		return 0
	End if 
	
	var $index : Integer:=$buffer.length-1
	While ($index>=0)
		var $trimmedLine : Text:=Trim($buffer[$index])
		var $level : Integer:=This._headerLevel($trimmedLine; $headingLevels)
		If ($level>0)
			return $level
		End if 
		$index:=$index-1
	End while 
	
	return 0
	
Function _headerLevel($line : Text; $headingLevels : Collection) : Integer
	If (This._headingLevelsInclude($headingLevels; 4) & This._matchesHeader($line; "####"))
		return 4
	End if 
	If (This._headingLevelsInclude($headingLevels; 3) & This._matchesHeader($line; "###"))
		return 3
	End if 
	If (This._headingLevelsInclude($headingLevels; 2) & This._matchesHeader($line; "##"))
		return 2
	End if 
	If (This._headingLevelsInclude($headingLevels; 1) & This._matchesHeader($line; "#"))
		return 1
	End if 
	return 0
	
Function _headingLevelsInclude($headingLevels : Collection; $level : Integer) : Boolean
	If ($headingLevels=Null)
		return False
	End if 
	
	var $candidate : Integer
	For each ($candidate; $headingLevels)
		If ($candidate=$level)
			return True
		End if 
	End for each 
	
	return False
	
Function _matchesHeader($line : Text; $prefix : Text) : Boolean
	If (Position($prefix; $line)#1)
		return False
	End if 
	
	If (Length($line)=Length($prefix))
		return True
	End if 
	
	return Substring($line; Length($prefix)+1; 1)=" "
	
Function _headerText($line : Text; $level : Integer) : Text
	return Trim(Substring($line; $level+1))
	