// LatexTextSplitter
// Recursive splitter preconfigured with LaTeX section and environment separators.
Class extends TextSplitter

// Split LaTeX source using section markers, environments, and math delimiters first.
Function splitText($latex : Text; $options : Object) : Collection
	var $utils:=cs.Utils.me
	var $recursive:=cs.RecursiveTextSplitter.new()
	var $localOptions : Object:=($options#Null) ? $utils.copyObject($options) : {}
	$localOptions.separators:=$utils.separatorsForFormat("latex")
	return $recursive.splitText($latex; $localOptions)
	