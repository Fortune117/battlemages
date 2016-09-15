
local BUFF = {}

BUFF.name 			= "Blur"
BUFF.canStack 		= false 
BUFF.duration 		= 3
BUFF.dodgeChance 	= 0.6

function BUFF:onTakeDamage( ply, atk, dmginfo ) -- Called when the player takes damage.
	local rng = math.Rand( 0, 1 ) -- praise be
	if rng <= self.dodgeChange then 
		dmginfo:ScaleDamage( 0 )
	end 
end 

BM:addBuff( "buff_invis", BUFF, "buff_base" )