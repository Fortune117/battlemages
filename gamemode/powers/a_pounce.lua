
local ACTIVE = {}

ACTIVE.name 						= "Pounce"
ACTIVE.baseCooldown 				= 4 

ACTIVE.cooldownType 				= COOLDOWN_INSTANT
ACTIVE.castType 					= CAST_INSTANT

ACTIVE.animation 					= PLAYER_ATTACK1
ACTIVE.shouldPlayAnimation 			= false 

ACTIVE.pounceForce 					= 650
ACTIVE.upForce 						= 300

function ACTIVE:canCast( ply )
	if ply:IsOnGround() then 
		return self.baseClass.canCast( self, ply )
	end 
	return false 
end 

function ACTIVE:cast( ply )
	ply:SetVelocity( ply:GetAimVector()*self.pounceForce + Vector( 0, 0, self.upForce ) )
end

BM:addPower( "a_pounce", ACTIVE, "active_base" ) 