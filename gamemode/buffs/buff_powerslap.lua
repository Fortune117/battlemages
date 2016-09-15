
local BUFF = {}

BUFF.name 		= "Power Slap"
BUFF.canStack 	= false
BUFF.duration 	= 6

BUFF.dmgAdd		= 50
BUFF.forceScale = 1000

function BUFF:onDealDamage( ply, vic, dmginfo )

	local inf = dmginfo:GetInflictor()
	if inf:GetClass() == "weapon_bm_banhammer" then
		dmginfo:SetDamage( dmginfo:GetDamage() + self.dmgAdd )
		dmginfo:SetDamageForce( dmginfo:GetDamageForce()*self.forceScale )
		vic:SetPos( vic:GetPos() + Vector( 0, 0, 1 ) )
		vic:SetVelocity( dmginfo:GetDamageForce() + Vector( 0, 0, 15000 ) )
		if vic:IsPlayer() then
			vic:ViewPunch( Angle( math.random( -15, 15 ), math.random( -15, 15 ), 0 ) )
		end
		self:remove()
	end

end

BM:addBuff( "buff_powerslap", BUFF, "buff_base" )
