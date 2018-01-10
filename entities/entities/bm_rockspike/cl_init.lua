
include('shared.lua')

local rad = math.pi*2
local rockGap = 50
function ENT:Initialize()

	self.drawProps = {}

	self.norm = (self:GetAngles() - Angle( 90, 0, 0 )):Forward()

	self.drawPos = self:GetPos() - self.norm*120

	local nRocks = self.numRocks
	for i = 1,nRocks do

		self.drawProps[ i ] = ClientsideModel( self.Model, RENDERGROUP_OPAQUE )

		local nUp = self.norm:Angle():Up()
		local nRight = self.norm:Angle():Right()

		local k = ((i - 1)/nRocks)*rad

		local xadd = math.cos( k )*nRight*rockGap
		local yadd = math.sin( k )*nUp*rockGap
		local n = xadd + yadd + self.norm*122

		self.drawProps[ i ]:SetAngles( n:Angle() + Angle( 90, 0, 0 ) )

		local normal = self:GetUp()
		local position = normal:Dot( self:GetPos() - self.norm*55 )
		self.drawProps[ i ]:SetRenderClipPlaneEnabled( true )
		self.drawProps[ i ]:SetRenderClipPlane( normal, position )

	end

	self.spawnTime = CurTime()

	self.removeTime = CurTime() + self.liveTime

end

function ENT:OnRemove()
	for i = 1,self.numRocks do
		self.drawProps[ i ]:Remove()
	end
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

		local nRocks = self.numRocks
		for i = 1, nRocks do

			local nUp = self.norm:Angle():Up()
			local nRight = self.norm:Angle():Right()

			local k = ((i - 1)/nRocks)*rad
			local xadd = math.cos( k )*nRight*rockGap
			local yadd = math.sin( k )*nUp*rockGap
			local n = xadd + yadd + self.norm*100

			local pos = self.drawPos + n*p

			self.drawProps[ i ]:SetPos( self.drawPos + n*p )

			self.drawProps[ i ]:DrawModel()

		end

	render.PopCustomClipPlane()
	render.EnableClipping( oldEC )

end
