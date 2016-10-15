
local ACTIVE = {}

ACTIVE.name 						= "Barrage"
ACTIVE.baseCooldown 				= 8

ACTIVE.cooldownType 				= COOLDOWN_INSTANT
ACTIVE.castType 					= CAST_INSTANT

ACTIVE.animation 					= PLAYER_ATTACK1
ACTIVE.shouldPlayAnimation 			= false

ACTIVE.fireDelay = 0.09

function ACTIVE:canCast( ply )
	local wep = ply:GetActiveWeapon()
	local hasAmmo = wep:Clip1() > 0
	return self.baseClass.canCast( self, ply ) and hasAmmo
end

function ACTIVE:cast( ply )
	local wep = ply:GetActiveWeapon()
	if wep:GetClass() == "weapon_bm_grenadelauncher" then
		wep:barrage( self.fireDelay )
	end
end

BM:addPower( "a_barrage", ACTIVE, "active_base" )
