
local ACTIVE = {}

ACTIVE.name 						= "Roll the Dice" 	-- Name
ACTIVE.baseCooldown 				= 5 				-- Base cooldown - note that is the "base" cooldown, because we may want to modify it.

ACTIVE.cooldownType 				= COOLDOWN_INSTANT	-- Determines the cooldown type.
ACTIVE.castType 					= CAST_INSTANT		-- Cast type.

ACTIVE.delay 						= 0.2 				-- The delay when the cast type is set to CAST_DELAY

ACTIVE.animation 					= PLAYER_ATTACK1	-- Animation that should be played when the ability is cast.
ACTIVE.shouldPlayAnimation 			= false			    -- Determines whether or not the animation should be played.

ACTIVE.viewModelAnimation 			= nil 				-- Specifies a viewmodel animation that should be played.
ACTIVE.shouldPlayViewModelAnimation = false 			-- Determines whether or not the viewmodel animation should play.

-- Good Effects
local infAmmo       = { "Infinite Ammo", "buff_rtd_infiniteammo" }
local rapidFire     = { "Rapid Fire", "buff_rtd_rapidfire" }
local godMode       = { "God Mode", "buff_rtd_god" }
local superSpeed    = { "Super Speed", "buff_rtd_sspeed" }
local lowGravity    = { "Low Gravity", "buff_rtd_lowgrav" }
local superGun      = { "the Super Gun", "buff_rtd_supergun" }
local vamparism     = { "Vamparism", "buff_rtd_vamparism" }
local taser         = { "Taser Rounds", "buff_rtd_taser" }

-- Bad Effects
local instantDeath   = { "Instant Death", "buff_rtd_death" }
local superSlow      = { "Super Slow", "buff_rtd_sslow" }
local rubberBullets  = { "Rubber Bullets", "buff_rtd_rubberbullets" }

local rtdRolls =
{
    -- Bad
    instantDeath,
    superSlow,
    rubberBullets,

    -- Good
    infAmmo,
    rapidFire,
    godMode,
    superSpeed,
    lowGravity,
    superGun,
    vamparism,
    taser
}
local anNums =
{
    [ 8 ] = true,
    [ 18 ] = true
}
local function getPrefix( n )
    if anNums[ n ] then return "an" else return "a" end
end
function ACTIVE:cast( ply ) -- This should be the "meat" of the ability.
    local n = math.random( 1, #rtdRolls )
    ef = rtdRolls[ n ]
    ply:giveBuff( ef[ 2 ] )
    for k,v in pairs( player.GetAll() ) do
        if v ~= ply then
            v:ChatPrint( ply:Nick().." has rolled "..getPrefix( n ).." "..n.." and got "..ef[ 1 ].." for 10 seconds!" )
        end
    end
    ply:ChatPrint( "You rolled a "..n.." and got "..ef[ 1 ].." for 10 seconds!" )
end

BM:addPower( "u_rtd", ACTIVE, "active_base" )
