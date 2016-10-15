
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

util.AddNetworkString( "mineTriggered" )
util.AddNetworkString( "mineDestroyed" )
function ENT:Initialize()


	self:SetModel( self.Model )
	self:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self:PhysicsInitSphere( 0.2, "metal" )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:PhysWake()
	self:GetPhysicsObject():SetMass( 35 )
	self:SetModelScale( 0.5 )
	self.set = false
	self.armed = false
	self.armDelay = 0

end

function ENT:fling( dir, force, damage, range, armtime, radius )
	local physObj = self:GetPhysicsObject()
	physObj:ApplyForceCenter( dir*force )
	physObj:AddAngleVelocity( VectorRand()*500 )
	self.damage = damage
	self.range 	= range^2
	self.armTime = armtime
	self.radius = radius^2
end

function ENT:PhysicsCollide( colData, collider )
    if colData.HitEntity:IsWorld() and not self.set and not self.destroyed then
		local norm = colData.HitNormal
		self:SetAngles( norm:Angle() + Angle( -90, 0, 0 ) )
		self:SetMoveType( MOVETYPE_NONE )
		self:EmitSound( "NPC_CombineMine.CloseHooks" )
		self.set = true
		self.armDelay = CurTime() + self.armTime
	end
end

function ENT:Think()

	if not IsValid( self:GetOwner() ) then
		self:Remove()
	end
	if self.set then

		if CurTime() >= self.armDelay then
			if not self.armed then
				self.armed = true
				self:EmitSound( "NPC_CombineMine.TurnOn" )
			end
			local pos = self:GetPos()
			for k,v in pairs( player.GetAll() ) do
				if v == self:GetOwner() then continue end
				if v:GetPos():DistToSqr( pos ) <= self.range then
					self:detonate()
				end
			end
		end

	end

end

function ENT:OnTakeDamage( dmginfo )

	self:PhysicsInit( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_VPHYSICS )
	self:PhysWake()
	self:GetPhysicsObject():ApplyForceCenter( VectorRand()*1500 )
	self:GetPhysicsObject():AddAngleVelocity( VectorRand()*1200 )
	local delay = CurTime() + 1.5
	self.Think = function( self )
		if CurTime() >= delay then
			self:Remove()
		end
	end

	if not self.destroyed then

		net.Start( "mineDestroyed" )
			net.WriteVector( self:GetPos() )
		net.Send( self:GetOwner() )
		self.destroyed = true

	end

end

function ENT:detonate()

	local effect = EffectData()
	effect:SetStart(self:GetPos())
	effect:SetOrigin(self:GetPos())
	effect:SetScale(400)
	effect:SetRadius(400)
	effect:SetMagnitude(220)
	util.Effect("Explosion", effect, true, true)

	local pos = self:GetPos()
	for k,v in pairs( player.GetAll() ) do
		if not v:Alive() then continue end
		local vpos = v:GetPos()
		if vpos:DistToSqr( pos ) <= self.radius then
			local dmginfo = DamageInfo()
			dmginfo:SetDamageType( DMG_BLAST )
			dmginfo:SetDamage( self.damage )
			dmginfo:SetDamageForce( ( vpos - pos ):GetNormalized()*300 )
			dmginfo:SetInflictor( self )
			dmginfo:SetAttacker( self:GetOwner() or self )
			v:TakeDamageInfo( dmginfo )
		end
	end


	local owner = self:GetOwner()
	net.Start( "mineTriggered" )
		net.WriteVector( pos )
	net.Send( owner )

	self:Remove()

end

hook.Add( "OnPlayerChangeBMClass", "removeMines", function( ply, oldClass, newClass )
	if ply.mine and IsValid( ply.mine ) then
		ply.mine:Remove()
	end
end)
