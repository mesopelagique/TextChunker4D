Function importMarkdownText($sourceText : Text; $sourceName : Text; $options : Object) : Object
	return This._importTextForType($sourceText; $sourceName; "markdown"; $options)
	
Function importMarkdownFile($file : 4D.File; $options : Object) : Object
	return This._importFileForType($file; "markdown"; $options)
	
Function importFourDCodeText($sourceText : Text; $sourceName : Text; $options : Object) : Object
	return This._importTextForType($sourceText; $sourceName; "4dcode"; $options)
	
Function importFourDCodeFile($file : 4D.File; $options : Object) : Object
	return This._importFileForType($file; "4dcode"; $options)
	
Function importFile($file : 4D.File; $options : Object) : Object
	var $utils:=cs.textChunker.Utils.me
	var $source:=$utils.readTextFile($file; $options)
	var $sourceType : Text:=This._resolveFileSourceType($file; $options)
	ASSERT(Length($sourceType)>0; "Unsupported file extension for '"+String($source.sourceName)+"'.")
	return This._importTextForType($source.text; $source.sourceName; $sourceType; $options)
	
Function importFolder($folder : 4D.Folder; $options : Object) : Object
	ASSERT($folder#Null; "A 4D.Folder input is required.")
	ASSERT($folder.exists; "Folder not found: "+String($folder.path))
	
	var $recursive : Boolean:=True
	If (($options#Null) & ($options.recursive#Null))
		$recursive:=Bool($options.recursive)
	End if
	
	var $extensions : Collection:=This._effectiveExtensions($options)
	var $files : Collection:=$recursive ? $folder.files(fk recursive) : $folder.files()
	var $documents : Collection:=[]
	var $importedFiles : Collection:=[]
	var $skippedFiles : Collection:=[]
	
	var $file : 4D.File
	For each ($file; $files)
		var $extension : Text:=This._normalizedExtension($file.extension)
		If (Not($extensions.includes($extension)))
			$skippedFiles.push({sourceName: $file.name; path: String($file.path); reason: "filteredExtension"})
		Else 
			Try
				var $document:=This.importFile($file; $options)
				$documents.push($document)
				$importedFiles.push({documentID: $document.ID; title: $document.title; sourceName: $document.sourceName; sourceType: $document.sourceType})
			Catch
				var $lastError : Object:=Last errors.last()
				var $msg : Text:=($lastError#Null) ? String($lastError.message) : "Unknown import error."
				$skippedFiles.push({sourceName: $file.name; path: String($file.path); reason: $msg})
			End try 
		End if 
	End for each 
	
	return {documents: $documents; importedFiles: $importedFiles; skippedFiles: $skippedFiles; importedCount: $documents.length; skippedCount: $skippedFiles.length; recursive: $recursive; extensions: $extensions}
	
Function _importFileForType($file : 4D.File; $sourceType : Text; $options : Object) : Object
	var $utils:=cs.textChunker.Utils.me
	var $source:=$utils.readTextFile($file; $options)
	return This._importTextForType($source.text; $source.sourceName; $sourceType; $options)
	
Function _importTextForType($sourceText : Text; $sourceName : Text; $sourceType : Text; $options : Object) : Object
	var $utils:=cs.textChunker.Utils.me
	var $safeSourceName : Text:=(Length(String($sourceName))>0) ? String($sourceName) : "inline.txt"
	var $normalizedText : Text:=$utils.normalizeText($sourceText)
	var $chunks : Collection:=This._splitTextForType($normalizedText; $safeSourceName; $sourceType; $options)
	var $document : Object:=ds.Documents.new()
	$document.title:=$utils.titleFromSourceName($safeSourceName)
	$document.sourceType:=$sourceType
	$document.sourceName:=$safeSourceName
	$document.rawText:=$normalizedText
	$document.checksum:=$utils.digest($normalizedText)
	$document.createdAt:=$utils.isoTimestamp()
	$document.save()
	
	var $storedChunks : Collection:=[]
	var $chunk : Object
	For each ($chunk; $chunks)
		var $chunkEntity : Object:=ds.Chunks.new()
		$chunkEntity.documentID:=$document.ID
		$chunkEntity.chunkIndex:=Num($chunk.chunkIndex)
		$chunkEntity.text:=String($chunk.text)
		$chunkEntity.charCount:=Num($chunk.charCount)
		$chunkEntity.startIndex:=Num($chunk.startIndex)
		$chunkEntity.headers:=($chunk.metadata#Null) ? $chunk.metadata : {}
		$chunkEntity.embeddingModel:=""
		$chunkEntity.embedding:=Null
		$chunkEntity.save()
		$storedChunks.push($chunkEntity)
	End for each 
	
	If (($options#Null) & Bool($options.embedNow))
		cs.EmbeddingService.new($options).embedChunks($storedChunks; $options)
	End if 
	
	return $document
	
Function _splitTextForType($sourceText : Text; $sourceName : Text; $sourceType : Text; $options : Object) : Collection
	var $utils:=cs.textChunker.Utils.me
	var $splitOptions : Object:=($options#Null) ? $utils.copyObject($options) : {}
	$splitOptions.sourceName:=$sourceName
	
	Case of 
		: ($sourceType="markdown")
			return cs.textChunker.MarkdownTextSplitter.new().splitText($sourceText; $splitOptions)
		: ($sourceType="4dcode")
			return cs.textChunker.FourDCodeTextSplitter.new().splitText($sourceText; $splitOptions)
		: ($sourceType="python")
			return cs.textChunker.PythonCodeTextSplitter.new().splitText($sourceText; $splitOptions)
		: ($sourceType="html")
			return cs.textChunker.HtmlTextSplitter.new().splitText($sourceText; $splitOptions)
		: ($sourceType="latex")
			return cs.textChunker.LatexTextSplitter.new().splitText($sourceText; $splitOptions)
		: ($sourceType="json")
			return cs.textChunker.RecursiveJsonSplitter.new().splitText($sourceText; $splitOptions)
		: ($sourceType="jsframework")
			return cs.textChunker.JSFrameworkTextSplitter.new().splitText($sourceText; $splitOptions)
		: ($sourceType="text")
			return cs.textChunker.RecursiveTextSplitter.new().splitText($sourceText; $splitOptions)
	End case 
	
	ASSERT(False; "Unsupported source type '"+String($sourceType)+"'.")
	return []
	
Function _effectiveExtensions($options : Object) : Collection
	var $extensions : Collection:=This._defaultExtensions()
	If (($options#Null) & ($options.extensions#Null))
		var $filtered : Collection:=[]
		Case of 
			: (Value type($options.extensions)=Is collection)
				var $extension : Text
				For each ($extension; $options.extensions)
					var $normalized : Text:=This._normalizedExtension($extension)
					If (Length($normalized)>0)
						$filtered.push($normalized)
					End if 
				End for each 
			: (Value type($options.extensions)=Is text)
				var $normalizedText : Text:=This._normalizedExtension(String($options.extensions))
				If (Length($normalizedText)>0)
					$filtered.push($normalizedText)
				End if 
		End case 
		If ($filtered.length>0)
			$extensions:=$filtered
		End if 
	End if 
	return $extensions
	
Function _defaultExtensions() : Collection
	return [".md"; ".markdown"; ".4dm"; ".py"; ".html"; ".htm"; ".tex"; ".json"; ".js"; ".ts"; ".jsx"; ".tsx"; ".vue"; ".svelte"; ".txt"]
	
Function _normalizedExtension($extension : Text) : Text
	var $normalized : Text:=Lowercase(Trim(String($extension)))
	If (Length($normalized)=0)
		return ""
	End if 
	If (Substring($normalized; 1; 1)#".")
		$normalized:="."+$normalized
	End if 
	return $normalized
	
Function _resolveSourceType($sourceName : Text; $options : Object) : Text
	If (($options#Null) & ($options.format#Null))
		var $explicitType : Text:=This._normalizedSourceType($options.format)
		If (Length($explicitType)>0)
			return $explicitType
		End if 
	End if 
	return This._sourceTypeFromExtension(This._extensionFromSourceName($sourceName))
	
Function _extensionFromSourceName($sourceName : Text) : Text
	var $name : Text:=String($sourceName)
	var $lastDot : Integer:=0
	var $cursor : Integer:=1
	
	While ($cursor<=Length($name))
		var $nextDot : Integer:=Position("." ; $name; $cursor)
		If ($nextDot=0)
			$cursor:=Length($name)+1
		Else 
			$lastDot:=$nextDot
			$cursor:=$nextDot+1
		End if 
	End while 
	
	If ($lastDot<=0)
		return ""
	End if 
	return This._normalizedExtension(Substring($name; $lastDot))
	
Function _resolveFileSourceType($file : 4D.File; $options : Object) : Text
	If (($options#Null) & ($options.format#Null))
		var $explicitType : Text:=This._normalizedSourceType($options.format)
		If (Length($explicitType)>0)
			return $explicitType
		End if 
	End if 
	return This._sourceTypeFromExtension(This._normalizedExtension($file.extension))
	
Function _normalizedSourceType($format : Text) : Text
	var $key : Text:=Lowercase(Trim(String($format)))
	Case of 
		: (($key="markdown") | ($key="md"))
			return "markdown"
		: (($key="4d") | ($key="4dcode") | ($key="fourd"))
			return "4dcode"
		: (($key="python") | ($key="py"))
			return "python"
		: (($key="html") | ($key="htm"))
			return "html"
		: (($key="latex") | ($key="tex"))
			return "latex"
		: ($key="json")
			return "json"
		: (($key="javascript") | ($key="typescript") | ($key="jsx") | ($key="tsx") | ($key="js") | ($key="ts") | ($key="jsframework"))
			return "jsframework"
		: (($key="text") | ($key="txt"))
			return "text"
	End case 
	return ""
	
Function _sourceTypeFromExtension($extension : Text) : Text
	Case of 
		: (($extension=".md") | ($extension=".markdown"))
			return "markdown"
		: ($extension=".4dm")
			return "4dcode"
		: ($extension=".py")
			return "python"
		: (($extension=".html") | ($extension=".htm"))
			return "html"
		: ($extension=".tex")
			return "latex"
		: ($extension=".json")
			return "json"
		: (($extension=".js") | ($extension=".ts") | ($extension=".jsx") | ($extension=".tsx") | ($extension=".vue") | ($extension=".svelte"))
			return "jsframework"
		: ($extension=".txt")
			return "text"
	End case 
	return ""
	
