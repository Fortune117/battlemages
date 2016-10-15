
local ACTIVE = {}

ACTIVE.name 						= "Trip Mine" 			-- Name
ACTIVE.baseCooldown 				= 8				-- Base cooldown - note that is the "base" cooldown, because we may want to modify it.

ACTIVE.cooldownType 				= COOLDOWN_INSTANT	-- Determines the cooldown type.
ACTIVE.castType 					= CAST_INSTANT		-- Cast type.

ACTIVE.force 		= 12000
ACTIVE.spawnDist	= 30
ACTIVE.damage 		= 120
ACTIVE.mineRange	= 100
ACTIVE.blastRadius	= 200
ACTIVE.armTime 		= 0.7

ACTIVE.viewModelAnimation 			= ACT_VM_DRAW 				-- Specifies a viewmodel animation that should be played.
ACTIVE.shouldPlayViewModelAnimation = true			-- Determines whether or not the viewmodel animation should play.

function ACTIVE:cast( ply ) -- This should be the "meat" of the ability.
	if ply.mine then
		if IsValid( ply.mine ) then
			ply.mine:Remove()
		end
	end
	local mine = ents.Create( "bm_tripmine" )
	mine:SetOwner( ply )
	mine:SetPos( ply:GetShootPos() + ply:GetAimVector()*self.spawnDist )
	mine:Spawn()
	mine:fling( ply:GetAimVector(), self.force, self.damage, self.mineRange, self.armTime, self.blastRadius )
	ply:EmitSound( "npc/fast_zombie/claw_miss1.wav" )
	ply.mine = mine
end

BM:addPower( "a_tripmine", ACTIVE, "active_base" )
