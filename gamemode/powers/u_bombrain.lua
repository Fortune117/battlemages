
local ACTIVE = {}

ACTIVE.name 						= "Bomb Dash"
ACTIVE.baseCooldown 				= 1

ACTIVE.cooldownType 				= COOLDOWN_INSTANT
ACTIVE.castType 					= CAST_INSTANT

ACTIVE.animation 					= PLAYER_ATTACK1
ACTIVE.shouldPlayAnimation 			= false

ACTIVE.bombData =
{
	duration 	= 5,
	projectiles = 48,
	damage 		= 45,
	delay 		= 1,
	force 		= 1200,
	spread 		= 0.5,
	radius 		= 200,
}

function ACTIVE:cast( ply )

	local pos = ply:GetShootPos()
	local dir = ply:GetAimVector()

	local bomb = ents.Create( "bm_bombrain" )
	bomb:SetPos( pos )
	bomb:SetOwner( ply )
	bomb:Spawn()

	bomb:fling( dir, self.bombData )

	ply:EmitSound( "weapons/crossbow/fire1.wav" )

end

BM:addPower( "u_bombrain", ACTIVE, "active_base" )
