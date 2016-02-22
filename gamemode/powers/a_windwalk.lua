
local ACTIVE = {}

ACTIVE.name 						= "Windwalk"
ACTIVE.baseCooldown 				= 8

ACTIVE.cooldownType 				= COOLDOWN_INSTANT
ACTIVE.castType 					= CAST_INSTANT

ACTIVE.animation 					= PLAYER_ATTACK1
ACTIVE.shouldPlayAnimation 			= false 


function ACTIVE:cast( ply )
	ply:giveBuff( "buff_windwalk" )
end

BM:addPower( "a_windwalk", ACTIVE, "active_base" ) 