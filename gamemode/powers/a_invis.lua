
local ACTIVE = {}

ACTIVE.name 						= "Smokebomb"
ACTIVE.baseCooldown 				= 8

ACTIVE.cooldownType 				= COOLDOWN_INSTANT
ACTIVE.castType 					= CAST_INSTANT

ACTIVE.animation 					= PLAYER_ATTACK1
ACTIVE.shouldPlayAnimation 			= false 


function ACTIVE:cast( ply )
	ply:giveBuff( "buff_invis" )
end

BM:addPower( "a_invis", ACTIVE, "active_base" ) 