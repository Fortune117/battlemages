
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.Model = Model( "models/props_wasteland/rockcliff01k.mdl" )
ENT.riseAmount 	= 80
ENT.riseTime 	= 0.05
ENT.liveTime 	= 5 

function ENT:Initialize()

	self:SetModel( self.Model )
	self.riseEnd = CurTime() + self.riseTime 
	self:SetCollisionGroup( COLLISION_GROUP_WORLD )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_NOCLIP )
	if IsValid( self:GetPhysicsObject() ) then 
		self:PhysWake()
	end 
	self:beginRising()

	self.removeTime = CurTime() + self.liveTime

	self.startZ = self:GetPos().z 

end

function ENT:beginRising()
	local speed = self.riseAmount
	self:SetVelocity( Vector( 0, 0, self.riseAmount/self.riseTime ) )
end 

function ENT:finishRising()
	self:SetMoveType( MOVETYPE_NONE )
end 

function ENT:Think() 

	if CurTime() > self.riseEnd and not self.riseFinished then 
		self:finishRising()
		self.riseFinished = true 
	end 

	if CurTime() > self.removeTime  then 
		if not self.removePush then 
			self:SetMoveType( MOVETYPE_NOCLIP )
			self:SetVelocity( Vector( 0, 0, -(self.riseAmount/self.riseTime) ) )
			self.removePush = true 
		elseif self:GetPos().z < self.startZ then  
			self:Remove()
		end 
	end 

end 
