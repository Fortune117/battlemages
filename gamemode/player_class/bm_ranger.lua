

local PLAYER = {}

PLAYER.DisplayName				= "Ranger"

PLAYER.MaxHealth				= 175		-- Max health we can have
PLAYER.StartHealth				= 175		-- How much health we start with
PLAYER.StartArmor				= 0			-- How much armour we start with
PLAYER.WalkSpeed				= 410		-- How fast to move when not running
PLAYER.RunSpeed					= 410		-- How fast to move when running
PLAYER.JumpPower				= 330		-- How powerful our jump should be
PLAYER.CrouchedWalkSpeed		= 0.5		-- Multiply move speed by this when crouching
PLAYER.DuckSpeed				= 0.25		-- How fast to go from not ducking, to ducking
PLAYER.UnDuckSpeed				= 0.3		-- How fast to go from ducking, to not ducking
PLAYER.baseHealthRegen 			= 0  		-- The base rate the player will regenerate health.

PLAYER.playerModel 				= Model( "models/player/kleiner.mdl" )

PLAYER.CanUseFlashlight			= false		-- Can we use the flashlight
PLAYER.UseVMHands				= true		-- Uses viewmodel hands

PLAYER.passives =
{
	"p_doublejump"
}

PLAYER.powers 	=
{
	[ IN_USE ] = "a_tripmine",
	[ IN_SPEED ] = "a_shuriken"
}

PLAYER.ult = "u_shadowwalk"
PLAYER.maxUltCharge = 10


function PLAYER:Loadout()

	self.Player:Give( "weapon_bm_sniper" )

end

player_manager.RegisterClass( "bm_ranger", PLAYER, "bm_base" )
