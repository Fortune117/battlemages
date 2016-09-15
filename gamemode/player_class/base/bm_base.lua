

local PLAYER = {}

PLAYER.DisplayName			= "Default Class"

PLAYER.MaxHealth				= 200		-- Max health we can have
PLAYER.StartHealth				= 200		-- How much health we start with
PLAYER.StartArmor				= 0			-- How much armour we start with
PLAYER.WalkSpeed				= 450		-- How fast to move when not running
PLAYER.RunSpeed					= 450		-- How fast to move when running
PLAYER.JumpPower				= 450		-- How powerful our jump should be
PLAYER.CrouchedWalkSpeed		= 0.5		-- Multiply move speed by this when crouching
PLAYER.DuckSpeed				= 0.25		-- How fast to go from not ducking, to ducking
PLAYER.UnDuckSpeed				= 0.3		-- How fast to go from ducking, to not ducking
PLAYER.baseHealthRegen 			= 1 		-- The base rate the player will regenerate health.

PLAYER.playerModel 				= Model( "models/player/kleiner.mdl" )

PLAYER.CanUseFlashlight			= false		-- Can we use the flashlight
PLAYER.UseVMHands				= true		-- Uses viewmodel hands

/* 	This is the base player file. Most of the stuff in here should not need to be modified.
	I've done my best to try and keep everything simple, creating classes, abilities, buffs, w/e.
	So, I'll give you a run down.

	The passives table down there simply needs to contain the string name of the passive you wish the class to have.
	The game will load the powers for the player when their class initiates, might cause a bit of lag at the start of the round,
	but that's ok. It should be fine for the most part.

	The powers table below that handles active abilities. You can assign any key to an ability, but for the most part, you should stick
	with these four:
	IN_SPEED	-	Shift by default.
	IN_USE		-	E by default.
	IN_ATTACK2 	-	Right click by default.

	Just about everything in here is internal and shouldn't need to be modified - at all. If you have to, you can still call the
	function from the base file using self.BaseClass.funcname( self, args ).
*/

PLAYER.passives = { "p_doublejump" } -- Defines the passives the class should have.

PLAYER.powers 	= -- Defines the actives the class should have.
{
	[ IN_SPEED ] = "a_pounce"
}

PLAYER.ult 			= "a_pounce"
PLAYER.maxUltCharge = 1000


function PLAYER:SetupDataTables() -- Fuck me this is useful.

	self.Player:NetworkVar( "Float", 0, "Cooldown1" );
	self.Player:NetworkVar( "Float", 1, "Cooldown2" );
	self.Player:NetworkVar( "Float", 2, "Cooldown3" );
	self.Player:NetworkVar( "Float", 3, "Cooldown4" );
	self.Player:NetworkVar( "Float", 4, "ReloadMod" );

	self.Player:NetworkVar( "Float", 5, "UltCharge" );

end

function PLAYER:Init() -- Called when the player has the class set.

	self:loadPowers()
	self.Player.speedBoosts = {}
	self.Player.buffs 		= {}

	-- Detouring names because I like lowerCamel.
	self.Player.setCooldown1 = self.Player.SetCooldown1
	self.Player.getCooldown1 = self.Player.GetCooldown1

	self.Player.setCooldown2 = self.Player.SetCooldown2
	self.Player.getCooldown2 = self.Player.GetCooldown2

	self.Player.setCooldown3 = self.Player.SetCooldown3
	self.Player.getCooldown3 = self.Player.GetCooldown3

	self.Player.setCooldown4 = self.Player.SetCooldown4
	self.Player.getCooldown4 = self.Player.GetCooldown4

	self.Player.setReloadMod = self.Player.SetReloadMod
	self.Player.getReloadMod = self.Player.GetReloadMod

	self.Player.setUltCharge = self.Player.SetUltCharge
	self.Player.getUltCharge = self.Player.GetUltCharge

	self.Player:setUltCharge( 0 )

end

function PLAYER:loadPowers() -- Used to load and store all the powers for the player.
	local ply = self.Player
	ply.powers = {}
	for k,v in pairs( self.powers ) do
		ply.powers[ k ] = table.Copy( BM.powers[ v ] )
		ply.powers[ k ].player 	= ply
		ply.powers[ k ].key 	= k
		ply.powers[ k ]:initInternal( ply )
		ply.powers[ k ]:init( ply )
	end

	ply.ult = table.Copy( BM.powers[ self.ult ] )
	ply.ult.player = ply
	ply.ult:initInternal( ply )
	ply.ult:init( ply )

	ply.passives = {}
	for k,v in pairs( self.passives ) do
		ply.passives[ k ] = table.Copy( BM.passives[ v ] )
		ply.passives[ k ].player = ply
		ply.passives[ k ]:initInternal( ply )
		ply.passives[ k ]:init( ply )
	end
end

function PLAYER:resetActives() -- Cancels all abilities that are being casts and resets their cooldown. Called when the player dies.
	local ply = self.Player
	for k,v in pairs( ply.powers ) do
		v:setCasting( false )
		v:setCooldown( 0 )
	end
	ply.ult:setCasting( false )
	ply.ult:setCooldown( 0 )
end

function PLAYER:resetBuffs() -- Same as above, except for buffs.

	local ply = self.Player
	local b = self:getBuffs()
	for k,v in pairs( b ) do
		for i = 1,#v do
			v[ i ]:playerDeath( ply, atk, dmginfo )
			v[ i ]:remove()
		end
	end

end

function PLAYER:getClassData() -- Returns the whole player class
	return self
end

function PLAYER:getClassName() -- Returns the display name of the class.
	return self.DisplayName
end

function PLAYER:getPassives() -- Returns the players passives.
	return self.Player.passives
end

function PLAYER:getBuffs() -- Returns the players buffs.
	return self.Player.buffs
end

function PLAYER:getUlt()
	return self.Player.ult
end

function PLAYER:getMaxUltCharge()
	return self.maxUltCharge
end

function PLAYER:setClassPlayerModel() -- Set the players model based on the one specified in the class file.
	self.Player:SetModel( self.playerModel )
end

function PLAYER:Spawn() -- Called when the player spawns.

	local ply = self.Player
	local p = self:getPassives()
	for i = 1,#p do
		p[ i ]:playerSpawn( ply )
	end

end

function PLAYER:abilityCallbacks( ply, passives, buffs, power ) -- Called when the player casts an ability.
	for k,v in pairs( player.GetAll() ) do

		if v ~= ply then

			local p = player_manager.RunClass( v, "getPassives" )
			for i = 1,#p do
				p[ i ]:onPlayerAbilityUsed( ply, power )
			end

			local b = player_manager.RunClass( v, "getBuffs" )
			for k,v in pairs( b ) do
				for i = 1,#v do
					v[ i ]:onPlayerAbilityUsed( ply, power )
				end
			end

		else

			for i = 1,#passives do
				passives[ i ]:onAbilityUsed( ply, pwr )
			end

			for _,b in pairs( buffs ) do
				for i = 1,#b do
					b[ i ]:onAbilityUsed( ply, power )
				end
			end

		end

	end
end

function PLAYER:keyPress( key ) -- Called when the player presses a key.

	local ply = self.Player

	if ply:Alive() then
		local p = self:getPassives()
		for i = 1,#p do
			p[ i ]:keyPress( ply, key )
		end

		local b = self:getBuffs()
		for k,v in pairs( b ) do
			for i = 1,#v do
				v[ i ]:keyPress( ply, key )
			end
		end

		local pwr = ply.powers[ key ]
		if pwr then
			if pwr:canCast( ply ) then
				pwr:beginCast( ply )
				self:abilityCallbacks( ply, p, b, pwr )
			end
		end
	end

end

function PLAYER:removeSpeedBoost( id )
	local ply = self.Player
	local boosts = ply:getSpeedMultipliers()
	local boost = boosts[ id ]
	if boost then
		ply:SetWalkSpeed( ply:GetWalkSpeed() - self.WalkSpeed*boost.mul )
		ply:SetRunSpeed( ply:GetRunSpeed() - self.RunSpeed*boost.mul )
		boosts[ id ] = nil
	end
end


function PLAYER:think() -- Called each tick.

	local ply = self.Player
	local p = self:getPassives()
	for i = 1,#p do
		p[ i ]:think( ply )
	end

	local b = self:getBuffs()
	for k,v in pairs( b ) do
		for i = 1,#v do
			local buff = v[ i ]
			buff:think( ply )
			if CurTime() > buff:getRemoveTime() then
				ply:removeBuff( buff.class )
			end
		end
	end

	local p = ply.powers
	if ply:Alive() then
		for k,pwr in pairs( p ) do
			if pwr:isCasting() then
				pwr:internalCastThink( ply )
				pwr:castThink( ply )
			end
			pwr:think( ply )
		end

		local speedBoosts = ply:getSpeedMultipliers()
		for k,boost in pairs( speedBoosts ) do
			if CurTime() > boost.dur then
				self:removeSpeedBoost( k )
			end
		end
	end

end

function PLAYER:onHitGround( inWater, onFloater, speed ) -- Called when the player hits the ground.

	local ply = self.Player
	local p = self:getPassives()
	for i = 1,#p do
		p[ i ]:onHitGround( ply, inWater, onFloater, speed )
	end

	local b = self:getBuffs()
	for k,v in pairs( b ) do
		for i = 1,#v do
			v[ i ]:onHitGround( ply, inWater, onFloater, speed )
		end
	end

end

function PLAYER:onDeath( atk, dmginfo ) -- Called when the player dies.

	local ply = self.Player
	local p = self:getPassives()
	for i = 1,#p do
		p[ i ]:playerDeath( ply, atk, dmginfo )
	end
	ply.speedBoosts = {}

	for k,v in pairs( player.GetAll() ) do
		if v == ply then continue end
		local p = player_manager.RunClass( v, "getPassives" )
		for i = 1,#p do
			p[ i ]:onPlayerDeath( ply, atk, dmginfo )
		end
	end

	for k,v in pairs( player.GetAll() ) do
		local b = player_manager.RunClass( v, "getBuffs" )
		for _,buff in pairs( b ) do
			for i = 1,#buff do
				buff[ i ]:onPlayerDeath( ply, atk, dmginfo )
			end
		end
	end

	self:resetBuffs()

	self:resetActives()

	ply:Freeze( false )

	ply:setThirdPerson( false, 0, 0 )

end

function PLAYER:onTakeDamage( ply, atk, dmginfo ) -- Called when the player takes damage.

	local p = self:getPassives()
	for i = 1,#p do
		p[ i ]:onTakeDamage( ply, atk, dmginfo )
	end

	local b = self:getBuffs()
	for k,v in pairs( b ) do
		for i = 1,#v do
			v[ i ]:onTakeDamage( ply, atk, dmginfo )
		end
	end

end

function PLAYER:onDealDamage( ply, vic, dmginfo ) -- Called when the player deals damage.

	local p = self:getPassives()
	for i = 1,#p do
		p[ i ]:onDealDamage( ply, vic, dmginfo )
	end

	local b = self:getBuffs()
	for k,v in pairs( b ) do
		for i = 1,#v do
			v[ i ]:onDealDamage( ply, vic, dmginfo )
		end
	end

	local dmg = dmginfo:GetDamage()
	if vic:IsPlayer() then
		ply:addUltCharge( dmg )
	end

end

function PLAYER:onKill( ply, vic, dmginfo ) -- Called when the player kills another player.

	local p = self:getPassives()
	for i = 1,#p do
		p[ i ]:onKill( ply, vic, dmginfo )
	end

	local b = self:getBuffs()
	for k,v in pairs( b ) do
		for i = 1,#v do
			v[ i ]:onKill( ply, vic, dmginfo )
		end
	end

end

function PLAYER:onKilled( ply, atk, dmginfo ) -- Called when the player is killed by another player.

	local p = self:getPassives()
	for i = 1,#p do
		p[ i ]:onKilled( ply, atk, dmginfo )
	end

	local b = self:getBuffs()
	for k,v in pairs( b ) do
		for i = 1,#v do
			v[ i ]:onKilled( ply, atk, dmginfo )
		end
	end

end

function PLAYER:getReloadMod( ply )

	if SERVER then
		local mod = 1

		local p = self:getPassives()
		for i = 1,#p do
			mod = mod * p[ i ]:reloadMod( ply )
		end

		local b = self:getBuffs()
		for k,v in pairs( b ) do
			for i = 1,#v do
				mod = mod * v[ i ]:reloadMod( ply )
			end
		end
		ply:setReloadMod( mod )
		return mod
	else
		return ply:getReloadMod()
	end

end

function PLAYER:onFireWeapon( ply, wep )
	local p = self:getPassives()
	for i = 1,#p do
		p[ i ]:onFireWeapon( ply, wep )
	end

	local b = self:getBuffs()
	for k,v in pairs( b ) do
		for i = 1,#v do
			v[ i ]:onFireWeapon( ply, wep )
		end
	end
end

player_manager.RegisterClass( "bm_base", PLAYER, "player_default" )
