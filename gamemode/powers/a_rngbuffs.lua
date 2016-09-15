
local ACTIVE = {}

ACTIVE.name 						= "Request Buffs" 			-- Name
ACTIVE.baseCooldown 				= 16				-- Base cooldown - note that is the "base" cooldown, because we may want to modify it.

ACTIVE.cooldownType 				= COOLDOWN_INSTANT	-- Determines the cooldown type.
ACTIVE.castType 					= CAST_INSTANT		-- Cast type.

ACTIVE.range = 400

local buffs =
{
	"buff_rng_vamp",
	"buff_rng_dmg",
	"buff_rng_speed"
}
function ACTIVE:cast( ply ) -- This should be the "meat" of the ability.
	local pos = ply:GetPos()
	local t = ply:Team()
	for k,v in pairs( player.GetAll() ) do
		if v:Team() == t and v:Alive() and v:GetPos():Distance( pos ) <= self.range then
			v:giveBuff( table.Random( buffs ) )
		end
	end
end

BM:addPower( "a_rngbuffs", ACTIVE, "active_base" )
