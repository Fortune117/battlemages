

local PLAYER = {}

PLAYER.DisplayName				= "Assassin"

PLAYER.MaxHealth				= 150		-- Max health we can have
PLAYER.StartHealth				= 150		-- How much health we start with
PLAYER.StartArmor				= 0			-- How much armour we start with
PLAYER.WalkSpeed				= 475		-- How fast to move when not running
PLAYER.RunSpeed					= 475		-- How fast to move when running
PLAYER.JumpPower				= 450		-- How powerful our jump should be
PLAYER.CrouchedWalkSpeed		= 0.5		-- Multiply move speed by this when crouching
PLAYER.DuckSpeed				= 0.25		-- How fast to go from not ducking, to ducking
PLAYER.UnDuckSpeed				= 0.3		-- How fast to go from ducking, to not ducking
PLAYER.baseHealthRegen 			= 1  		-- The base rate the player will regenerate health.

PLAYER.playerModel 				= Model( "models/player/kleiner.mdl" )

PLAYER.CanUseFlashlight			= false		-- Can we use the flashlight
PLAYER.UseVMHands				= true		-- Uses viewmodel hands

PLAYER.passives =
{ 
	"p_doublejump"
}

PLAYER.powers 	=
{
	[ IN_USE ] = "a_invis",
	[ IN_SPEED] = "a_expbullet"
}
 
function PLAYER:Loadout()

	self.Player:Give( "weapon_bm_sniper" )

end

player_manager.RegisterClass( "bm_assassin", PLAYER, "bm_base" )
