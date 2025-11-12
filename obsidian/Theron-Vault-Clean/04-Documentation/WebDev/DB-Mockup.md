MapsGlobal
[
	Id:
	OriginWadId:
	History: New String
	
	PictureList()
	{
		MapPicture:
			[
				Id: New id
				Description: New String
			]
	}
	OtherWadsUsed()
	LeagueMapStats()
	TotalMapStats()
]

WadsGlobal
[
	Id:
	WadName:
	LeaguesUsed: (SeasonId.SeasonWadId)
	MapsUsed: (SeasonId.GlobalMapId)
		function MapsInLeague()
		[
			(for each SeasonId.MatchId.MapId.GlobalMapId)
			Id: (GlobalMapId)
			MapName New String
			WadName (WadID:WadName)
			SeasonsUsed (GlobalMapId.SeasonsUsedNum)
		]
]

Priv/Duel


(Rivals/Redemption)
Leagues
- Id (LeagueTypeId, 0 = null, 1 = rivals, 2 = ctf)
- Seasons
	[
	RivalsSeasons
		- Id
		- SeasonName
		- SeasonWad(SeasonWadId)
		- Players
		- Matches(RivalMatchId)
			[
				
			
	RedemptionSeasons
		- Id
		- GameModeId: 0(CTF)
		- SeasonName
		- SeasonWad(SeasonWadId)
			SeasonWad
			[
				Id NewID
				DateReleased NewDATE
				GameModeId: 0(CTF, 1 = Duel)
				SeasonsUsed: Accumulate(Seasons.SeasonWadId)
				MapList: (SeasonWadId.MapNumId)
					function SeasonWadMaplist()
						[
							MapNumId: new id
							GlobalId: (MapsGlobal.Id)
							GlobalMapName: (MapsGlobal.Id.Name)
							GlobalMapNum: (MapsGlobal.Id.MapNum)
							GlobalWad: (MapsGlobal.Id.WadId)
							Link: (MapsGlobal.Id.Link)
						]
				MapsUsedList: (SeasonWadId:MapList:Id)
					function SeasonUsedMapList()
					{
						Id: (WadGlobalId:MapId)
						MapName: MapId (WadGlobalId:MapName)
						MapWad: WadId(WadGlobalId:WadName)
					}

			]
			
			[
				SeasonWadId:
				Maps:
					[
						Id: (MapGlobalId)
						WadName: (SeasonWadId:SeasonWadName)
						MapId: (SeasonWadId:SeasonMapId)
						MapName: (MapGlobalId:MapName)
						WadName: (MapGlobalId:WadNameId)
						TimesPlayed: (MapGlobalId:MapGlobalPlayed)
						SeasonsAppeared: (MapGlobalId:SeasonsUsed)
					]
			]
		- SeasonMapsPlayed(
			[
				Id:
				Name:
				Maps
			]
		- LeagueTypeId
		- Matches(RedemptionMatchId)
			[
			- Id
			- Type(MatchTypeId0=Week,1=Playoff,2=Semi,3=Finals)
			- MatchName
			- MatchLabel(MatchTypeId)
			- MatchMapName(
			- MatchWad
			- MatchMapNum
			- DatePlayed
			- Result
			- BlueTeam(TeamId)
			- RedTeam(TeamId)
			- Rounds(RedemptionRoundId)
				[
				- Id
				- RoundNum (0,1,2)
				- BlueId(TeamId)
				- RedId(TeamId)
					- Id
					- Pts
					- Caps
					- PCaps
					- Touches
					- Ptouches
					- Assists
					- FlagDefs

							]
						- Frags
						- Deaths
						- Suicides
						- KDR
						- DMG
						- Powerups
						- RATING
					]
				]
			- Teams
				[
					- Id
					- Name
					- InitialRoster
					- Roster
						[
							- Id
							- Captain(PlayerId)
							- Second_Player(PlayerId)
							- Third_Player(PlayerId)
							- Fourt_Player(PlayerId)
						]
					- Trades(Old_PlayerId, New_PlayerId)
						[
							- TradeId
							- Previous_Players(PlayerId)
							- New_Player(PlayerId)
						]
					- Matches
				]
	]
	
	]
- Teams(LeagueId/SeasonId/TeamId)
	[
		- Id
		- LeagueId
		- SeasonId
	]
		
Teams
	- Id
	- Name
	
	
	- Draft
		[
			- First_Pick(UserId)
			- Second_Pick(UserId)
			- Third_Pick(UserId)
			- Fourth_Pick(UserId)
		]