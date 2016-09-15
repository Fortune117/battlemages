
local ACTIVE = {}

ACTIVE.name 						= "Propsurf"
ACTIVE.baseCooldown 				= 8

ACTIVE.cooldownType 				= COOLDOWN_INSTANT
ACTIVE.castType 					= CAST_INSTANT

ACTIVE.animation 					= PLAYER_ATTACK1
ACTIVE.shouldPlayAnimation 			= false

ACTIVE.pounceForce 					= 550
ACTIVE.upForce 						= 250

function ACTIVE:cast( ply )
	ply:SetVelocity( ply:GetAimVector()*self.pounceForce + Vector( 0, 0, self.upForce ) )
end


BM:addPower( "a_propsurf", ACTIVE, "active_base" )
