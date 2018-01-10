
local ACTIVE = {}

ACTIVE.name 						= "Elemental Cycle" 			-- Name
ACTIVE.baseCooldown 				= 0				-- Base cooldown - note that is the "base" cooldown, because we may want to modify it.

ACTIVE.cooldownType 				= COOLDOWN_INSTANT	-- Determines the cooldown type.
ACTIVE.castType 					= CAST_INSTANT		-- Cast type.

function ACTIVE:cast( ply ) -- This should be the "meat" of the ability.
end

BM:addPower( "a_elempowerchange", ACTIVE, "active_base" )
