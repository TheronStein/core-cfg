int currentMapList;

Script "Maplist_Change_List" (int sel)
{
	int totalMaps;

	if (GetCvar("sv_currentList") ==  sel))
	{
	
		totalMaps = GetCvar(GetMapSizeCvarString(sel));
		ConsoleCommand("ClearMaplist");
		
		for (int i = 0; i < totalMaps; i++)
		{
			str mapToAdd = StrParam(s:"addmap", s:4v4Maps[i]);
			ConsoleCommand(mapToAdd);
		}
	}
}

function void GetMapSizeCvarString (int sel)
{
	switch (sel)
	{
		Case 1:
			return "sv_DefaultMapsTotal";
		Case 2: 
			return "sv_BeastMapsTotal ";
		Case 4:
			return "sv_4v4mapsTotal";
		Case 6: 
			return "sv_6v6MapsTotal";
		Case 8:
			return "sv_8v8MapsTotal";
	}
	
	return "sv_DefaultMapsTotal";
}		


