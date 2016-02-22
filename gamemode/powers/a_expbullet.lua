
local ACTIVE = {}

ACTIVE.name 						= "Explosive Bullet"	-- Name
ACTIVE.baseCooldown 				= 8 					-- Base cooldown - note that is the "base" cooldown, because we may want to modify it.

ACTIVE.cooldownType 				= COOLDOWN_INSTANT		-- Determines the cooldown type.
ACTIVE.castType 					= CAST_INSTANT			-- Cast type.


function ACTIVE:cast( ply ) -- This should be the "meat" of the ability.
	ply:giveBuff( "buff_expbullet" )
end

BM:addPower( "a_expbullet", ACTIVE, "active_base" ) 