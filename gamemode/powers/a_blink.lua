
local ACTIVE = {}

ACTIVE.name 						= "Blink" 			-- Name
ACTIVE.baseCooldown 				= 8				-- Base cooldown - note that is the "base" cooldown, because we may want to modify it.

ACTIVE.cooldownType 				= COOLDOWN_INSTANT	-- Determines the cooldown type.
ACTIVE.castType 					= CAST_INSTANT		-- Cast type.

ACTIVE.blinkRange 					= 1200

function ACTIVE:cast( ply ) -- This should be the "meat" of the ability.
	self:blink( ply )
end

function ACTIVE:canCast( ply )

	local bClassCheck = self.baseClass.canCast( self, ply )
	local traceCheck = false
	local td =
	{
		start 	= ply:GetShootPos(),
		endpos 	= ply:GetShootPos() + ply:GetAimVector()*self.blinkRange,
		filter = { ply, unpack( player.GetAll() ) }
	}

	local tr = util.TraceLine( td )
	if tr.HitWorld then
		traceCheck = true
	end

	return bClassCheck and traceCheck

end

function ACTIVE:blink( ply )
	local td =
	{
		start 	= ply:GetShootPos(),
		endpos 	= ply:GetShootPos() + ply:GetAimVector()*self.blinkRange,
		filter = { ply, unpack( player.GetAll() ) }
	}
	local tr = util.TraceLine( td )
	if tr.HitWorld then
		ply:SetPos( tr.HitPos )
	end
end


BM:addPower( "a_blink", ACTIVE, "active_base" )
