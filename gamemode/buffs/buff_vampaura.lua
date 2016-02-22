
local BUFF = {}

BUFF.name 		= "Vamp"
BUFF.canStack 	= false 
BUFF.duration 	= math.huge
BUFF.steal 		= 0.15

function BUFF:onDealDamage( ply, vic, dmginfo )
	ply:heal( dmginfo:GetDamage()*self.steal )
end 

BM:addBuff( "buff_vampaura", BUFF, "buff_base" )