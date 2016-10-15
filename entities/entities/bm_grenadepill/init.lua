
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()

	self:SetModel( self.Model )
	self:SetModelScale( 0.15 )

	self:PhysicsInitSphere( 2, "metal" )

	self:SetCollisionGroup( COLLISION_GROUP_PROJECTILE )
	self:SetMoveType( MOVETYPE_VPHYSICS )

	local physObj = self:GetPhysicsObject()
	if IsValid( physObj ) then
		physObj:Wake()
		physObj:EnableGravity( false )
		physObj:EnableDrag( false )
		physObj:SetMass( 2 )
		physObj:AddGameFlag( FVPHYSICS_NO_IMPACT_DMG )
	end

	self:SetGravity( 1.2 )
	self:SetElasticity( 1 )

	self:StartMotionController()

end

function ENT:PhysicsSimulate( physObj, dt )
	local v = -Vector( 0, 0, 514 )*( self:GetGravity()*dt )
	physObj:ApplyForceCenter( v )
end

--for k,v in pairs( ents.FindByClass( "bm_grenadepill") ) do v:Remove() end

function ENT:fling( dir, force, damage, radius )
	local physObj = self:GetPhysicsObject()
	physObj:ApplyForceCenter( dir*force )
	self.damage = damage
	self.radius = radius^2
end

local hitSounds   =
{
    Sound( "physics/metal/metal_sheet_impact_hard2.wav" ),
    Sound( "physics/metal/metal_sheet_impact_hard6.wav" ),
    Sound( "physics/metal/metal_sheet_impact_hard7.wav" )
}

function ENT:PhysicsCollide( colData, physobj )

	local LastSpeed = math.max( colData.OurOldVelocity:Length(), colData.Speed )
	local NewVelocity = physobj:GetVelocity()
	NewVelocity:Normalize()

	LastSpeed = math.max( NewVelocity:Length(), LastSpeed )

	local TargetVelocity = ( NewVelocity * LastSpeed + colData.HitNormal*-(LastSpeed/12) ) * 0.4

	physobj:SetVelocity( TargetVelocity )


	local hitEnt = colData.HitEntity
	if (hitEnt:IsWorld() and not self.hitWorld) then
		self.hitWorld = true
		self.liveTime = CurTime() + 2.5
	elseif IsValid( hitEnt ) then
		self:detonate()
		return
	end

end

local expSounds =
{
	Sound( "weapons/explode3.wav" ),
	Sound( "weapons/explode4.wav" ),
	Sound( "weapons/explode5.wav" )
}
function ENT:detonate( scale )

	local effect = EffectData()
	effect:SetStart(self:GetPos())
	effect:SetOrigin(self:GetPos())
	effect:SetScale(1)
	effect:SetRadius(1)
	effect:SetMagnitude(1)
	util.Effect("Explosion", effect, true, true)

	local ply = self:GetOwner()
	local pos = self:GetPos()
	for k,v in pairs( ents.GetAll() ) do
		if v:IsPlayer() and not v:Alive() then continue end
		local vpos = v:GetPos()
		local dist = vpos:DistToSqr( pos )
		if dist <= self.radius and v:Visible( self ) then
			local p = math.max( 0.2, ((self.radius-dist + 15)/self.radius) )
			local dmginfo = DamageInfo()
			local s = v == ply and 0.5 or 1
			dmginfo:SetDamageType( DMG_SONIC )
			dmginfo:SetDamage( self.damage*p*s )
			dmginfo:SetDamageForce( ( vpos - pos ):GetNormalized()*300 )
			dmginfo:SetInflictor( self )
			dmginfo:SetAttacker( self:GetOwner() or self )
			v:TakeDamageInfo( dmginfo )
		end
	end

	SafeRemoveEntityDelayed( self, 0 )

end

function ENT:Think()

	if ( self:WaterLevel() >= 1 and not self.hitWorld )  then
		self.hitWorld = true
		self.liveTime = CurTime() + 2.5
	end

	if self.hitWorld and CurTime() > self.liveTime then
		self:detonate( 0.5 )
	end

	self.lastThink = CurTime()

	self:NextThink( CurTime() )
	return true
end
