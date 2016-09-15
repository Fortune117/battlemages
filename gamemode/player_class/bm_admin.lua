

local PLAYER = {}

PLAYER.DisplayName				= "Abusive Admin"

PLAYER.MaxHealth				= 200		-- Max health we can have
PLAYER.StartHealth				= 200		-- How much health we start with
PLAYER.StartArmor				= 0			-- How much armour we start with
PLAYER.WalkSpeed				= 370		-- How fast to move when not running
PLAYER.RunSpeed					= 370		-- How fast to move when running
PLAYER.JumpPower				= 320		-- How powerful our jump should be
PLAYER.CrouchedWalkSpeed		= 0.5		-- Multiply move speed by this when crouching
PLAYER.DuckSpeed				= 0.25		-- How fast to go from not ducking, to ducking
PLAYER.UnDuckSpeed				= 0.3		-- How fast to go from ducking, to not ducking
PLAYER.baseHealthRegen 			= 0  		-- The base rate the player will regenerate health.

PLAYER.playerModel 				= Model( "models/player/kleiner.mdl" )

PLAYER.CanUseFlashlight			= false		-- Can we use the flashlight
PLAYER.UseVMHands				= true		-- Uses viewmodel hands

PLAYER.passives =
{
}

PLAYER.powers 	=
{
	[ IN_USE ] = "a_powerslap",
	[ IN_SPEED ] = "a_noclip"
}

PLAYER.ult = "u_godmode"
PLAYER.maxUltCharge = 50

function PLAYER:Loadout()

	self.Player:Give( "weapon_bm_banhammer" )

end

player_manager.RegisterClass( "bm_admin", PLAYER, "bm_base" )
