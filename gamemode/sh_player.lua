local PLY = FindMetaTable( "Player" )
function PLY:getClassData()
	return player_manager.RunClass( self, "getClassData" )
end

function PLY:getClass()
	return player_manager.GetPlayerClass( self )
end

function PLY:getDisplayClass()
	for i = 1,#BM.classChangeQue do
		local data = BM.classChangeQue[ i ]
		if data.player == self then
			return data.class
		end
	end
	return self:getClass()
end

if SERVER then

	util.AddNetworkString( "bm_setThirdPerson" )
	util.AddNetworkString( "bm_healNotify" )
	util.AddNetworkString( "bm_damageNumbers" )

	function PLY:setThirdPerson( b, dist, ease )
		local data = { bool = b, dist = dist, delay = (ease or 0.01 ), startTime = CurTime() }
		net.Start( "bm_setThirdPerson" )
			net.WriteTable( data )
		net.Send( self )
		self.thirdPersonData = data
	end

	function PLY:setBMClass( class )
		hook.Call( "OnPlayerChangeBMClass", GAMEMODE, self, self:getClass(), class )
		player_manager.SetPlayerClass( self, class )
	end

	function PLY:heal( n )
		self:SetHealth( math.min( self:Health() + n, self:GetMaxHealth() ) )
		net.Start( "bm_healNotify" )
			net.WriteInt( n, 16 )
		net.Send( self )
	end

end

function PLY:isThirdPerson()
	return self:getThirdPersonData().bool or false
end

function PLY:getThirdPersonDist()
	return self:getThirdPersonData().dist
end

function PLY:getThirdPersonDelay()
	return self:getThirdPersonData().delay
end

function PLY:getThirdPersonData()
	return self.thirdPersonData or {}
end

if CLIENT then
	net.Receive( "bm_setThirdPerson", function( len )
		local tbl = net.ReadTable()
		local ply = LocalPlayer()
		ply.thirdPersonData = tbl
	end )
end
