

local PLAYER = {}

PLAYER.DisplayName				= "RNGesus"

PLAYER.MaxHealth				= 250		-- Max health we can have
PLAYER.StartHealth				= 250		-- How much health we start with
PLAYER.StartArmor				= 0			-- How much armour we start with
PLAYER.WalkSpeed				= 350		-- How fast to move when not running
PLAYER.RunSpeed					= 350		-- How fast to move when running
PLAYER.JumpPower				= 350		-- How powerful our jump should be
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
	[ IN_USE ] = "a_rngheal",
	[ IN_SPEED ] = "a_rngbuffs" 
}

PLAYER.ult = "u_rtd"
PLAYER.maxUltCharge = 10

function PLAYER:Loadout()

	self.Player:Give( "weapon_bm_rngshotgun" )

end

player_manager.RegisterClass( "bm_rng", PLAYER, "bm_base" )
