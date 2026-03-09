// FourDCodeTextSplitter
// Recursive splitter preconfigured for 4D class, function, and control-flow boundaries.
Class extends TextSplitter

// Split 4D code using 4D-specific structural separators before generic fallback.
Function splitText($code : Text; $options : Object) : Collection
	var $utils:=cs.Utils.me
	var $recursive:=cs.RecursiveTextSplitter.new()
	var $localOptions : Object:=($options#Null) ? $utils.copyObject($options) : {}
	$localOptions.separators:=$utils.separatorsForFormat("4d")
	return $recursive.splitText($code; $localOptions)
	