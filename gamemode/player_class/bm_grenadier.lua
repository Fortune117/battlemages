

local PLAYER = {}

PLAYER.DisplayName				= "Grenadier"

PLAYER.MaxHealth				= 250		-- Max health we can have
PLAYER.StartHealth				= 250		-- How much health we start with
PLAYER.StartArmor				= 0			-- How much armour we start with
PLAYER.WalkSpeed				= 330		-- How fast to move when not running
PLAYER.RunSpeed					= 330		-- How fast to move when running
PLAYER.JumpPower				= 280		-- How powerful our jump should be
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
	[ IN_USE ] = "a_barrage",
	[ IN_SPEED ] = "a_bombdash"
}

PLAYER.ult = "u_bombrain"
PLAYER.maxUltCharge = 100


function PLAYER:Loadout()

	self.Player:Give( "weapon_bm_grenadelauncher" )

end

player_manager.RegisterClass( "bm_grenadier", PLAYER, "bm_base" )
