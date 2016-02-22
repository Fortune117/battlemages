
local BUFF = {}

BUFF.name 		= "Windwalk"
BUFF.canStack 	= false 
BUFF.duration 	= 5
BUFF.speedBoost = 0.25

function BUFF:onApply( ply )
	ply:giveSpeedMultiplier( self.speedBoost, self.duration )
end 

function BUFF:onRemove( ply )
end 

BM:addBuff( "buff_windwalk", BUFF, "buff_base" )