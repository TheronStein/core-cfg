OptionMenu Rampage_Admin
{
	Title 		"Rampage Admin Options"
	StaticText 	""
	StaticText "Test Functions"
	StaticText ""
	Control "Test Data",				"Rampage_Test_Data"
	StaticText ""
	StaticText ""
	StaticText 	"Rampage Maplist Configuration"
	StaticText 	""
	Submenu "Maplist Configuration", 		"Rampage_Maplist_Setup"
	Submenu "Map Configuration", 		"Rampage_Map_Setup"
	StaticText ""
	StaticText "Exwiz and Nexus suck dick at ctf",1
}

OptionMenu Rampage_Maplist_Setup
{
	Title 		"Rampage Maplist Configuration"
	Option  "Maplist: ", "sv_currentMaplist", "MapList"
	
	TextField "Maplist Name: ", "sv_maplistName", "MapList_Name"
	StaticText ""
	StaticText "Exwiz and Nexus suck dick at ctf",1
}

OptionString MapList_Name {
	0, "$MAPLIST_DEFNAME",
	1, "$MAPLIST_NAME1",
	2, "$MAPLIST_NAME2", 
	3, "$MAPLIST_NAME3", 
	4, "$MAPLIST_NAME4",
	5, "$MAPLIST_NAME5"
}

OptionValue "MapList"
{
	0, "Default", 
	1, "Custom Maplist 1", 
	2, "Custom Maplist 2", 
	3, "Custom Maplist 3", 
	4, "Custom Maplist 4",
	5, "Custom Maplist 5",
}


  "Kills", "Damage", 
"CapsOnly", "CapsWithPickup", "Frags", "Deaths", "Assists", "TouchesOnly", "TouchesPickup", "FlagReturns", "Time", "Ping"


CompositeColumn "CapsOnly"
{
	AddFlag ALWAYSUSESHORTESTWIDTH
	GapBetweenColumns = 4
	CVar = cl_showPCap, 0
	Size = 96
	//Add Wins
	Columns = 
}

CompositeColumn "CapsWithPickup"
{
	AddFlag ALWAYSUSESHORTESTWIDTH
	GapBetweenColumns = 4
	
	Size = 128
	//Add Wins
	Columns = "Points", "Caps", "PickupCaps"
}