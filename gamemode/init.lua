AddCSLuaFile( "sh_battlemages.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_battlemages.lua" )
AddCSLuaFile( "sh_player.lua" )
AddCSLuaFile( "sh_powers.lua" )
AddCSLuaFile( "sh_buffs.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_hud.lua" )
AddCSLuaFile( "cl_draw.lua" )
AddCSLuaFile( "cl_powers.lua" )
AddCSLuaFile( "cl_halooverride.lua" )
AddCSLuaFile( "cl_classmenu.lua" )


include( "sh_battlemages.lua" )
include( "shared.lua" )
include( "sv_battlemages.lua" )
include( "sh_player.lua" )
include( "sh_powers.lua" )
include( "sh_buffs.lua" )
include( "sv_player.lua" )
include( "sv_powers.lua" )

function GM:PlayerInitialSpawn( ply )

	ply:SetTeam( TEAM_ANGEL )

	ply:setBMClass( "bm_grenadier" )

	self.BaseClass.PlayerInitialSpawn( self, ply )
end
 
local classes =
{
	"bm_rng",
	"bm_admin",
	"bm_minge",
	"bm_ranger"
}
function GM:PlayerSpawn( ply )

	ply:setClassPlayerModel()

	for k,data in pairs( BM.classChangeQue ) do
		if data.player == ply then
			ply:setBMClass( data.class )
			table.remove( BM.classChangeQue, k )
			break
		end
	end

	self.BaseClass.PlayerSpawn( self, ply )
end

function GM:DoPlayerDeath( ply, atk, dmginfo )

	BM:doPlayerDeath( ply, atk, dmginfo )

	self.BaseClass:DoPlayerDeath( ply, atk, dmginfo )
end

function GM:Think()
	BM:think()
end

function GM:KeyPress( ply, key )
	BM:keyPress( ply, key )
end

function GM:OnPlayerHitGround( ply, inWater, onFloater, speed )
	BM:onPlayerHitGround( ply, inWater, onFloater, speed )
end

function GM:EntityTakeDamage( targ, dmginfo )
	local atk = dmginfo:GetAttacker()
	if targ:IsPlayer() or atk:IsPlayer() then
		BM:entityTakeDamage( targ, atk, dmginfo )
	end
end

function GM:GetFallDamage( ply, speed )
	return 0
end

function GM:ShowTeam( ply )
	ply:ConCommand( "bm_openclassmenu" )
end
