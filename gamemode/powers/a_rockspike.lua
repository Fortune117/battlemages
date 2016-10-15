
local ACTIVE = {}

ACTIVE.name 						= "Rock Spike"
ACTIVE.baseCooldown 				= 1

ACTIVE.cooldownType 				= COOLDOWN_INSTANT
ACTIVE.castType 					= CAST_INSTANT

ACTIVE.animation 					= PLAYER_ATTACK1
ACTIVE.shouldPlayAnimation 			= false

ACTIVE.damage						= 120
ACTIVE.force 						= 400
ACTIVE.ownerForceScale 				= 1.2
ACTIVE.range 						= 800
ACTIVE.radius 						= 120

function ACTIVE:init()
	self.range = self.range ^ 2
	self.radius = self.radius ^ 2
end

function ACTIVE:canCast( ply )
	local tr = ply:GetEyeTrace()
	local inRange = tr.HitPos:DistToSqr( ply:GetPos() ) < self.range
	local validHit = tr.HitWorld or ( tr.Entity and tr.Entity:IsOnGround() )
	if inRange and validHit then
		return self.baseClass.canCast( self, ply )
	end
	return false
end

function ACTIVE:cast( ply )
	local tr = ply:GetEyeTrace()
	local inRange = tr.HitPos:DistToSqr( ply:GetPos() ) < self.range
	if inRange then
		if tr.HitWorld then
			local rock = ents.Create( "bm_rockspike" )
			rock:SetPos( tr.HitPos + tr.HitNormal*54 )
			rock:SetAngles( tr.HitNormal:Angle() + Angle( 90, 0, 0 ) )
			rock:SetOwner( ply )
			rock:setStats( self.damage, self.force, self.ownerForceScale, self.radius )
			rock:Spawn()
		elseif tr.Entity then
			local e = tr.Entity
			if e:IsOnGround() then
				local rock = ents.Create( "bm_rockspike" )
				rock:SetPos( e:GetPos() + Vector( 0, 0, 1 )*54 )
				rock:SetAngles( Vector( 0, 0, 1 ):Angle() + Angle( 90, 0, 0 ) )
				rock:SetOwner( ply )
				rock:setStats( self.damage, self.force, self.ownerForceScale, self.radius )
				rock:Spawn()
			end
		end
	end
end

BM:addPower( "a_rockspike", ACTIVE, "active_base" )
