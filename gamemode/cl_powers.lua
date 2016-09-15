
function GM:PlayerBindPress( ply, bind, active )
	if bind == "+menu" then
		if ply:canUlt() then
			net.Start( "useUlt" )
			net.SendToServer()
		end
	end
end
