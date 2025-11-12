Column "Points"
{
	AddFlag NOSPECTATORS
	AddFlag ALWAYSUSESHORTESTWIDTH

	Alignment = Right
	EarnType = Points
	GameType = Deathmatch, TeamGame
	ShortName = "Pts"
	Size = 16
}


CompositeColumn "ReadyToGoAndStatusIcons"
{
	AddFlag DONTSHOWHEADER
	AddFlag ALWAYSUSESHORTESTWIDTH

	Columns = "ReadyToGoIcon", "StatusIcon"
	GapBetweenColumns = 4
}

CompositeColumn "Player"
{
	Columns = "PlayerColor", "JoinQueue", "Name"
	GapBetweenColumns = 4
	Size = 200
}


CompositeColumn "Player"
{
	Columns = "PlayerColor", "JoinQueue", "Name"
	GapBetweenColumns = 4
	Size = 200
}

CompositeColumn "Misc"
{
	Columns = "Vote", "Handicap", "Wins"
	GapBetweenColumns = 4
	Size = 48
}

Column "ArtifactIcon"
{
	AddFlag NOINTERMISSION
	AddFlag DONTSHOWHEADER

	Alignment = Center
	ClipRectHeight = -2
	GameMode = Terminator, Possession, TeamPossession, CTF, OneFlagCTF, Skulltag
	Size = 13
}

Column "PlayerIcon"
{
	AddFlag NOSPECTATORS
	AddFlag NOENEMIES
	AddFlag DONTSHOWHEADER
	AddFlag ALWAYSUSESHORTESTWIDTH
	AddFlag DISABLEIFEMPTY

	Alignment = Center
	ClipRectHeight = -2
}

CompositeColumn "ReadyToGoAndStatusIcons"
{
	AddFlag DONTSHOWHEADER
	AddFlag ALWAYSUSESHORTESTWIDTH

	Columns = "ReadyToGoIcon", "StatusIcon"
	GapBetweenColumns = 4
}

CompositeColumn "PlayerInfoIcons"
{
	Columns = "ArtifactIcon", "PlayerIcon", "CountryFlag"
}

CompositColumn "NormalStats"
{
	Columns = "Wins", "Points", "Frags", "Deaths",
}

CompositColumn "NormalStatsPCaps"
{
	Columns = "Wins", "Caps", "PickupCaps", "Frags", "Deaths",
}

CompositColumn "NewStats"
{
	Columns = "Assists", "Touches", "PickupTouches"
}

CompositColumn "NewStatsTouchesAll"
{
	Columns = "Assists", "TouchesAll"
}

ColumnOrder = "BotSkillIcon", "Index", "ReadyToGoAndStatusIcons", "PlayerInfoIcons", "Player", "Misc",

ifCVar( cl_showPCaps == 1)
{
	RemoveFromColumnOrder("NormalStats")
	if cVar( cl_showPTouch == 1)
	{
		RemoveFromColumnOrder("NewStats")
	}
	ifCVar( cl_showPTouch == 0)
	{
		RemoveFromColumnOrder("NewStatsTouchesAll")
	}
	
	AddToColumnOrder
}

AddToColumns(

ColumnOrder = "BotSkillIcon", "Index", "ReadyToGoAndStatusIcons", "PlayerInfoIcons", "Player", "Misc", "Wins", "Points", "Frags", "Deaths", "Assists", "Touches", "PickupTouches", "FlagReturns", "Ping"

 "Damage", "Lives", "Secrets",
 
  "Time", "Ping"
  
  
	AddCustomData = "Caps", "int", 0
  	AddCustomData = "Touches", "int", 0
	AddCustomData = "TouchesAll", "int", 0
	AddCustomData = "PickupTouches", "int", 0
  	AddCustomData = "PickupCaps", "int", 0



CompositeColumn "TouchesPickup"
{
	AddFlag ALWAYSUSESHORTESTWIDTH
	GapBetweenColumns = 4
	Size = 	96
	CVar = cl_showPTouch, 1
	//Add Wins
	Columns = "Touches", "PickupTouches"
}

CompositeColumn "TouchesOnly"
{
	AddFlag ALWAYSUSESHORTESTWIDTH
	Size = 64
	CVar = cl_showPTouch, 0
	//Add Wins
	Columns = "TouchesAll"
}
E2 HoneyComb
V7 HotStuff
E9 Warning Strip
X3 crystla iris
F3 

	Title "LOG IN"

	TextField	"Username",				"menu_authusername"
	TextField	"Password",				"menu_authpassword"
	StaticText	" "
	Command		"Log in",				"menu_login"


yaytso

\c[E0]
