
local ACTIVE = {}

ACTIVE.name 						= "Shuriken" 			-- Name
ACTIVE.baseCooldown 				= 10				-- Base cooldown - note that is the "base" cooldown, because we may want to modify it.

ACTIVE.cooldownType 				= COOLDOWN_INSTANT	-- Determines the cooldown type.
ACTIVE.castType 					= CAST_INSTANT		-- Cast type.

ACTIVE.force 		= 9000
ACTIVE.spawnDist	= 30
ACTIVE.damage 		= 120

ACTIVE.viewModelAnimation 			= ACT_VM_DRAW 				-- Specifies a viewmodel animation that should be played.
ACTIVE.shouldPlayViewModelAnimation = true			-- Determines whether or not the viewmodel animation should play.

function ACTIVE:cast( ply ) -- This should be the "meat" of the ability.
	local s = ents.Create( "bm_shuriken" )
	s:SetOwner( ply )
	s:SetPos( ply:GetShootPos() + ply:GetAimVector()*self.spawnDist )
	s:Spawn()
	s:fling( ply:GetAimVector(), self.force, self.damage, self.mineRange, self.armTime, self.blastRadius )
	ply:EmitSound( "npc/fast_zombie/claw_miss1.wav" )
end

BM:addPower( "a_shuriken", ACTIVE, "active_base" )
