
include('shared.lua')

function ENT:Initialize()

	self.drawProp = ClientsideModel( self.Model, RENDERGROUP_OPAQUE )
	self.drawProp:SetAngles( self:GetAngles() )
	self.norm = (self:GetAngles() - Angle( 90, 0, 0 )):Forward()
	self.drawPos = self:GetPos() - self.norm*120

	local normal = self:GetUp()
	local position = normal:Dot( self:GetPos() - self.norm*55 )
	self.drawProp:SetRenderClipPlaneEnabled( true )
	self.drawProp:SetRenderClipPlane( normal, position )

	self.spawnTime = CurTime()

	self.removeTime = CurTime() + self.liveTime

end

function ENT:OnRemove()
	self.drawProp:Remove()
end

function ENT:Draw()

	--self.Entity:DrawModel()

	local normal = self:GetUp() -- Everything "behind" this normal will be clipped
	local position = normal:Dot( self:GetPos() ) -- self:GetPos() is the origin of the clipping plane

	local oldEC = render.EnableClipping( true )
	render.PushCustomClipPlane( normal, position )

		local p
		if CurTime() < self.removeTime - self.riseTime then
			p = math.min( (CurTime() - self.spawnTime)/self.riseTime, 1 )
		else
			p = 1 - ( math.min( (CurTime() - (self.removeTime - self.riseTime))/self.riseTime, 1 ) )
		end

		local pos = self.drawPos + (self.norm*122)*p

		self.drawProp:SetPos( pos )

		self.drawProp:DrawModel()

	render.PopCustomClipPlane()
	render.EnableClipping( oldEC )

end
