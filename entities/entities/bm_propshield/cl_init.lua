
include('shared.lua')

function ENT:Initialize()
	self.gprop = ClientsideModel( self.Model, RENDERGROUP_TRANSLUCENT )
	self.gprop:SetRenderMode( RENDERMODE_TRANSCOLOR )
end

function ENT:OnRemove()
	if self.gprop then self.gprop:Remove() end
end

function ENT:Draw()
end

local rad = math.pi*2
function ENT:Think()

	local ply = LocalPlayer()
	local owner = self:GetOwner()

	if ply == owner then
		self.gprop:SetColor( Color( 255, 255, 255, 100 ) )
	end

	local speed = self:GetNWInt( "speed" )
	local order = self:GetNWInt( "order" )
	local orderMax = self:GetNWInt( "orderMax" )
	local radius = self:GetNWInt( "radius" )
	local height = self:GetNWInt( "height" )

	local playerPos = owner:GetPos()
	local z = playerPos.z + height
	local x = playerPos.x + math.sin( CurTime()*speed + (rad/orderMax)*order )*radius
	local y = playerPos.y + math.cos( CurTime()*speed + (rad/orderMax)*order )*radius
	local pos = Vector( x, y, z )
	self.gprop:SetPos( pos )

	local norm = ( pos - playerPos ):GetNormalized():Angle()
	norm.p = norm.p - 45
	self.gprop:SetAngles( norm )

	render.SetBlend( 1 )

end
