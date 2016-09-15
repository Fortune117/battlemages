

local PLAYER = {}

PLAYER.DisplayName				= "Necromancer"

PLAYER.MaxHealth				= 200		-- Max health we can have
PLAYER.StartHealth				= 200		-- How much health we start with
PLAYER.StartArmor				= 0			-- How much armour we start with
PLAYER.WalkSpeed				= 400		-- How fast to move when not running
PLAYER.RunSpeed					= 400		-- How fast to move when running
PLAYER.JumpPower				= 400		-- How powerful our jump should be
PLAYER.CrouchedWalkSpeed		= 0.5		-- Multiply move speed by this when crouching
PLAYER.DuckSpeed				= 0.25		-- How fast to go from not ducking, to ducking
PLAYER.UnDuckSpeed				= 0.3		-- How fast to go from ducking, to not ducking
PLAYER.baseHealthRegen 			= 0  		-- The base rate the player will regenerate health.

PLAYER.playerModel 				= Model( "models/player/kleiner.mdl" )

PLAYER.CanUseFlashlight			= false		-- Can we use the flashlight
PLAYER.UseVMHands				= true		-- Uses viewmodel hands

PLAYER.passives =
{
	"p_a_necro"
}

PLAYER.powers 	=
{
	[ IN_USE ] = "a_deathblock"
}

function PLAYER:Loadout()

	self.Player:Give( "weapon_bm_sniper" )

end

player_manager.RegisterClass( "bm_necro", PLAYER, "bm_base" )
