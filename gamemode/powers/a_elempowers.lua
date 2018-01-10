
local ACTIVE = {}

ACTIVE.name 						= "Elemental Prowess"
ACTIVE.baseCooldown 				= 1

ACTIVE.cooldownType 				= COOLDOWN_INSTANT
ACTIVE.castType 					= CAST_INSTANT

ACTIVE.animation 					= PLAYER_ATTACK1
ACTIVE.shouldPlayAnimation 			= false

ACTIVE.curPower = "fire"

ACTIVE.rock = {}

ACTIVE.rock.damage						= 120
ACTIVE.rock.force 						= 400
ACTIVE.rock.ownerForceScale 			= 1
ACTIVE.rock.range 						= 800
ACTIVE.rock.radius 						= 170

function ACTIVE:init()
	self.rock.range = self.rock.range ^ 2
	self.rock.radius = self.rock.radius ^ 2
end

function ACTIVE:getPower()
	return self[ self.curPower ]
end

function ACTIVE:setPower( str )
	self.curPower = str
end

--------------------------------------------------------------------------------

function ACTIVE.rock:canCast( active, ply )
	local tr = ply:GetEyeTrace()
	local inRange = tr.HitPos:DistToSqr( ply:GetPos() ) < self.range
	local validHit = tr.HitWorld or ( tr.Entity and tr.Entity:IsOnGround() )
	if inRange and validHit then
		return active.baseClass.canCast( active, ply )
	end
	return false
end

function ACTIVE.rock:cast( active, ply )
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

			local ef = EffectData()
			ef:SetOrigin( tr.HitPos )
			ef:SetNormal( tr.HitNormal )
			util.Effect( "bm_rockspike", ef, true, true )


		elseif tr.Entity then

			local e = tr.Entity
			if e:IsOnGround() then
				local tr2 = util.QuickTrace( e:GetPos(), e:GetUp()*-10, { unpack( ents.GetAll() ) } )
				if tr2.HitWorld then
					local rock = ents.Create( "bm_rockspike" )
					rock:SetPos( tr2.HitPos + tr2.HitNormal*54 )
					rock:SetAngles( tr2.HitNormal:Angle() + Angle( 90, 0, 0 ) )
					rock:SetOwner( ply )
					rock:setStats( self.damage, self.force, self.ownerForceScale, self.radius )
					rock:Spawn()
				end
			end

		end
	end
end

--------------------------------------------------------------------------------

ACTIVE.wind = {}

function ACTIVE.wind:canCast( active, ply )
	return active.baseClass.canCast( active, ply )
end

function ACTIVE.wind:cast( active, ply )
	ply:giveBuff( "buff_elemwind" )
end

--------------------------------------------------------------------------------

ACTIVE.fire = {}

ACTIVE.fire.damage						= 120
ACTIVE.fire.force 						= 400
ACTIVE.fire.ownerForceScale 			= 1
ACTIVE.fire.range 						= 800
ACTIVE.fire.radius 						= 170

function ACTIVE.fire:canCast( active, ply )
	return active.baseClass.canCast( active, ply )
end

function ACTIVE.fire:cast( active, ply )
	ply:giveBuff( "buff_elemwind" )
end

--------------------------------------------------------------------------------

function ACTIVE:canCast( ply )
	local power = self:getPower()
	return power:canCast( self, ply )
end

function ACTIVE:cast( ply )
	local power = self:getPower()
	power:cast( self, ply )
end


BM:addPower( "a_elempowers", ACTIVE, "active_base" )
