AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "sh_player.lua" )
AddCSLuaFile( "sh_battlemages.lua" )
AddCSLuaFile( "sh_powers.lua" )
AddCSLuaFile( "sh_buffs.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_hud.lua" )
AddCSLuaFile( "cl_draw.lua" )
AddCSLuaFile( "cl_powers.lua" )


include( "shared.lua" )
include( "sh_player.lua" )
include( "sh_battlemages.lua" )
include( "sh_powers.lua" )
include( "sh_buffs.lua" )
include( "sv_player.lua" )
include( "sv_powers.lua" )

function GM:PlayerInitialSpawn( ply )

	ply:SetTeam( TEAM_ANGEL )


	self.BaseClass.PlayerInitialSpawn( self, ply )
end

local classes =
{
	"bm_rng",
	"bm_admin",
	"bm_minge"
}
function GM:PlayerSpawn( ply )

	ply:setClassPlayerModel()
	ply:setBMClass( table.Random( classes ) ) 

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
