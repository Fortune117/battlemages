
local BUFF = {}

BUFF.name 		= "!god"
BUFF.canStack 	= false
BUFF.duration 	= 6
BUFF.speedBoost = 0.2

function BUFF:onApply( ply )
	ply:GodEnable()
	ply:giveSpeedMultiplier( self.speedBoost, self.duration )
	for k,v in pairs( player.GetAll() ) do
		if v ~= ply then
			v:ChatPrint( "[BM] "..ply:Nick().." has enabled godmode on himself." )
		else
			v:ChatPrint( "[BM] You have enabled godmode on yourself." )
		end
	end
end

function BUFF:onRemove( ply )
	ply:GodDisable()
	for k,v in pairs( player.GetAll() ) do
		if v ~= ply then
			v:ChatPrint( "[BM] "..ply:Nick().." has disabled godmode on himself." )
		else
			v:ChatPrint( "[BM] You have disabled godmode on yourself." )
		end
	end
end

BM:addBuff( "buff_godmode", BUFF, "buff_base" )
