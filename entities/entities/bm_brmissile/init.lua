
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

	self:SetElasticity( 1 )

end

--for k,v in pairs( ents.FindByClass( "bm_brmissile") ) do v:Remove() end

local rad = math.pi*2
local force = 1500
function ENT:fire( damage, spread, radius )

	local dir = Vector( math.cos( math.Rand( -rad, rad ) )*spread, math.sin( math.Rand( -rad, rad ) )*spread, -1 )

	local physObj = self:GetPhysicsObject()
	physObj:ApplyForceCenter( dir*force )

	self.damage = damage
	self.radius = radius^2

	self:SetAngles( dir:Angle() )

end

local hitSounds   =
{
    Sound( "physics/metal/metal_sheet_impact_hard2.wav" ),
    Sound( "physics/metal/metal_sheet_impact_hard6.wav" ),
    Sound( "physics/metal/metal_sheet_impact_hard7.wav" )
}

function ENT:PhysicsCollide( colData, physobj )

	local hitEnt = colData.HitEntity
	if IsValid( hitEnt ) or hitEnt:IsWorld() then
		self:detonate()
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

	local pos = self:GetPos()
	for k,v in pairs( player.GetAll() ) do
		if not v:Alive() then continue end
		local vpos = v:GetPos()
		local dist = vpos:DistToSqr( pos )
		if dist <= self.radius and v:Visible( self ) then
			local dmginfo = DamageInfo()
			dmginfo:SetDamageType( DMG_BLAST )
			dmginfo:SetDamage( self.damage )
			dmginfo:SetDamageForce( ( vpos - pos ):GetNormalized()*300 )
			dmginfo:SetInflictor( self )
			dmginfo:SetAttacker( self:GetOwner() or self )
			v:TakeDamageInfo( dmginfo )
		end
	end

	SafeRemoveEntityDelayed( self, 0 )

end
