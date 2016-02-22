
local BUFF = {}

BUFF.name 		= "Explosive Shots"
BUFF.canStack 	= false 
BUFF.duration 	= 12

BUFF.numShots 	= 3
BUFF.dmgInc		= 0.4

function BUFF:init()

	self.curShots = 0

end 

function BUFF:onDealDamage( ply, vic, dmginfo )

	if dmginfo:IsBulletDamage() then 

		local ef = EffectData()
		ef:SetOrigin( dmginfo:GetDamagePosition() ) 
		ef:SetNormal( ply:GetAimVector() )
		util.Effect( "bm_expshot", ef )

		dmginfo:ScaleDamage( 1 + self.dmgInc )

		self.curShots = self.curShots + 1 
		if self.curShots >= self.numShots then 
			self:remove()
		end 

	end 

end 

BM:addBuff( "buff_expbullet", BUFF, "buff_base" )