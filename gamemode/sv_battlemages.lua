
util.AddNetworkString( "bm_requestClassChange" )
util.AddNetworkString( "bm_syncClassChangeQue" )

net.Receive( "bm_requestClassChange", function( len, ply )
	local class = net.ReadString()
	local forced = net.ReadBool()
	local classData =  BM:getClasses()[ class ]
	if classData then
		if forced then
			if ply:Alive() then
				ply:Kill()
				ply:setBMClass( class )
			end
		else
			local que = BM.classChangeQue
			local inQue = false
			for i = 1, #que do
				local data = que[ i ]
				if data.player == ply then
					data.class = class
					inQue = true
					ply:ChatPrint( "[BM] You will respawn as "..classData.DisplayName.."." )
					break
				end
			end
			if not inQue then
				table.insert( que, { player = ply, class = class } )
				ply:ChatPrint( "[BM] You will respawn as "..classData.DisplayName.."." )
			end
			net.Start( "bm_syncClassChangeQue" )
				net.WriteTable( BM.classChangeQue )
			net.Broadcast()
		end
	end
end)
