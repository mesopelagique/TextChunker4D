//%attributes = {}
#DECLARE($query : Text; $config : Object) : Collection

var $options : Object:=($config#Null) ? JSON Parse(JSON Stringify($config); Is object) : {}
If ($options=Null)
	$options:={}
End if

var $service:=cs.RAGService.new($options)
var $topK : Integer:=($options.topK#Null) ? Num($options.topK) : 5
var $threshold : Real:=($options.threshold#Null) ? Num($options.threshold) : 0.75
var $matches:=$service.retrieve($query; $topK; $threshold)

return $service.matchesToCollection($matches; $service._resolveQueryVector($query))
