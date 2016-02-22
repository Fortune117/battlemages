
local PASSIVE = {}

PASSIVE.name 	= "Double Jump"
PASSIVE.type 	= ABILITY_PASSIVE

PASSIVE.maxJumps = 1
PASSIVE.jumpPower = 300 
PASSIVE.addPower = PASSIVE.jumpPower/2

function PASSIVE:playerSpawn( ply )
	ply.curJumps = 0 
end 

function PASSIVE:think( ply )
end 

function PASSIVE:getMaxJumps()
	return self.maxJumps 
end 

function PASSIVE:keyPress( ply, key )
	if key == IN_JUMP and not ply:IsOnGround() then
		if ply.curJumps < self:getMaxJumps() then 

			local power = ply:GetJumpPower()
			local addPower = ply:GetWalkSpeed()

			local vec = Vector( 0, 0, power )

			if ply:KeyDown( IN_FORWARD ) then 
				vec = vec + ply:GetForward()*addPower
			end 

			if ply:KeyDown( IN_BACK ) then 
				vec = vec - ply:GetForward()*addPower 
			end 

			if ply:KeyDown( IN_MOVERIGHT ) then 
				vec = vec + ply:GetRight()*addPower 
			end 

			if ply:KeyDown( IN_MOVELEFT ) then 
				vec = vec - ply:GetRight()*addPower 
			end 

			ply:SetVelocity( ply:GetVelocity()*-1 + vec )
			ply.curJumps = ply.curJumps + 1 
		end 
	end
end

function PASSIVE:onHitGround( ply, inWater, isFloater, speed )
	ply.curJumps = 0
end  

BM:addPassive( "p_doublejump", PASSIVE, "passive_base" )