-- simple unloack effect :/

--Initializes the effect. The data is a table of data 
--which was passed from the server.

EFFECT.sideSpeed 	= 15
EFFECT.area 		= 10
EFFECT.circleSpeed 	= 400
function EFFECT:Init( data )
	
	
	local Pos = data:GetOrigin()
	local ent = data:GetEntity() 
	local eVel = ent:GetVelocity()

	local Norm = Vector(0,0,1)
	
	Pos = Pos + Norm * 6

	local emitter = ParticleEmitter( Pos )
	
	for i = 1, math.random( 25, 35 ) do
		
		local spawnPos = Pos + Vector( math.random( -self.area, self.area ), math.random( -self.area, self.area ), math.random( 0, 30 ) )
		local particle = emitter:Add( "particles/smokey", spawnPos )

		local mov = Vector( math.random( -self.sideSpeed, self.sideSpeed ), math.random( -self.sideSpeed, self.sideSpeed ), math.random( -5, 100 ) )

		particle:SetVelocity( mov )
		particle:SetDieTime( math.Rand( 2.5, 4 ) )
		particle:SetStartAlpha( 150 )
		particle:SetStartSize( math.random( 15, 40 ) )
		particle:SetEndSize( math.random( 40, 55 ) )
		particle:SetRoll( math.Rand( 360, 480 ) )
		particle:SetRollDelta( math.Rand( -1, 1 ) )
		particle:SetColor( Color( 255, 255, 255 ) )

	end

	emitter:Finish()

	local emitter2 = ParticleEmitter( Pos ) 
	
	local deg = (math.pi*2)/72
	for i = 1,72 do 
		local a = i*deg 
		local x = math.cos( a )
		local y = math.sin( a )
		local norm = ( Vector( Pos.x + x, Pos.y + y, Pos.z ) - Pos ):GetNormalized()

		local spawnPos = Pos 
		local particle = emitter2:Add( "particles/smokey", spawnPos )

		particle:SetVelocity( norm*self.circleSpeed )
		particle:SetDieTime( math.Rand( 1, 2 ) )
		particle:SetStartAlpha( 150 )
		particle:SetStartSize( math.random( 30, 35 ) )
		particle:SetEndSize( math.random( 35, 40 ) )
		particle:SetRoll( math.Rand( 360, 480 ) )
		particle:SetRollDelta( math.Rand( -1, 1 ) )
		particle:SetColor( Color( 255, 255, 255 ) )
		particle:SetAirResistance( 150 )


	end 

	emitter2:Finish()
end 


function EFFECT:Think( )
	return true
end

-- Draw the effect
function EFFECT:Render()
	-- Do nothing - this effect is only used to spawn the particles in Init	
end



