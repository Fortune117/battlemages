
local BUFF = {}
BUFF.name 		= "RNG Vamparism" 	-- Buff name.
BUFF.canStack 	= false 		-- Can the buff stack?
BUFF.duration 	= 8 			-- The duration of the buff.
BUFF.stealMin 	= 0.05
BUFF.stealMax 	= 0.25
function BUFF:init()
	self.steal = math.Rand( self.stealMin, self.stealMax )
end
function BUFF:onDealDamage( ply, vic, dmginfo ) -- Called when the player deals damage.
	ply:heal( dmginfo:GetDamage()*self.steal )
end
BM:addBuff( "buff_rng_vamp", BUFF, "buff_base" )

local BUFF = {}
BUFF.name 		= "RNG Damage" 	-- Buff name.
BUFF.canStack 	= false 		-- Can the buff stack?
BUFF.duration 	= 8 			-- The duration of the buff.
BUFF.bonusMin 	= 0.05
BUFF.bonusMax 	= 0.15
function BUFF:init()
	self.bonus = math.Rand( self.bonusMin, self.bonusMax )
end
function BUFF:onDealDamage( ply, vic, dmginfo ) -- Called when the player deals damage.
	dmginfo:ScaleDamage( 1 + self.bonus )
end
BM:addBuff( "buff_rng_dmg", BUFF, "buff_base" )

local BUFF = {}
BUFF.name 		= "RNG Speed" 	-- Buff name.
BUFF.canStack 	= false 		-- Can the buff stack?
BUFF.duration 	= 8 			-- The duration of the buff.
BUFF.boostMin 	= 0.05
BUFF.boostMax 	= 0.35
function BUFF:init()
	self.boost = math.Rand( self.boostMin, self.boostMax )
end
function BUFF:onApply( ply ) -- Called when the buff is applied.
	ply:giveSpeedMultiplier( self.boost, self.duration )
end
BM:addBuff( "buff_rng_speed", BUFF, "buff_base" )
