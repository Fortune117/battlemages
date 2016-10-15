local PLY = FindMetaTable( "Player" )

function PLY:setClassPlayerModel()
	player_manager.RunClass( self, "setClassPlayerModel" )
end

function PLY:giveSpeedMultiplier( m, dur, id )

	local speed = self:getClassData().WalkSpeed
	local speed2 = self:getClassData().RunSpeed
	self:SetWalkSpeed( self:GetWalkSpeed() + speed*m )
	self:SetRunSpeed( self:GetRunSpeed() + speed2*m )

	if dur == 0 then
		dur = math.huge
	end

	local mults = self:getSpeedMultipliers()

	id = id or #mults + 1
	mults[ id ] = { mul = m, dur = CurTime() + dur }

end

function PLY:removeSpeedMultiplier( id )
	player_manager.RunClass( self, "removeSpeedBoost", id )
end

function PLY:getSpeedMultipliers()
	return self.speedBoosts
end
