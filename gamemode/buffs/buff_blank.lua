
local BUFF = {}

BUFF.name 		= "Buff Blank" 	-- Buff name.
BUFF.canStack 	= false 		-- Can the buff stack?
BUFF.duration 	= 1 			-- The duration of the buff.

-- Buffs are a great way of adding temporary "passives" to a player. They can shorten ability code by a lot and are generally just really neato.

function BUFF:init() -- Called when the buff is loaded.
end

function BUFF:onRefresh( ply ) -- Called when the buff is applied again and it doesn't stack.
end

function BUFF:onApply( ply ) -- Called when the buff is applied.
end

function BUFF:onRemove( ply ) -- Called when the buff is removed.
end

function BUFF:think() -- Called every tick.
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

function BUFF:onPlayerDeath( ply, atk, dmginfo ) -- Called when ANY player dies.
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

BM:addBuff( "buff_blank", BUFF, "buff_base" )
