property config : Object

Class constructor($config : Object)
	This.config:=($config#Null) ? $config : {}
	
Function retrieve($query : Text; $topK : Integer; $threshold : Real) : Object
	var $queryVector : 4D.Vector:=This._resolveQueryVector($query)
	var $parameter : Object:={vector: $queryVector; metric: mk cosine; threshold: (($threshold>0) ? $threshold : 0.75)}
	var $selection : Object:=ds.Chunks.query("embedding > :1"; $parameter).orderByFormula(Formula(This.embedding.cosineSimilarity($queryVector)); dk descending)
	var $limit : Integer:=($topK>0) ? $topK : 5
	If ($selection.length>$limit)
		$selection:=$selection.slice(0; $limit)
	End if 
	return $selection
	
Function answer($query : Text; $topK : Integer; $threshold : Real) : Object
	var $matches : Object:=This.retrieve($query; $topK; $threshold)
	var $queryVector : 4D.Vector:=This._resolveQueryVector($query)
	var $matchRows : Collection:=This.matchesToCollection($matches; $queryVector)
	If ($matchRows.length=0)
		return {success: False; answer: ""; matches: []; context: ""; error: "No matching chunks found."}
	End if 
	
	var $context : Text:=This._contextFromMatches($matchRows)
	var $embeddingService:=cs.EmbeddingService.new(This.config)
	var $effectiveConfig : Object:=$embeddingService._effectiveConfig({})
	var $client : cs.AIKit.OpenAI:=$embeddingService._client($effectiveConfig)
	var $messages : Collection:=[\
		{role: "system"; content: "Answer using only the supplied context. If the answer is not present, say that the context does not contain it."}; \
		{role: "user"; content: "Question:\n"+$query+"\n\nContext:\n"+$context}\
		]
	var $result:=$client.chat.completions.create($messages; {model: String($effectiveConfig.chatModel)})
	
	If (Bool($result.success) & ($result.choice#Null) & ($result.choice.message#Null))
		return {success: True; answer: $result.choice.message.text; matches: $matchRows; context: $context; model: String($effectiveConfig.chatModel)}
	End if 
	
	return {success: False; answer: ""; matches: $matchRows; context: $context; error: JSON Stringify($result.errors)}
	
Function matchesToCollection($selection; $queryVector : 4D.Vector) : Collection
	var $rows : Collection:=$selection.toCollection(["ID"; "documentID"; "chunkIndex"; "text"; "charCount"; "startIndex"; "headers"; "embeddingModel"; "embedding"])
	var $row : Object
	For each ($row; $rows)
		var $documentSelection : Object:=ds.Documents.query("ID = :1"; $row.documentID)
		If ($documentSelection.length>0)
			var $document : Object:=$documentSelection.first()
			$row.documentTitle:=String($document.title)
			$row.sourceName:=String($document.sourceName)
		Else 
			$row.documentTitle:=""
			$row.sourceName:=""
		End if 
		
		If (($queryVector#Null) & ($row.embedding#Null))
			$row.similarity:=$row.embedding.cosineSimilarity($queryVector)
		Else 
			$row.similarity:=Null
		End if 
	End for each 
	
	return $rows
	
Function _resolveQueryVector($query : Text) : 4D.Vector
	If (This.config#Null)
		If (This.config.queryVector#Null)
			If (Value type(This.config.queryVector)=Is collection)
				return 4D.Vector.new(This.config.queryVector)
			End if
			
			return This.config.queryVector
		End if 
	End if 
	
	ASSERT(Length($query)>0; "A query text is required when no queryVector is provided.")
	return cs.EmbeddingService.new(This.config).embedQuery($query; This.config)
	
Function _contextFromMatches($matches : Collection) : Text
	var $blocks : Collection:=[]
	var $row : Object
	For each ($row; $matches)
		var $headerParts : Collection:=[]
		var $level : Integer
		For ($level; 1; 4)
			var $key : Text:="h"+String($level)
			If (($row.headers#Null) & ($row.headers[$key]#Null))
				$headerParts.push(String($row.headers[$key]))
			End if 
		End for 
		
		var $prefix : Text:="["+String($row.sourceName)+" #"+String($row.chunkIndex)+"]"
		If ($headerParts.length>0)
			$prefix:=$prefix+" "+$headerParts.join(" > ")
		End if 
		$blocks.push($prefix+Char(10)+String($row.text))
	End for each 
	
	return $blocks.join(Char(10)+Char(10)+"---"+Char(10)+Char(10))
	
