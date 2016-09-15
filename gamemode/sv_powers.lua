
util.AddNetworkString( "useUlt" )

net.Receive( "useUlt", function( len, ply )
	if ply:canUlt() then
		ply:useUlt()
	end
end)

local PLY = FindMetaTable( "Player" )

function PLY:getUlt()
	return player_manager.RunClass( self, "getUlt" )
end

function PLY:useUlt()
	local pwr = self:getUlt()
	if pwr then
		local p = self:getPassives()
		local b = self:getBuffs()
		if pwr:canCast( self ) then
			pwr:beginCast( self )
			player_manager.RunClass( self, "abilityCallbacks", ply, p, b, pwr )
			self:setUltCharge( 0 )
		end
	end
end

function PLY:addUltCharge( n )
	local n = math.min( self:getUltCharge() + n, self:getMaxUltCharge() )
	self:setUltCharge( n )
end
