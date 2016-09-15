
local ACTIVE = {}

ACTIVE.name 						= "Pray to RNG" 			-- Name
ACTIVE.baseCooldown 				= 16				-- Base cooldown - note that is the "base" cooldown, because we may want to modify it.

ACTIVE.cooldownType 				= COOLDOWN_INSTANT	-- Determines the cooldown type.
ACTIVE.castType 					= CAST_INSTANT		-- Cast type.

ACTIVE.minHeal = 25
ACTIVE.maxHeal = 150
function ACTIVE:cast( ply ) -- This should be the "meat" of the ability.
	local h = math.random( self.minHeal, self.maxHeal )
	ply:heal( h )
end

BM:addPower( "a_rngheal", ACTIVE, "active_base" )
