
local ACTIVE = {}

ACTIVE.name 					= "Blur" 			-- Name
ACTIVE.baseCooldown 			= 12				-- Base cooldown - note that is the "base" cooldown, because we may want to modify it.

ACTIVE.cooldownType 			= COOLDOWN_INSTANT	-- Determines the cooldown type.
ACTIVE.castType 				= CAST_INSTANT		-- Cast type.


function ACTIVE:cast( ply ) -- This should be the "meat" of the ability.
	ply:giveBuff( "buff_blur" )
end


BM:addPower( "a_blur", ACTIVE, "active_base" )
