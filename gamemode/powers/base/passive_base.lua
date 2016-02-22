
local PASSIVE = {}

PASSIVE.name 	= "Base Passive" 	-- Name 
PASSIVE.type 	= ABILITY_PASSIVE 	-- Ability type. 

function PASSIVE:initInternal( ply ) -- Called internally, basically, if you're making your own passive base and something always needs to be defined, overwrite this function and put it here.
end 

function PASSIVE:init( ply ) -- Called when the passive is loaded. 
end 

function PASSIVE:playerSpawn( ply ) -- Called when the passive owner spawns. 
end 

function PASSIVE:playerDeath( ply, atk, dmginfo ) -- Called when the passive owner dies. 
end 

function PASSIVE:think( ply ) -- Called every tick. 
end 

function PASSIVE:keyPress( ply, key ) -- Called when the passive owner presses a key. 
end 

function PASSIVE:onHitGround( ply, inWater, isFloater, speed ) -- Called when the passive owner hits the ground. 
end  

function PASSIVE:onTakeDamage( ply, atk, dmginfo ) -- Called when the passive owner takes damage.
end 

function PASSIVE:onDealDamage( ply, vic, dmginfo ) -- Called when the passive owner deals damage. 
end 

function PASSIVE:onKill( ply, vic, dmginfo ) -- Called when the passive owner kills a player.
end 

function PASSIVE:onKilled( ply, atk, dmginfo ) -- Called when the passive owner is killed by another player. 
end 

function PASSIVE:onPlayerDeath( ply, atk, dmginfo ) -- Called whenever ANY player dies. 
end 

function PASSIVE:onAbilityUsed( ply, ability ) 	-- Called when the passive owner uses an ability.
end 

function PASSIVE:onPlayerAbilityUsed( ply, ability ) -- Called whenver ANY player uses an ability.
end 

function PASSIVE:reloadMod( ply ) -- Called when the player goes to reload their weapon. Can be used to modify reload speed.
	return 1 
end 

function PASSIVE:onFireWeapon( ply, wep ) -- Called when the player fires their weapon.
end 

BM:addPassive( "passive_base", PASSIVE )