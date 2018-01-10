
EFFECT.numParticles = 64
EFFECT.circleSpeed 	= 1200
EFFECT.airRes 		= 250
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

local earthBreakModel = Model( "models/props_debris/concrete_debris128pile001a.mdl" )
local holeModel = Model( "models/turtle/hell_hole_rim.mdl" )

function EFFECT:Init( data )

	self.dieTime = CurTime() + self.liveTime

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
		particle:SetColor( 60, 49, 12 )
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
		particle2:SetColor( 60, 49, 12 )
		particle2:SetAirResistance( self.airRes  )

	end

	self.gibs = {}
	for i = 1,self.numGibs do

		self.gibs[ i ] = ents.CreateClientProp( )
		local gib = self.gibs[ i ]
		gib:SetModel( table.Random( gibModels ) )
		gib:SetPos( pos + norm*2 )
		gib:Spawn()

		local sz = Vector( 5, 5, 5 )
		gib:PhysicsInitBox( -sz, sz )
		gib:SetCollisionGroup( COLLISION_GROUP_WORLD )
		gib:SetMoveType( MOVETYPE_VPHYSICS )

		local n = up*math.random( -500, 500 ) + right*math.random( -500, 500 ) + norm*math.random( 100, 600 )

		gib:GetPhysicsObject():SetVelocity( n )
		gib:GetPhysicsObject():AddAngleVelocity( VectorRand()*100 )


	end

	for i = 1,4 do -- filthy

		self.gibs[ #self.gibs + 1 ] = ents.CreateClientProp() --not technically a gib, but it gets removed this way.
		local hole = self.gibs[ #self.gibs ]
		hole:SetModel( holeModel )
		hole:SetPos( pos - norm*2 )
		hole:SetAngles( norm:Angle() + Angle( 90, 0, 0 ) )

		local j = i - 1

		local scale = Vector( 0.14 - j*0.011, 0.14 - j*0.011, 0.3 + j*0.1 )*1.2
		local mat = Matrix()
		mat:Scale( scale )
		hole:EnableMatrix( "RenderMultiply", mat )

	end



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
