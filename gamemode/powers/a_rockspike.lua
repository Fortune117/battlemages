
local ACTIVE = {}

ACTIVE.name 						= "Rock Spike"
ACTIVE.baseCooldown 				= 1

ACTIVE.cooldownType 				= COOLDOWN_INSTANT
ACTIVE.castType 					= CAST_INSTANT

ACTIVE.animation 					= PLAYER_ATTACK1
ACTIVE.shouldPlayAnimation 			= false 

ACTIVE.numRocks 					= 1 
ACTIVE.range 						= 800 

function ACTIVE:init()
	self.range = self.range ^ 2 
end 

function ACTIVE:canCast( ply )
	local tr = ply:GetEyeTrace()

	if tr.HitWorld and tr.HitPos:DistToSqr( ply:GetPos() ) < self.range then 
		return self.baseClass.canCast( self, ply )
	end 
	return false 
end 

function ACTIVE:cast( ply )
	local tr = ply:GetEyeTrace()
	if tr.HitWorld and tr.HitPos:DistToSqr( ply:GetPos() ) < self.range then 
		local rock = ents.Create( "bm_rockspike" )
		rock:SetPos( tr.HitPos - tr.HitNormal*50 ) 
		rock:SetAngles( tr.HitNormal:Angle() + Angle( 90, 0, 0 ) )
		rock:Spawn()
	end  
end

BM:addPower( "a_rockspike", ACTIVE, "active_base" ) 