// PythonCodeTextSplitter
// Recursive splitter preconfigured for Python class and function boundaries.
Class extends TextSplitter

// Split Python code using class and def separators before line and character fallback.
Function splitText($python : Text; $options : Object) : Collection
	var $utils:=cs.Utils.me
	var $recursive:=cs.RecursiveTextSplitter.new()
	var $localOptions : Object:=($options#Null) ? $utils.copyObject($options) : {}
	$localOptions.separators:=$utils.separatorsForFormat("python")
	return $recursive.splitText($python; $localOptions)
	