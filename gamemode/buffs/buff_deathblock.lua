
local BUFF = {}

BUFF.name 			= "Deathblock"
BUFF.canStack 		= false
BUFF.duration 		= 3

function BUFF:onTakeDamage( ply, atk, dmginfo ) -- Called when the player takes damage.
	if dmginfo:GetDamage() > ply:Health() then
		dmginfo:SetDamage( ply:Health() - 1 )
	end
end

BM:addBuff( "buff_deathblock", BUFF, "buff_base" )
