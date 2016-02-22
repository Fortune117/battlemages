
local AURA = {}

AURA.name 	= "Death Aura"
AURA.type 	= ABILITY_AURA
AURA.radius = 300 

function AURA:onPlayerEnter( ply )
end 

function AURA:onPlayerExit( ply )
end 

function AURA:auraThink( ply )
end 

function AURA:auraDeath( ply, atk, dmginfo )
end 

BM:addPassive( "p_a_death", AURA, "aura_base" )