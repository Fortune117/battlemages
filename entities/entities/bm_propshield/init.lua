
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()

	self:SetModel( self.Model )
	self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_NOCLIP )
	self:DrawShadow( false )
end

function ENT:setOrbit( ply, order, orderMax, radius, speed, height, health, clockwise )

	self:SetOwner( ply )
	self.order = order
	self.orderMax = orderMax
	self.radius = radius
	self.clockwise = clockwise
	self.height = height
	self.speed = speed
	self:SetHealth( health )

	self:SetNWInt( "order", order )
	self:SetNWInt( "orderMax", orderMax )
	self:SetNWInt( "radius", radius )
	self:SetNWInt( "speed", speed )
	self:SetNWInt( "height", height )

	if SERVER then
		self:SetParent( ply )
	end

end

function ENT:OnTakeDamage( dmginfo )
	self:SetHealth( self:Health() - dmginfo:GetDamage() )
	if self:Health() <= 0 then
		self:Remove()
	end
end

function ENT:Think()

	local ply = self:GetOwner()
	if ply then
		self:orbitThink( ply )
	end
	self:NextThink( CurTime() )
	return true

end

local rad = math.pi*2
function ENT:orbitThink( ply )

	if not IsValid( ply ) or not ply:Alive() then self:Remove() return end

	local playerPos = ply:GetPos()
	local z = self.height
	local x = math.sin( CurTime()*self.speed + (rad/self.orderMax)*self.order )*self.radius
	local y = math.cos( CurTime()*self.speed + (rad/self.orderMax)*self.order )*self.radius
	local pos = Vector( x, y, z )
	self:SetPos( pos )

	local norm = ( self:GetPos() - playerPos ):GetNormalized():Angle()
	norm.p = norm.p - 45
	self:SetAngles( norm )

end
