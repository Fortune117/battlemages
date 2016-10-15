
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

util.AddNetworkString( "mineTriggered" )
util.AddNetworkString( "mineDestroyed" )
function ENT:Initialize()

	self:SetModel( self.Model )
	self:SetCollisionGroup( COLLISION_GROUP_PLAYER )
	self:SetMoveType( MOVETYPE_FLY )

	self:SetModelScale( 0.5 )
	self:PhysicsInit( SOLID_VPHYSICS )

	local physObj = self:GetPhysicsObject()
	if IsValid( physObj ) then
		physObj:Wake()
		physObj:EnableGravity( false )
		physObj:EnableDrag( false )
		physObj:SetMass( 1 )
	end


end

--for k,v in pairs( ents.FindByClass( "bm_shuriken") ) do v:Remove() end

function ENT:fling( dir, force, damage  )
	self:SetAngles( dir:Angle() )
	local physObj = self:GetPhysicsObject()
	physObj:ApplyForceCenter( dir*force )
	physObj:AddAngleVelocity( Angle( 0, 0, 90 ):Right()*900 )
	self.damage = damage
end

local hitSounds   =
{
    Sound( "physics/metal/metal_sheet_impact_hard2.wav" ),
    Sound( "physics/metal/metal_sheet_impact_hard6.wav" ),
    Sound( "physics/metal/metal_sheet_impact_hard7.wav" )
}

function ENT:PhysicsCollide( colData, collider )
    if colData.HitEntity:IsPlayer() then

		if self.damage > colData.HitEntity:Health() then
			local ply = self:GetOwner()
			for k,v in pairs( ply.powers ) do
				if v.class == "a_shuriken" then
					v:setCooldown( math.floor( v.baseCooldown/2 ) )
				end
			end
		end

		local dmginfo = DamageInfo()
		dmginfo:SetDamageType( DMG_SLASH )
		dmginfo:SetDamage( self.damage )
		dmginfo:SetDamageForce( colData.OurOldVelocity*600 )
		dmginfo:SetAttacker( self:GetOwner() or self )
		dmginfo:SetInflictor( self )
		colData.HitEntity:TakeDamageInfo( dmginfo )
		self:EmitSound( "npc/fast_zombie/claw_strike"..math.random( 1, 3 )..".wav" )
		self:Remove()

	elseif colData.HitEntity:IsWorld() then

		self:SetMoveType( MOVETYPE_NONE )
		self:SetCollisionGroup( COLLISION_GROUP_NONE )
		self:EmitSound( tostring( table.Random( hitSounds ) ) )
		local delay = CurTime() + 3
		self.Think = function( self )
			if CurTime() > delay then
				self:Remove()
			end
		end

	end
end
