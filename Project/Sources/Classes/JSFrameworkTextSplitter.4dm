// JSFrameworkTextSplitter
// Recursive splitter for JavaScript, TypeScript, JSX, and TSX sources.
Class extends TextSplitter

// Split JS framework source using code separators plus detected tag openings from the input.
Function splitText($sourceText : Text; $options : Object) : Collection
	var $utils:=cs.Utils.me
	var $recursive:=cs.RecursiveTextSplitter.new()
	var $localOptions : Object:=($options#Null) ? $utils.copyObject($options) : {}
	var $customSeparators : Collection:=[]
	If (($options#Null) & ($options.separators#Null) & ($options.separators.length>0))
		$customSeparators:=$utils.copyCollection($options.separators)
	End if 
	$localOptions.separators:=$utils.jsFrameworkSeparators($sourceText; $customSeparators)
	return $recursive.splitText($sourceText; $localOptions)
	