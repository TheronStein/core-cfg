also, I can handle a lot of the map rotation/map lists through ACS/Scripting, so I could have different arrays of maplists that you can manually modify and adjust.

```
GetMapRotationInfo

position: The index into the map rotation. This can be 0 to return the current map (printed in green when the maplist console command is used); otherwise it must be between 1 and the value returned by GetMapRotationSize.

info: One of:

MAPROTATION_Name = 0
The name of the map (e.g. "Entryway").
MAPROTATION_LumpName = 1
The lump name of the map (e.g. "MAP01").
MAPROTATION_Used = 2
Whether or not this map has already been played. Used maps are printed in red when the maplist console command is used.
MAPROTATION_MinPlayers = 3
The minimum number of players required to load this level. If this is 0, then there's no minimum limit.
MAPROTATION_MaxPlayers = 4
The maximum number of players allowed to load this level. If this is 64, then there's no maximum limit.

```

then

```
GetMapRotationSize

Returns the number of map entries that are currently in the map rotation.

```

So I have a lot of control over only using bigger maps when there's a minimum amount of players, or not using smaller maps when it exceeds the maximum amount of players required to load the level.

I can also have you guys adjust separate maplists using a menu like interface that i code up instead of having to do it all through rcon controls.

so I can have like

```

```


```
r_adminpass = "69rontop69" // this allows you to access a custom admin menu for ACS scripts.

Access menu "CurrentMapList" 
options:
1 = Default
2 = Beast
4 = 4v4
6 = 6v6
8 = 8v8
```


You will see the menu print out like this.

```
Server Settings:

Current Map List: Default (Beast/4v4/6v6/8v8)

Changed the value of CurrentMapList to 4v4

Server Settings:

Current Map List: 4v4

this will run the command sv_currentList = 4; //we set the current list to use the list for 4v4 maps.
```

Switching which maplist is being used on the server.

```
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

```

Example of adding a map to a specified maplist.

```

Script "Maplist_AddMap_ToList" (int maplistNum, int addedMapNum)
{
    //Get the Server variable for the maplist
    totalMaps = GetCvar(GetMapSizeCvarString(maplistNum)) + 1;

    //Increase the size total for the map list we're adding onto
    SetCvar(GetMapSizeCvarString(maplistNum), totalMaps);

    //Add the map to the specified maplist.
	AddMapToMaplistArray(maplistNum, totalMaps, addedMapNum);
}

function void AddMapToMaplistArray(int maplistNum, int index, int mapNum)
{
	switch (maplistNum)
	{
		Case 2: 
			BEAST3_MAPLIST[index] = mapNum;
			break;
		Case 4:
			4v4Maps[index] = mapNum;
			break;
		Case 6: 
			6v6Maps[index] = mapNum;
			break;
		Case 8:
			8v8Maps[index] = mapNum;
			break;
	}
	
	return "DEFAULT_MAPLIST";
}
```

```
Script "Determine_Next_Map" (void)
{
	currentMapList  = GetCvar("sv_currentList");
	currentPosition = GetMapRotationInfo(0,1);
	
	for (int i = 0; i < totalMaps; i++)
	{
		str mapToAdd = StrParam(s:"addmap", s:4v4Maps[i]);
		ConsoleCommand(mapToAdd);
	}
}


Script "Determine_Maplist_PlayerCount" (void)
{
	currentMapList = GetCvar("sv_currentList");
	totalMaps = GetCvar(GetMapSizeCvarString(currentMapList));
	currentPosition = GetMapRotationInfo(0,1);
	int maplistIndex;
	
	currentPlayers = GetInGamePlayers();
	
	//get index of current map
	for (int i = 0; i < totalMaps; i++)
	{
		
		str lumpName = GetMapLumpName(currentMapList);
		if (lumpName == currentPosition)
			maplistIndex = i;
			break;
	}
	
	if (!maplistIndex)
		log(s:"maplistIndex not set...");
		maplistIndex = 0;
		
	//look at next map index.
	for (i = mapListIndex; i < totalMaps; i++)
	{
		//Check if used
		
		if (GetMapRotationInfo(i,2))
	}
	
}

function str GetMapLumpName(int mapListNum, int index)
{
	switch (mapListNum)
	{
		Case 2:
			return BEAST3_MAPLIST[index];
		Case 4:
			return 4v4Maps[index];
		Case 6: 
			return 6v6Maps[index];
		Case 8:
			return 8v8Maps[index];
	}
	
	return DEFAULT_MAPLIST[index];
}

function void GetMapRotationPosition(int maplistNum, int index, int mapNum)
{
	switch (sel)
	{
		Case 1:
			DEFAULT_MAPLIST[index] = mapNum;
			break;
		Case 2: 
			BEAST3_MAPLIST[index] = mapNum;
			break;
		Case 4:
			4v4Maps[index] = mapNum;
			break;
		Case 6: 
			6v6Maps[index] = mapNum;
			break;
		Case 8:
			8v8Maps[index] = mapNum;
			break;
	}
	
	return "DEFAULT_MAPLIST";
}
```


InsertMap <Lump name> <Position> [MinPlayers] [MaxPlayers]
InsertMap MAP32 5

```
GetMapRotationInfo

position: The index into the map rotation. This can be 0 to return the current map (printed in green when the maplist console command is used); otherwise it must be between 1 and the value returned by GetMapRotationSize.

info: One of:

MAPROTATION_Name = 0
The name of the map (e.g. "Entryway").
MAPROTATION_LumpName = 1
The lump name of the map (e.g. "MAP01").
MAPROTATION_Used = 2
Whether or not this map has already been played. Used maps are printed in red when the maplist console command is used.
MAPROTATION_MinPlayers = 3
The minimum number of players required to load this level. If this is 0, then there's no minimum limit.
MAPROTATION_MaxPlayers = 4
The maximum number of players allowed to load this level. If this is 64, then there's no maximum limit.

```

then

```
GetMapRotationSize

Returns the number of map entries that are currently in the map rotation.

```

So I have a lot of control over only using bigger maps when there's a minimum amount of players, or not using smaller maps when it exceeds the maximum amount of players required to load the level.

I can also have you guys adjust separate maplists using a menu like interface that i code up instead of having to do it all through rcon controls.

so I can have like

```
int MAX_MAPS 100;

DEFAULT_MAPLIST[MAX_MAPS]; // 1
BEAST3_MAPLIST[MAX_MAPS]; // 2 
4v4Maps[MAX_MAPS]; // 4
6v6Maps[MAX_MAPS]; // 6
8v8Maps[MAX_MAPS]; // 8

(custom variable we set on the server depending on how many maps we put into the 4v4Maps array)
sv_DefaultMapsTotal = 100;
sv_BeastMapsTotal = 20; 
sv_4v4mapsTotal = 20;
sv_6v6MapsTotal = 10;
sv_8v8MapsTotal = 8;
```


```
r_adminpass = "69rontop69" // this allows you to access a custom admin menu for ACS scripts.

Access menu "CurrentMapList" 
options:
1 = Default
2 = Beast
4 = 4v4
6 = 6v6
8 = 8v8
```


You will see the menu print out like this.

```
Server Settings:

Current Map List: Default (Beast/4v4/6v6/8v8)

Changed the value of CurrentMapList to 4v4

Server Settings:

Current Map List: 4v4

this will run the command sv_currentList = 4; //we set the current list to use the list for 4v4 maps.
```

Switching which maplist is being used on the server.

```
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

```

Example of adding a map to a specified maplist.

```

Script "Maplist_AddMap_ToList" (int sel, int addedMapNum)
{
    //Get the Server variable for the maplist
    totalMaps = GetCvar(GetMapSizeCvarString(sel));

    //Increase the size total for the map list we're adding onto
    SetCvar(GetMapSizeCvarString(sel), totalMaps++);

    //Get the array name of the maplist we're adjusting.

    maplist = GetMapListArray();
    GetMapListArray(); 
}

function void GetMapListArray(int sel, int mapNum)
{
	switch (sel)
	{
		Case 1:
			DEFAULT_MAPLIST[totalMaps] = addedMapNum;
                        break;
		Case 2: 
			return "BEAST3_MAPLIST";
		Case 4:
			return "4v4Maps";
		Case 6: 
			return "6v6Maps";
		Case 8:
			return "8v8Maps";
	}
	
	return "DEFAULT_MAPLIST";
}
```
