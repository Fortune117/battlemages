
local BUFF = {}

BUFF.name 		= "Wind Fury"
BUFF.canStack 	= true
BUFF.duration 	= 5

BUFF.speed 		= 0.35
BUFF.attackSpeed = 0.35

function BUFF:onApply( ply )
	ply:giveSpeedMultiplier( self.speed, self.duration )
	self.wep = ply:GetActiveWeapon()
	print( self.wep )
	self.prevFire = self.wep.Primary.Delay or 0
	self.newFire = self.prevFire*( 1 - self.attackSpeed )
	self.wep.Primary.Delay = self.newFire
end

function BUFF:onRefresh()

end

function BUFF:onRemove( ply )
	if IsValid( self.wep ) then
		local fd = self.wep.Primary.Delay
		if fd == self.newFire then
			self.wep.Primary.Delay = self.prevFire
		else
			local p = ( fd - ( self.newFire - self.prevFire ) )
			self.wep.Primary.Delay = p
		end
	end
end

BM:addBuff( "buff_elemwind", BUFF, "buff_base" )
