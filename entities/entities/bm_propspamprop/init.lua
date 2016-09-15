
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()

	self:SetModel( table.Random( self.Models ) )
	self:SetCollisionGroup( COLLISION_GROUP_INTERACTIVE_DEBRIS )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:PhysWake()
	self:GetPhysicsObject():SetMass( 500 )
	self:DrawShadow( false )

	self.liveTime = CurTime() + 6

end

function ENT:fling( targ, force, damage )
	local pos = targ:GetPos() + Vector( 0, 0, 45 )
	local spos = self:GetPos()
	local norm = (pos-spos):GetNormalized()
	local physObj = self:GetPhysicsObject()
	physObj:ApplyForceCenter( norm*force*physObj:GetMass() )
	self.damage = damage
end

function ENT:Think()
	if CurTime() > self.liveTime then self:Remove() end
end

function ENT:PhysicsCollide( colData, collider )
    if colData.HitEntity:IsWorld() or colData.HitEntity:IsPlayer() then
		self:Remove()
	end
end
