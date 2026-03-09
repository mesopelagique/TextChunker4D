property config : Object

Class constructor($config : Object)
	This.config:=($config#Null) ? $config : {}
	
Function embedChunks($chunks : Collection; $config : Object) : Collection
	var $effectiveConfig:=This._effectiveConfig($config)
	var $texts : Collection:=[]
	var $chunk : Object
	For each ($chunk; $chunks)
		If (Length(String($chunk.text))>0)
			$texts.push(String($chunk.text))
		End if 
	End for each 
	
	If ($texts.length=0)
		return []
	End if 
	
	var $client : cs.AIKit.OpenAI:=This._client($effectiveConfig)
	var $model : Text:=String($effectiveConfig.embeddingModel)
	var $payload : Variant:=($texts.length=1) ? $texts[0] : $texts
	var $result:=$client.embeddings.create($payload; $model; {})
	ASSERT(Bool($result.success); "Unable to create embeddings: "+JSON Stringify($result))
	
	var $updated : Collection:=[]
	var $i : Integer
	var $lastChunkIndex : Integer:=$chunks.length-1
	var $lastEmbeddingIndex : Integer:=$result.embeddings.length-1
	var $lastIndex : Integer:=($lastChunkIndex<$lastEmbeddingIndex) ? $lastChunkIndex : $lastEmbeddingIndex
	For ($i; 0; $lastIndex)
		$chunk:=$chunks[$i]
		var $vector : 4D.Vector:=$result.embeddings[$i].embedding
		$chunk.embeddingModel:=$model
		$chunk.embedding:=$vector
		Try
			$chunk.save()
		Catch
			// Plain objects do not persist.
		End try
		$updated.push($chunk)
	End for 
	
	return $updated
	
Function embedQuery($query : Text; $config : Object) : 4D.Vector
	var $effectiveConfig:=This._effectiveConfig($config)
	var $client : cs.AIKit.OpenAI:=This._client($effectiveConfig)
	var $model : Text:=String($effectiveConfig.embeddingModel)
	var $result:=$client.embeddings.create($query; $model; {})
	ASSERT(Bool($result.success); "Unable to create query embedding: "+JSON Stringify($result))
	return $result.embedding.embedding
	
Function _effectiveConfig($config : Object) : Object
	var $utils:=cs.textChunker.Utils.me
	var $defaults : Object:={embeddingModel: "text-embedding-3-small"; chatModel: "gpt-4o-mini"; apiKey: ""; baseURL: ""}
	If (Folder(fk home folder).file(".openai").exists)
		$defaults.apiKey:=Folder(fk home folder).file(".openai").getText()
	End if 
	// TODO: use APIPRoviders to get openai client when available
	var $merged : Object:=$utils.mergeOptions($defaults; This.config)
	return $utils.mergeOptions($merged; $config)
	
Function _client($config : Object) : cs.AIKit.OpenAI
	var $clientConfig : Object:={}
	If (Length(String($config.apiKey))>0)
		$clientConfig.apiKey:=String($config.apiKey)
	End if 
	If (Length(String($config.baseURL))>0)
		$clientConfig.baseURL:=String($config.baseURL)
	End if 
	
	If (OB Is defined($clientConfig; "apiKey") | OB Is defined($clientConfig; "baseURL"))
		return cs.AIKit.OpenAI.new($clientConfig)
	End if 
	
	return cs.AIKit.OpenAI.new()
	
	
