--There are two functions that will install mods, ServerModSetup and ServerModCollectionSetup. Put the calls to the functions in this file and they will be executed on boot.

--ServerModSetup takes a string of a specific mod's Workshop id. It will download and install the mod to your mod directory on boot.
	--The Workshop id can be found at the end of the url to the mod's Workshop page.
	--Example: http://steamcommunity.com/sharedfiles/filedetails/?id=350811795
	--ServerModSetup("350811795")

--ServerModCollectionSetup takes a string of a specific mod's Workshop id. It will download all the mods in the collection and install them to the mod directory on boot.
	--The Workshop id can be found at the end of the url to the collection's Workshop page.
	--Example: http://steamcommunity.com/sharedfiles/filedetails/?id=379114180
	--ServerModCollectionSetup("379114180")
	
--Campfire
ServerModSetup("569043634")

--Chester Family
ServerModSetup("407977022")


--Craftable Gears
ServerModSetup("478005098")

--Show Me (Origin)
ServerModSetup("666155465")

--Display food values
ServerModSetup("347079953")


--Extra Equip Slots
ServerModSetup("2032685784")


--Food Values - Item Tooltips (Server and Client)
ServerModSetup("458940297")


--Personal Chesters
ServerModSetup("463740026")

--Daisy the Pig Princess
ServerModSetup("1383795736")

--Realistic Placement
ServerModSetup("551324730")

--Friendly Flingomatics
ServerModSetup("438293817")

--Global Positions
ServerModSetup("378160973")
