
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()

	self:SetModel( self.Model )
	self:SetModelScale( 0.75 )

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

	self:SetGravity( 0.25 )
	self:SetElasticity( 1 )

	self:StartMotionController()

end

function ENT:PhysicsSimulate( physObj, dt )
	local v = -Vector( 0, 0, 514 )*( self:GetGravity()*dt )
	physObj:ApplyForceCenter( v )
end

--for k,v in pairs( ents.FindByClass( "bm_bombrain") ) do v:Remove() end

function ENT:fling( dir, data )

	local physObj = self:GetPhysicsObject()
	physObj:ApplyForceCenter( dir*data.force )

	self.damage = data.damage
	self.duration = CurTime() + data.duration + data.delay
	self.fireRate = data.duration/data.projectiles
	self.delay = CurTime() + data.delay
	self.spread = data.spread
	self.radius = data.radius

	print( data.spread )

	self.fireDelay = 0

	self.Think = self.flyThink

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

	local TargetVelocity = ( NewVelocity * LastSpeed + colData.HitNormal*-(LastSpeed/12) ) * 0.3

	physobj:SetVelocity( TargetVelocity )

end

function ENT:flyThink()
	if CurTime() > self.delay then
		self.Think = self.fireThink
		self:StopMotionController()
		self:SetMoveType( MOVETYPE_NONE )
	end
	self:NextThink( CurTime() )
	return true
end

function ENT:fireThink()
	local t = CurTime()
	if t < self.duration then
		if t > self.fireDelay then
			self:fireMissile()
			self.fireDelay = t + self.fireRate
		end
	else
		self:Remove()
	end
	self:NextThink( t )
	return true
end

function ENT:fireMissile()

	local pos = self:GetPos()
	local mis = ents.Create( "bm_brmissile" )
	mis:SetPos( pos )
	mis:SetOwner( self:GetOwner() )
	mis:Spawn()

	mis:fire( self.damage, self.spread, self.radius )

	self:EmitSound( "weapons/airboat/airboat_gun_energy1.wav" )

end
