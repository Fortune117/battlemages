
local PASSIVE = {}

PASSIVE.name 	= "Vampirism"
PASSIVE.type 	= ABILITY_PASSIVE

PASSIVE.stealMul = 0.25

function PASSIVE:onDealDamage( ply, vic, dmginfo )
	ply:heal( dmginfo:GetDamage()*self.stealMul )
end 

BM:addPassive( "p_vamp", PASSIVE, "passive_base" )