
EFFECT.numParticles = 54
EFFECT.circleSpeed 	= 400
EFFECT.airRes 		= 350
EFFECT.numGibs 		= 20
EFFECT.liveTime = 5

local debrisMats =
{
	"particle/particle_noisesphere",
	"particle/particle_debris_02",
	"particle/particle_debris_01"
}
local smokeMat = "particle/smokesprites_000"

local gibModels = {
	Model("models/props_debris/concrete_chunk04a.mdl"),
	Model("models/props_debris/concrete_chunk05g.mdl"),
	Model("models/props_debris/concrete_chunk06c.mdl"),
	Model("models/props_debris/concrete_chunk06d.mdl"),
	Model("models/props_debris/concrete_chunk07a.mdl"),
	Model("models/props_debris/concrete_chunk08a.mdl"),
	Model("models/props_debris/concrete_chunk09a.mdl")
}

function EFFECT:Init( data )


	local pos = data:GetOrigin()
	local norm = data:GetNormal()
	local emitter = ParticleEmitter( pos )

	local up = norm:Angle():Up()
	local right = norm:Angle():Right()

	local deg = (math.pi*2/self.numParticles)

	for i = 1,self.numParticles*2 do

		local particle = emitter:Add( table.Random( debrisMats ), pos )

		local x = math.cos( i*deg )
		local y = math.sin( i*deg )

		local n = up*y + right*x

		particle:SetVelocity( n*self.circleSpeed*2 )
		particle:SetDieTime( math.Rand( 1.2, 2.5 ) )
		particle:SetStartAlpha( 255 )
		particle:SetStartSize( math.random( 30, 24 ) )
		particle:SetEndSize( math.random( 28, 18 ) )
		particle:SetRoll( math.Rand( 360, 480 ) )
		particle:SetRollDelta( math.Rand( -1, 1 ) )
		particle:SetColor( Color( 255, 255, 255, 255 ) )
		particle:SetAirResistance( self.airRes  )

	end

	for i = 1,self.numParticles do

		local particle2 = emitter:Add( smokeMat..math.random( 1, 9 ), pos )

		local x = math.cos( i*deg )
		local y = math.sin( i*deg )

		local n = up*y + right*x

		particle2:SetVelocity( n*self.circleSpeed )
		particle2:SetDieTime( math.Rand( 1.2, 3 ) )
		particle2:SetStartAlpha( 255 )
		particle2:SetStartSize( math.random( 42, 36 ) )
		particle2:SetEndSize( math.random( 28, 18 ) )
		particle2:SetRoll( math.Rand( 360, 480 ) )
		particle2:SetRollDelta( math.Rand( -1, 1 ) )
		particle2:SetColor( Color( 255, 255, 255, 255 ) )
		particle2:SetAirResistance( self.airRes  )

	end

	self.gibs = {}
	for i = 1,self.numGibs do

		self.gibs[ i ] = ents.CreateClientProp( tostring( table.Random( gibModels ) ) )
		local gib = self.gibs[ i ]
		gib:SetPos( pos + norm*2 )
		gib:Spawn()

		gib:PhysicsInitSphere( 2, "concrete" )
		gib:SetCollisionGroup( COLLISION_GROUP_WORLD )
		gib:SetMoveType( MOVETYPE_VPHYSICS )

		local n = up*math.random( -500, 500 ) + right*math.random( -500, 500 ) + norm*math.random( 100, 600 )

		gib:GetPhysicsObject():SetVelocity( n )
		gib:GetPhysicsObject():AddAngleVelocity( VectorRand()*100 )


	end

	self.dieTime = CurTime() + self.liveTime

	emitter:Finish()


end


function EFFECT:Think( )
	if CurTime() < self.dieTime then
		return true
	end
	for i = 1,#self.gibs do
		self.gibs [ i ]:Remove()
	end
	return false
end

-- Draw the effect
function EFFECT:Render()
	-- Do nothing - this effect is only used to spawn the particles in Init
end
