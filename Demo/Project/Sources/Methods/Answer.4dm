//%attributes = {}
#DECLARE($query : Text; $config : Object) : Object

var $options : Object:=($config#Null) ? JSON Parse(JSON Stringify($config); Is object) : {}
If ($options=Null)
	$options:={}
End if

var $service:=cs.RAGService.new($options)
var $topK : Integer:=($options.topK#Null) ? Num($options.topK) : 5
var $threshold : Real:=($options.threshold#Null) ? Num($options.threshold) : 0.75

return $service.answer($query; $topK; $threshold)
