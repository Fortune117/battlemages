
local AURA = {}

AURA.name 	= "Vamp Aura"
AURA.type 	= ABILITY_AURA
AURA.radius = 500 

function AURA:onPlayerEnter( ply )
	ply:giveBuff( "buff_vampaura" )
end 

function AURA:onPlayerExit( ply )
	ply:removeBuff( "buff_vampaura" )
end 

function AURA:auraThink( ply )
	if not ply:hasBuff( "buff_vampaura" ) then 
		ply:giveBuff( "buff_vampaura" )
	end 
end 

BM:addPassive( "p_a_vamp", AURA, "aura_base" )