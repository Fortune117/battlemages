
local ACTIVE = {}

ACTIVE.name 					= "Deathblock" 			-- Name
ACTIVE.baseCooldown 			= 12				-- Base cooldown - note that is the "base" cooldown, because we may want to modify it.

ACTIVE.cooldownType 			= COOLDOWN_INSTANT	-- Determines the cooldown type.
ACTIVE.castType 				= CAST_INSTANT		-- Cast type.


function ACTIVE:cast( ply ) -- This should be the "meat" of the ability.
	ply:giveBuff( "buff_deathblock" )
end


BM:addPower( "a_deathblock", ACTIVE, "active_base" )
