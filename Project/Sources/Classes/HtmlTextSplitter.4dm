// HtmlTextSplitter
// Recursive splitter preconfigured with HTML-oriented tag separators.
Class extends TextSplitter

// Split HTML or markup-like text using common structural tag boundaries first.
Function splitText($html : Text; $options : Object) : Collection
	var $utils:=cs.Utils.me
	var $recursive:=cs.RecursiveTextSplitter.new()
	var $localOptions : Object:=($options#Null) ? $utils.copyObject($options) : {}
	$localOptions.separators:=$utils.separatorsForFormat("html")
	return $recursive.splitText($html; $localOptions)
	