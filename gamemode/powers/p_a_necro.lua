
local AURA = {}

AURA.name 	        = "Necro Aura"
AURA.type 	        = ABILITY_AURA
AURA.radius         = 300
AURA.includeSelf 	= false				-- Should the aura target the owner?
AURA.healPercentage = 0.15

function AURA:onPlayerEnter( ply ) -- Called when a player enters the aura.
end

function AURA:onPlayerExit( ply ) -- Called when a player exits the aura.
end

function AURA:auraDeath( ply, atk, dmginfo )
    self.player:heal( self.player:GetMaxHealth()*self.healPercentage )
end

BM:addPassive( "p_a_necro", AURA, "aura_base" )
