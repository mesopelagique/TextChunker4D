//%attributes = {"invisible":true}
var $tests : Collection:=["test_persistence_import"; "test_folder_import"; "test_rag_retrieval"]
var $results : Collection:=[]

var $testName : Text
For each ($testName; $tests)
	Try
		_resetData
		EXECUTE METHOD($testName)
		$results.push({name: $testName; success: True; errors: []})
	Catch
		$results.push({name: $testName; success: False; errors: Last errors})
	End try
End for each

var $result : Object
For each ($result; $results)
	If ($result.success)
		LOG EVENT(Into system standard outputs; "PASS "+String($result.name); Information message)
	Else 
		LOG EVENT(Into system standard outputs; "FAIL "+String($result.name)+" "+JSON Stringify($result.errors); Error message)
	End if 
End for each

QUIT 4D:C291
