Function computeGreeting($name : Text) : Text
	#DECLARE($name : Text) : Text
	var $safeName : Text:=(Length($name)>0) ? $name : "world"
	return "Hello "+$safeName
