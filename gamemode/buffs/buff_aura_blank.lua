
AURA_EFFECT_ALL 	= 0
AURA_EFFECT_TEAM 	= 1
AURA_EFFECT_ENEMY 	= 1

local BUFF = {}

BUFF.name 			= "Base Aura"		-- Name.
BUFF.type 			= ABILITY_AURA 		-- Ability type.
BUFF.targetType 	= AURA_EFFECT_ALL 	-- Who the aura should effect.
BUFF.radius 		= 300 				-- The radius of the aura.
BUFF.includeSelf 	= true 				-- Should the aura target the owner?

function BUFF:initInternal() -- Internal, shouldn't need to modify this, use the init function instead.
	self.radius = self.radius^2 -- This is done so that it runs more efficiently.
	self.players = {}
	self.__delayTime = 0
	self.__delay = 0.1
	self.baseClass.initInternal( self )
end

function BUFF:getPlayers() -- Returns all the players currently in the aura.
	return self.players
end

function BUFF:addPlayer( ply ) -- Adds a player to the aura.
	local id = (ply:IsBot() and ply:Nick() or ply:SteamID())
	self.players[ id ] = ply
	self:onPlayerEnter( ply )
end

function BUFF:removePlayer( ply ) -- Removes a player from the aura.
	local id = (ply:IsBot() and ply:Nick() or ply:SteamID())
	self.players[ id ] = nil
	self:onPlayerExit( ply )
end

function BUFF:getRadius() -- Returns the radius of the aura.
	return self.radius
end

function BUFF:onRefresh( ply ) -- Called when the buff is applied again and it doesn't stack.
end

function BUFF:onApply( ply ) -- Called when the buff is applied.
end

function BUFF:onRemove( ply ) -- Called when the buff is removed.
end

function BUFF:onPlayerEnter( ply ) -- Called when a player enters the aura.
end

function BUFF:onPlayerExit( ply ) -- Called when a player exits the aura.
end

function BUFF:auraThink( ply ) -- This is called for each player in the aura every 0.1 seconds. Think tickrate of 10, the delay can be modified in internal init function.
end

function BUFF:auraDeath( ply, atk, dmginfo ) -- Called when someone in the aura dies.
end

function BUFF:think( ply ) -- Mostly internal. Since auras are actually modified passives, we just overwrite the think function.

	if CurTime() > self.__delayTime then

		local affectedPlayers = self:getPlayers()
		local pos = ply:GetPos()
		for k,v in pairs( player.GetAll() ) do

			if self.targetType == AURA_EFFECT_TEAM and v:Team() ~= ply:Team() then continue end
			if self.targetType == AURA_EFFECT_ENEMY and v:Team() == ply:Team() then continue end
			if not self.includeSelf and ply == v then continue end

			local targPos = v:GetPos()
			local dist = pos:DistToSqr( targPos )
			local inrange = dist < self:getRadius()

			local id = (v:IsBot() and v:Nick() or v:SteamID())
			local hasPlayer = false
			if affectedPlayers[ id ] then
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

		for k,v in pairs( self:getPlayers() ) do
			if IsValid( v ) then
				self:auraThink( v )
			else
				self:removePlayer( v )
			end
		end

		self.__delayTime = CurTime() + self.__delay
	end

end

function BUFF:onPlayerDeath( ply, atk, dmginfo ) -- This is mostly internal as well. We just borrow this function from the passive base and make it call auradeath.
	local id = (ply:IsBot() and ply:Nick() or ply:SteamID())
	if self:getPlayers()[ id ] then
		self:auraDeath( ply, atk, dmginfo )
	end
end

function BUFF:keyPress( ply, key ) -- Called when the player presses a key.
end

function BUFF:onHitGround( ply, inWater, isFloater, speed ) -- Called when the player hits the ground.
end

function BUFF:onTakeDamage( ply, atk, dmginfo ) -- Called when the player takes damage.
end

function BUFF:onDealDamage( ply, vic, dmginfo ) -- Called when the player deals damage.
end

function BUFF:onKill( ply, vic, dmginfo ) -- Called when the player kills another.
end

function BUFF:onKilled( ply, atk, dmginfo )	-- Called when the player is killed by another player.
end

function BUFF:playerDeath( ply, atk, dmginfo ) -- Called when the buff target dies.
end

function BUFF:onAbilityUsed( ply, ability )	-- Called when the player uses an ability.
end

function BUFF:onPlayerAbilityUsed( ply, ability )	-- Called when ANYONE uses an ability.
end

function BUFF:reloadMod( ply ) -- Called when the player goes to reload their weapon. Can be used to modify reload speed.
	return 1
end

function BUFF:onFireWeapon()
end


BM:addBuff( "buff_aura_blank", BUFF, "buff_aura_base" )
