// RecursiveJsonSplitter
// Split JSON into bounded JSON fragments while keeping nested object structure intact.
Class extends TextSplitter

property defaultMaxChunkSize : Integer
property defaultMinChunkSize : Integer

// Initialize default JSON chunk size thresholds.
Class constructor()
	This.defaultMaxChunkSize:=2000
	This.defaultMinChunkSize:=1800
	
	// Split an in-memory JSON object or collection into chunk DTOs.
Function splitObject($jsonData; $options : Object) : Collection
	var $normalizedOptions : Object:=This._normalizedOptions($options)
	var $prepared : Variant:=This._prepareJsonData($jsonData; $normalizedOptions.convertLists)
	var $chunks : Collection:=This._jsonSplit($prepared; []; []; $normalizedOptions)
	return This._objectsToChunks($chunks; $normalizedOptions.sourceName)
	
	// Parse JSON text, then delegate to splitObject(...).
Function splitText($jsonText : Text; $options : Object) : Collection
	ASSERT(Length(String($jsonText))>0; "A JSON text input is required.")
	var $parsed:=Try(JSON Parse($jsonText))
	ASSERT($parsed#Null; "Unable to parse JSON input.")
	return This.splitObject($parsed; $options)
	
Function _normalizedOptions($options : Object) : Object
	var $maxChunkSize : Integer:=This.defaultMaxChunkSize
	var $minChunkSize : Integer:=This.defaultMinChunkSize
	var $convertLists : Boolean:=False
	var $sourceName : Text:=""
	
	If ($options#Null)
		If ($options.maxChunkSize#Null)
			$maxChunkSize:=Num($options.maxChunkSize)
		End if 
		If ($options.minChunkSize#Null)
			$minChunkSize:=Num($options.minChunkSize)
		End if 
		If ($options.convertLists#Null)
			$convertLists:=Bool($options.convertLists)
		End if 
		If ($options.sourceName#Null)
			$sourceName:=String($options.sourceName)
		End if 
	End if 
	
	If ($maxChunkSize<50)
		$maxChunkSize:=50
	End if 
	If ($minChunkSize<=0)
		$minChunkSize:=$maxChunkSize-200
	End if 
	If ($minChunkSize<50)
		$minChunkSize:=50
	End if 
	If ($minChunkSize>$maxChunkSize)
		$minChunkSize:=$maxChunkSize
	End if 
	
	return {maxChunkSize: $maxChunkSize; minChunkSize: $minChunkSize; convertLists: $convertLists; sourceName: $sourceName}
	
Function _prepareJsonData($jsonData; $convertLists : Boolean) : Variant
	Case of 
		: (Value type($jsonData)=Is object)
			If ($convertLists)
				return This._convertNestedLists($jsonData)
			End if 
			return $jsonData
		: (Value type($jsonData)=Is collection)
			If ($convertLists)
				return This._listToObject($jsonData)
			End if 
			return {items: $jsonData}
		Else 
			return {value: $jsonData}
	End case 
	
Function _convertNestedLists($value) : Variant
	Case of 
		: (Value type($value)=Is object)
			var $result : Object:={}
			var $entry : Object
			For each ($entry; OB Entries($value))
				$result[$entry.key]:=This._convertNestedLists($entry.value)
			End for each 
			return $result
		: (Value type($value)=Is collection)
			return This._listToObject($value)
		Else 
			return $value
	End case 
	
Function _listToObject($values : Collection) : Object
	var $result : Object:={}
	var $index : Integer
	For ($index; 0; $values.length-1)
		$result[String($index)]:=This._convertNestedLists($values[$index])
	End for 
	return $result
	
Function _jsonSplit($data; $currentPath : Collection; $chunks : Collection; $options : Object) : Collection
	If ($chunks.length=0)
		$chunks.push({})
	End if 
	
	If (Value type($data)=Is object)
		var $entry : Object
		For each ($entry; OB Entries($data))
			var $newPath : Collection:=cs.Utils.me.copyCollection($currentPath)
			$newPath.push($entry.key)
			
			var $candidate : Object:={}
			$candidate[$entry.key]:=$entry.value
			var $remaining : Integer:=$options.maxChunkSize-This._jsonSize($chunks[$chunks.length-1])
			var $candidateSize : Integer:=This._jsonSize($candidate)
			
			If ($candidateSize<$remaining)
				This._setNestedValue($chunks[$chunks.length-1]; $newPath; $entry.value)
			Else 
				If (This._jsonSize($chunks[$chunks.length-1])>=$options.minChunkSize)
					$chunks.push({})
				End if 
				$chunks:=This._jsonSplit($entry.value; $newPath; $chunks; $options)
			End if 
		End for each 
	Else 
		This._setNestedValue($chunks[$chunks.length-1]; $currentPath; $data)
	End if 
	
	If (($chunks.length>0) & (This._jsonSize($chunks[$chunks.length-1])=2))
		$chunks.remove($chunks.length-1)
	End if 
	
	return $chunks
	
Function _setNestedValue($target : Object; $path : Collection; $value)
	If ($path.length=0)
		return 
	End if 
	
	var $cursor : Object:=$target
	var $index : Integer
	For ($index; 0; $path.length-2)
		var $key : Text:=String($path[$index])
		If ($cursor[$key]=Null)
			$cursor[$key]:={}
		End if 
		$cursor:=$cursor[$key]
	End for 
	
	$cursor[String($path[$path.length-1])]:=$value
	
Function _jsonSize($value) : Integer
	return Length(JSON Stringify($value))
	
Function _objectsToChunks($objects : Collection; $sourceName : Text) : Collection
	var $utils:=cs.Utils.me
	var $results : Collection:=[]
	var $chunkObject : Object
	For each ($chunkObject; $objects)
		var $text : Text:=JSON Stringify($chunkObject)
		If (Length($text)>0)
			$results.push($utils.buildChunk($text; 0; 0; {format: "json"}; $sourceName))
		End if 
	End for each 
	return $utils.renumberChunks($results)
	