

local PLAYER = {}

PLAYER.DisplayName				= "Minge"

PLAYER.MaxHealth				= 150		-- Max health we can have
PLAYER.StartHealth				= 150		-- How much health we start with
PLAYER.StartArmor				= 0			-- How much armour we start with
PLAYER.WalkSpeed				= 450		-- How fast to move when not running
PLAYER.RunSpeed					= 450		-- How fast to move when running
PLAYER.JumpPower				= 400		-- How powerful our jump should be
PLAYER.CrouchedWalkSpeed		= 0.8		-- Multiply move speed by this when crouching
PLAYER.DuckSpeed				= 0.2		-- How fast to go from not ducking, to ducking
PLAYER.UnDuckSpeed				= 0.2		-- How fast to go from ducking, to not ducking
PLAYER.baseHealthRegen 			= 0  		-- The base rate the player will regenerate health.

PLAYER.playerModel 				= Model( "models/player/kleiner.mdl" )

PLAYER.CanUseFlashlight			= false		-- Can we use the flashlight
PLAYER.UseVMHands				= true		-- Uses viewmodel hands

PLAYER.passives =
{
}

PLAYER.powers 	=
{
	[ IN_USE ] = "a_propshield",
	[ IN_SPEED ] = "a_propsurf"
}

PLAYER.ult = "u_propspam"
PLAYER.maxUltCharge = 700

function PLAYER:Loadout()

	self.Player:Give( "weapon_bm_akminge" )

end

player_manager.RegisterClass( "bm_minge", PLAYER, "bm_base" )
