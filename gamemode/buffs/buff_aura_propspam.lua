
AURA_EFFECT_ALL 	= 0
AURA_EFFECT_TEAM 	= 1
AURA_EFFECT_ENEMY 	= 1

local BUFF = {}

BUFF.name 			= "Propspam Aura"		-- Name.
BUFF.type 			= ABILITY_AURA 		-- Ability type.
BUFF.targetType 	= AURA_EFFECT_ALL 	-- Who the aura should effect.
BUFF.radius 		= 400 				-- The radius of the aura.
BUFF.includeSelf 	= false				-- Should the aura target the owner?
BUFF.canStack 		= false 		-- Can the buff stack?
BUFF.duration 		= 6 			-- The duration of the buff.

BUFF.propDamage 	= 100
BUFF.propForce 		= 7000
BUFF.fireDelay 		= 0.75

function BUFF:init()
	self.lastFireTime = CurTime()
end

function BUFF:think( ply ) -- This is called for each player in the aura every 0.1 seconds. Think tickrate of 10, the delay can be modified in internal init function.
	self.baseClass.think( self, ply )
	if CurTime() > self.lastFireTime then
		local plys = self:getPlayers()
		for k,v in pairs( plys ) do
			local prop = ents.Create( "bm_propspamprop" )
			prop:Spawn()
			prop:SetOwner( ply )
			prop:SetPos( ply:GetPos() + Vector( 0, 0, 65 ) )
			prop:SetPhysicsAttacker( ply, 6 )
			prop:fling( v, self.propForce, self.propDamage )
		end
		self.lastFireTime = CurTime() + self.fireDelay
	end
end

BM:addBuff( "buff_aura_propspam", BUFF, "buff_aura_base" )
