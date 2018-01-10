
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()

	self:SetModel( self.Model )
	self:SetCollisionGroup( COLLISION_GROUP_PUSHAWAY )
	--self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_NONE )
	self:DrawShadow( false )

	self.removeTime = CurTime() + self.liveTime

	self:doBlast()

	self:EmitSound( "physics/concrete/concrete_break2.wav" )

end

function ENT:setStats( damage, force,ownerFScale, radius )
	self.damage = damage
	self.force = force
	self.ownerFScale = ownerFScale
	self.radius = radius
end

function ENT:doBlast()
	local ply = self:GetOwner()
	local pos = self:GetPos()
	for k,v in pairs( ents.GetAll() ) do
		if v:IsPlayer() and not v:Alive() then continue end
		local vpos = v:GetPos()
		local dist = vpos:DistToSqr( pos )
		if dist <= self.radius and v:Visible( self ) then
			local norm = ( vpos - pos ):GetNormalized()
			self:doHit( v, norm )
		end
	end
end

function ENT:doHit( ent, norm )

	local isOwner = ent == self:GetOwner()

	local s = isOwner and 0 or 1
	local s2 = isOwner and self.ownerFScale or 0.5

	local f2 = norm*self.force*s2
	f2.z = 0
	local force = self:GetUp()*self.force*s2 + f2

	local dmg = DamageInfo()
	dmg:SetDamageType( DMG_SONIC )
	dmg:SetDamage( self.damage*s )
	dmg:SetDamageForce( force )
	dmg:SetInflictor( self )
	dmg:SetAttacker( self:GetOwner() or self )


	ent:SetPos( ent:GetPos() + Vector( 0, 0, 2 ) )
	ent:SetVelocity( force )
	ent:TakeDamageInfo( dmg )

end

function ENT:Think()

	if CurTime() > self.removeTime then
		self:Remove()
	end

end

--for k,v in pairs( ents.FindByClass( "bm_rockspike") ) do v:Remove() end
