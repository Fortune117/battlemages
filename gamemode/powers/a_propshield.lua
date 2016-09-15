
local ACTIVE = {}

ACTIVE.name 						= "Base Active" 	-- Name
ACTIVE.baseCooldown 				= 13				-- Base cooldown - note that is the "base" cooldown, because we may want to modify it.

ACTIVE.cooldownType 				= COOLDOWN_INSTANT	-- Determines the cooldown type.
ACTIVE.castType 					= CAST_INSTANT		-- Cast type.

ACTIVE.delay 						= 0.2 				-- The delay when the cast type is set to CAST_DELAY

ACTIVE.animation 					= PLAYER_ATTACK1	-- Animation that should be played when the ability is cast.
ACTIVE.shouldPlayAnimation 			= false 				-- Determines whether or not the animation should be played.

ACTIVE.viewModelAnimation 			= nil 				-- Specifies a viewmodel animation that should be played.
ACTIVE.shouldPlayViewModelAnimation = false 			-- Determines whether or not the viewmodel animation should play.

function ACTIVE:init( ply ) -- Called when the ability is loaded into the players data table.
end

function ACTIVE:onBeginCasting( ply ) -- Called when the ability is beginning to be cast, useful for abilities with delayed casts.
end

function ACTIVE:preCast( ply ) -- Called just before the ability is actually cast.
end

function ACTIVE:cast( ply ) -- This should be the "meat" of the ability.
    ply:giveBuff( "buff_propshield" )
end

function ACTIVE:postCast( ply ) -- Called after the ability was cast.
end

function ACTIVE:castThink( ply ) -- This is run immediately after the above function.
end

function ACTIVE:think( ply ) -- This constantly runs.
end


BM:addPower( "a_propshield", ACTIVE, "active_base" )
