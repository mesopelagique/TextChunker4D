// RecursiveTextSplitter
// General-purpose recursive splitter with overlap and ordered separator fallback.
Class extends TextSplitter

property defaultChunkSize : Integer
property defaultChunkOverlap : Integer
property defaultSeparators : Collection

// Configure the default chunk size, overlap, and separator priority used by splitText(...).
Class constructor()
	This.defaultChunkSize:=1200
	This.defaultChunkOverlap:=150
	This.defaultSeparators:=["\n\n"; "\n"; " "; ""]
	
	// Split arbitrary text into chunk DTOs using recursive separator fallback.
Function splitText($text : Text; $options : Object) : Collection
	var $normalizedOptions : Object:=This._normalizedOptions($options)
	var $utils:=cs.Utils.me
	var $normalizedText : Text:=$utils.normalizeText($text)
	
	If (Length($normalizedText)=0)
		return []
	End if 
	
	var $chunks:=This._splitInternal($normalizedText; $normalizedOptions; {}; 0)
	return $utils.renumberChunks($chunks)
	
Function _normalizedOptions($options : Object) : Object
	var $chunkSize : Integer:=This.defaultChunkSize
	var $chunkOverlap : Integer:=This.defaultChunkOverlap
	var $separators : Collection:=This.defaultSeparators
	var $sourceName : Text:=""
	
	If ($options#Null)
		If ($options.chunkSize#Null)
			$chunkSize:=Num($options.chunkSize)
		End if 
		If ($options.chunkOverlap#Null)
			$chunkOverlap:=Num($options.chunkOverlap)
		End if 
		If (($options.separators#Null) & ($options.separators.length>0))
			$separators:=$options.separators
		End if 
		If ($options.sourceName#Null)
			$sourceName:=String($options.sourceName)
		End if 
	End if 
	
	If ($chunkSize<=0)
		$chunkSize:=This.defaultChunkSize
	End if 
	If ($chunkOverlap<0)
		$chunkOverlap:=0
	End if 
	If ($chunkOverlap>=$chunkSize)
		$chunkOverlap:=$chunkSize-1
		If ($chunkOverlap<0)
			$chunkOverlap:=0
		End if 
	End if 
	
	return {chunkSize: $chunkSize; chunkOverlap: $chunkOverlap; separators: $separators; sourceName: $sourceName}
	
Function _splitInternal($text : Text; $options : Object; $metadata : Object; $baseStartIndex : Integer) : Collection
	var $utils:=cs.Utils.me
	var $rawChunks : Collection:=This._splitRecursive($text; $options.separators; $options.chunkSize; $options.chunkOverlap)
	var $results : Collection:=[]
	var $chunk : Text
	var $lastFound : Integer:=1
	var $previousChunkLength : Integer:=0
	
	For each ($chunk; $rawChunks)
		var $trimmed : Object:=$utils.trimChunk($chunk; 0)
		If (Length($trimmed.text)>0)
			var $searchStart : Integer:=$lastFound+$previousChunkLength-$options.chunkOverlap
			If ($searchStart<1)
				$searchStart:=1
			End if 
			var $found : Integer:=Position($trimmed.text; $text; $searchStart)
			If ($found=0)
				$found:=Position($trimmed.text; $text)
			End if 
			If ($found=0)
				$found:=1
			End if 
			
			$results.push($utils.buildChunk($trimmed.text; 0; $baseStartIndex+$found-1; $metadata; $options.sourceName))
			$lastFound:=$found
			$previousChunkLength:=Length($trimmed.text)
		End if 
	End for each 
	
	return $results
	
Function _splitRecursive($text : Text; $separators : Collection; $chunkSize : Integer; $chunkOverlap : Integer) : Collection
	If (Length($text)<=$chunkSize)
		return [$text]
	End if 
	
	var $separator : Text:=""
	var $nextSeparators : Collection:=[]
	var $separatorIndex : Integer:=0
	var $i : Integer:=0
	
	For ($i; 0; $separators.length-1)
		var $candidate : Text:=String($separators[$i])
		If (Length($candidate)=0)
			$separator:=""
			$separatorIndex:=$i
			$i:=$separators.length
		Else 
			If (Position($candidate; $text)>0)
				$separator:=$candidate
				$separatorIndex:=$i
				$i:=$separators.length
			End if 
		End if 
	End for 
	
	If (($separatorIndex+1)<$separators.length)
		$nextSeparators:=$separators.slice($separatorIndex+1)
	End if 
	
	If (Length($separator)=0)
		return This._splitByLength($text; $chunkSize)
	End if 
	
	var $pieces : Collection:=Split string($text; $separator)
	var $goodPieces : Collection:=[]
	var $finalChunks : Collection:=[]
	var $piece : Text
	For each ($piece; $pieces)
		If (Length($piece)=0)
			// ignore empty fragments
		Else 
			If (Length($piece)<$chunkSize)
				$goodPieces.push($piece)
			Else 
				If ($goodPieces.length>0)
					$finalChunks.combine(This._mergePieces($goodPieces; $separator; $chunkSize; $chunkOverlap))
					$goodPieces:=[]
				End if 
				
				If ($nextSeparators.length=0)
					$finalChunks.combine(This._splitByLength($piece; $chunkSize))
				Else 
					$finalChunks.combine(This._splitRecursive($piece; $nextSeparators; $chunkSize; $chunkOverlap))
				End if 
			End if 
		End if 
	End for each 
	
	If ($goodPieces.length>0)
		$finalChunks.combine(This._mergePieces($goodPieces; $separator; $chunkSize; $chunkOverlap))
	End if 
	
	return $finalChunks
	
Function _mergePieces($pieces : Collection; $separator : Text; $chunkSize : Integer; $chunkOverlap : Integer) : Collection
	var $separatorLength : Integer:=Length($separator)
	var $docs : Collection:=[]
	var $currentDoc : Collection:=[]
	var $total : Integer:=0
	var $piece : Text
	
	For each ($piece; $pieces)
		var $pieceLength : Integer:=Length($piece)
		If (($total+$pieceLength+(($currentDoc.length>0) ? $separatorLength : 0))>$chunkSize)
			If ($currentDoc.length>0)
				var $joined : Text:=This._joinPieces($currentDoc; $separator)
				If (Length($joined)>0)
					$docs.push($joined)
				End if 
				
				While (($currentDoc.length>0) & (($total>$chunkOverlap) | (($total+$pieceLength+(($currentDoc.length>0) ? $separatorLength : 0))>$chunkSize)))
					$total:=$total-Length(String($currentDoc[0]))
					If ($currentDoc.length>1)
						$total:=$total-$separatorLength
					End if 
					$currentDoc:=$currentDoc.slice(1)
				End while 
			End if 
		End if 
		
		$currentDoc.push($piece)
		$total:=$total+$pieceLength
		If ($currentDoc.length>1)
			$total:=$total+$separatorLength
		End if 
	End for each 
	
	var $finalText : Text:=This._joinPieces($currentDoc; $separator)
	If (Length($finalText)>0)
		$docs.push($finalText)
	End if 
	
	return $docs
	
Function _splitByLength($text : Text; $chunkSize : Integer) : Collection
	var $chunks : Collection:=[]
	var $cursor : Integer:=1
	While ($cursor<=Length($text))
		$chunks.push(Substring($text; $cursor; $chunkSize))
		$cursor:=$cursor+$chunkSize
	End while 
	return $chunks
	
Function _joinPieces($pieces : Collection; $separator : Text) : Text
	return Trim($pieces.join($separator))
	