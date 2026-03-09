//%attributes = {}



var $folder:=Folder(fk home folder).folder("Downloads/docs-main/docs/ViewPro")  // https://github.com/4d/docs/tree/main/docs/ViewPro

If (Not(Asserted($folder.exists; "folder must exists")))
	return 
End if 

_resetData()
//ImportFolder($folder; {recursive: True; embedNow: True})
cs.IngestService.new().importFile($folder.file("commands/vp-column-autofit.md"); {embedNow: True})

var $answser:=Answer("How to 4d view pro manage autofit?")