
DeriveGamemode( "base" )

GM.Name 	= "Battle Mages"
GM.Author 	= "Fortune"
GM.Email 	= ""
GM.Website 	= ""

TEAM_ANGEL = 1
TEAM_DEMON = 2

ROUND_WAITING = 0
ROUND_PREPARING = 1
ROUND_ACTIVE = 2
ROUND_ENDED = 3

VO_DEATH = 1
VO_PAIN = 2
VO_TAUNT = 3
VO_ALERT = 4
VO_IDLE = 5
VO_YES = 6
VO_SPAWN = 7
VO_QUESTION = 8
VO_VICTORY = 9

white_glow = { Color( 255, 255, 255, 255 ),  Color( 255, 255, 255, 200 ),  Color( 255, 255, 255, 125 ) }
white_glow_outline = { Color( 255, 255, 255, 255 ),  Color( 44, 44, 44, 255 ),  Color( 0, 0, 0, 255 ) }
blue_glow = { Color( 255, 255, 255, 255 ),  Color( 55, 55, 255, 255 ),  Color( 55, 55, 250, 255 ) }

function GM:CreateTeams()
	
	team.SetUp( TEAM_ANGEL, "Angels", Color( 80, 80, 255 ), true )
	
	team.SetUp( TEAM_DEMON, "Demons", Color( 255, 80, 80 ), false )
	
	team.SetUp( TEAM_SPECTATOR, "Spectators", Color( 80, 255, 150 ), true )
	team.SetSpawnPoint( TEAM_SPECTATOR, { "info_player_counterterrorist", "info_player_combine", "info_player_human", "info_player_deathmatch" } ) 
	team.SetSpawnPoint( TEAM_UNASSIGNED, { "info_player_counterterrorist", "info_player_combine", "info_player_human", "info_player_deathmatch" } ) 

end 

function GM:PlayerNoClip( ply, on )
	
	if game.SinglePlayer() then return true end
	
	if ply:IsAdmin() or ply:IsSuperAdmin() then return true end
	
	return false
	
end


function GM:OnPlayerChat( ply, text, teamchat, dead )
	
	// chat.AddText( player, Color( 255, 255, 255 ), ": ", strText )
	
	local tab = {}
	
	if dead then
	
		table.insert( tab, Color( 255, 255, 255 ) )
		table.insert( tab, "(DEAD) " )
		
	end
	
	if teamchat then 
	
		table.insert( tab, Color( 255, 255, 255 ) )
		table.insert( tab, "(TEAM) " )
		
	end
	
	if ( IsValid( ply ) ) then
	
		table.insert( tab, ply )
		
	else
	
		table.insert( tab, Color( 150, 255, 150 ) )
		table.insert( tab, "Console" )
		
	end
	
	table.insert( tab, Color( 255, 255, 255 ) )
	table.insert( tab, ": " .. text )
	
	chat.AddText( unpack( tab ) )

	return true
	
end

include 	( "player_class/base/player_default.lua" )
AddCSLuaFile( "player_class/base/player_default.lua" ) 
include 	( "player_class/base/bm_base.lua" )
AddCSLuaFile( "player_class/base/bm_base.lua" )

local classes = file.Find( "battlemages/gamemode/player_class/*", "LUA" )
for k,v in pairs( classes ) do 
	include( "player_class/"..v )     
	AddCSLuaFile( "player_class/"..v ) 
end 
