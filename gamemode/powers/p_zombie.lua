
local PASSIVE = {}

PASSIVE.name 	= "Blank Passive" 	-- Name
PASSIVE.type 	= ABILITY_PASSIVE 	-- Ability type.


PASSIVE.healAmount = 0.35

function PASSIVE:onKill( ply, vic, dmginfo ) -- Called when the passive owner kills a player.
	ply:heal( ply:GetMaxHealth()*self.healAmount )
end

BM:addPassive( "p_zombie", PASSIVE, "passive_base" )
