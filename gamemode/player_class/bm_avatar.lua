

local PLAYER = {}

PLAYER.DisplayName				= "Avatar"

PLAYER.MaxHealth				= 300		-- Max health we can have
PLAYER.StartHealth				= 300		-- How much health we start with
PLAYER.StartArmor				= 0			-- How much armour we start with
PLAYER.WalkSpeed				= 410		-- How fast to move when not running
PLAYER.RunSpeed					= 410		-- How fast to move when running
PLAYER.JumpPower				= 390		-- How powerful our jump should be
PLAYER.CrouchedWalkSpeed		= 0.45		-- Multiply move speed by this when crouching
PLAYER.DuckSpeed				= 0.25		-- How fast to go from not ducking, to ducking
PLAYER.UnDuckSpeed				= 0.3		-- How fast to go from ducking, to not ducking
PLAYER.baseHealthRegen 			= 1  		-- The base rate the player will regenerate health.

PLAYER.playerModel 				= Model( "models/player/kleiner.mdl" )

PLAYER.CanUseFlashlight			= false		-- Can we use the flashlight
PLAYER.UseVMHands				= true		-- Uses viewmodel hands

PLAYER.passives =
{
	"p_vamp" 
}

PLAYER.powers 	=
{
	[ IN_USE ] 		= "a_windwalk",
	[ IN_SPEED ] 	= "a_rockspike"
}

function PLAYER:Loadout()

	self.Player:Give( "weapon_bm_fists" )

end


player_manager.RegisterClass( "bm_avatar", PLAYER, "bm_base" )
