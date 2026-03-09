// CharacterTextSplitter
// Single-separator splitter that falls back to fixed-length splitting when needed.
Class extends TextSplitter

property defaultSeparator : Text

// Set the preferred top-level separator used before character fallback.
Class constructor()
	This.defaultSeparator:=Char(10)+Char(10)
	
	// Split text using one preferred separator, then recurse down to character slices.
Function splitText($text : Text; $options : Object) : Collection
	var $utils:=cs.Utils.me
	var $recursive:=cs.RecursiveTextSplitter.new()
	var $localOptions : Object:=($options#Null) ? $utils.copyObject($options) : {}
	var $separator : Text:=This.defaultSeparator
	If (($options#Null) & ($options.separator#Null))
		$separator:=String($options.separator)
	End if 
	$localOptions.separators:=[$separator; ""]
	return $recursive.splitText($text; $localOptions)
	