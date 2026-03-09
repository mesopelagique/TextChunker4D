// TextSplitter
// Abstract parent for splitter classes exposing splitText(...) and splitFile(...).

// Override in concrete subclasses to return chunk DTOs for the given text input.
Function splitText($text : Text; $options : Object) : Collection
	ASSERT(False; "splitText must be overridden by a concrete splitter class.")
	return []
	
	// Read a 4D.File once, inject sourceName, then delegate to the subclass splitText(...).
Function splitFile($file : 4D.File; $options : Object) : Collection
	var $utils:=cs.Utils.me
	var $source : Object:=$utils.readTextFile($file; $options)
	var $localOptions : Object:=($options#Null) ? $utils.copyObject($options) : {}
	$localOptions.sourceName:=$source.sourceName
	return This.splitText($source.text; $localOptions)
	