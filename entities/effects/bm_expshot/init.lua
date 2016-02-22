
EFFECT.numParticles = 72
EFFECT.circleSpeed 	= 300
EFFECT.airRes 		= 750
function EFFECT:Init( data )
	
	
	local pos = data:GetOrigin()
	local norm = data:GetNormal()
	local emitter = ParticleEmitter( pos )

	local up = norm:Angle():Up()
	local right = norm:Angle():Right()

	local deg = (math.pi*2/self.numParticles)
	for i = 1,self.numParticles do 

		local particle = emitter:Add( "particles/fire1", pos )

		local x = math.cos( i*deg )
		local y = math.sin( i*deg )

		local n = up*y + right*x

		particle:SetVelocity( n*self.circleSpeed )
		particle:SetDieTime( math.Rand( 0.8, 1 ) )
		particle:SetStartAlpha( 255 )
		particle:SetEndAlpha( 5 )
		particle:SetStartSize( 8 )
		particle:SetEndSize( 1  )
		particle:SetRoll( math.Rand( 360, 480 ) )
		particle:SetRollDelta( math.Rand( -1, 1 ) )
		particle:SetColor( Color( 255, 255, 255, 255 ) )
		particle:SetAirResistance( self.airRes  )



	end 

	emitter:Finish()

end 


function EFFECT:Think( )
	return true
end

-- Draw the effect
function EFFECT:Render()
	-- Do nothing - this effect is only used to spawn the particles in Init	
end



