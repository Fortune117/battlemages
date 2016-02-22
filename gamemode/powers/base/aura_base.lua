
AURA_EFFECT_ALL 	= 0
AURA_EFFECT_TEAM 	= 1
AURA_EFFECT_ENEMY 	= 1 

local AURA = {}

AURA.name 			= "Base Aura"		-- Name.
AURA.type 			= ABILITY_AURA 		-- Ability type.
AURA.targetType 	= AURA_EFFECT_ALL 	-- Who the aura should effect.
AURA.radius 		= 300 				-- The radius of the aura.
AURA.includeSelf 	= true 				-- Should the aura target the owner?

function AURA:initInternal() -- Internal, shouldn't need to modify this, use the init function instead.
	self.radius = self.radius^2 -- This is done so that it runs more efficiently. 
	self.players = {}
	self.__delayTime = 0 
	self.__delay = 0.1
end 

function AURA:getPlayers() -- Returns all the players currently in the aura.
	return self.players 
end 

function AURA:addPlayer( ply ) -- Adds a player to the aura.
	self.players[ ply:SteamID() ] = ply 
	self:onPlayerEnter( ply )
end 

function AURA:removePlayer( ply ) -- Removes a player from the aura.
	self.players[ ply:SteamID() ] = nil 
	self:onPlayerExit( ply )
end 

function AURA:getRadius() -- Returns the radius of the aura. 
	return self.radius 
end 

function AURA:onPlayerEnter( ply ) -- Called when a player enters the aura.
end 

function AURA:onPlayerExit( ply ) -- Called when a player exits the aura. 
end 

function AURA:auraThink( ply ) -- This is called for each player in the aura every 0.1 seconds. Think tickrate of 10, the delay can be modified in internal init function.
end 

function AURA:auraDeath( ply, atk, dmginfo ) -- Called when someone in the aura dies. 
end 

function AURA:think( ply ) -- Mostly internal. Since auras are actually modified passives, we just overwrite the think function.

	if CurTime() > self.__delayTime then 

		local affectedPlayers = self:getPlayers()
		local pos = ply:GetPos()
		for k,v in pairs( player.GetAll() ) do 

			if self.targetType == AURA_EFFECT_TEAM and v:Team() ~= ply:Team() then continue end 
			if self.targetType == AURA_EFFECT_ENEMY and v:Team() == ply:Team() then continue end 
			if not self.includeSelf and ply == v then continue end 
			if not v:Alive() then continue end 

			local targPos = v:GetPos()
			local dist = pos:DistToSqr( targPos )
			local inrange = dist < self:getRadius() 

			local hasPlayer = false 
			if affectedPlayers[ v:SteamID() ] then 
				hasPlayer = true 
			end 

			if hasPlayer and not v:Alive() then
				self:removePlayer( v )
			elseif inrange and not hasPlayer then 
				self:addPlayer( v )
			elseif not inrange and hasPlayer then 
				self:removePlayer( v ) 
			end 


		end 

		for k,v in pairs( affectedPlayers ) do 
			if IsValid( v ) then 
				self:auraThink( v )
			else 
				self:removePlayer( v )
			end 
		end 

		self.__delayTime = CurTime() + self.__delay 
	end 

end 

function AURA:onPlayerDeath( ply, atk, dmginfo ) -- This is mostly internal as well. We just borrow this function from the passive base and make it call auradeath.
	if self:getPlayers()[ ply:SteamID() ] then 
		self:auraDeath( ply, atk, dmginfo )
	end 
end 


BM:addPassive( "aura_base", AURA, "passive_base" )