
local BUFF = {}

BUFF.name 		= "!noclip"
BUFF.canStack 	= false
BUFF.duration 	= 1.5

function BUFF:onApply( ply )
	ply:SetMoveType( MOVETYPE_FLY )
end

function BUFF:onRemove( ply )
	ply:SetMoveType( MOVETYPE_WALK )
end

BM:addBuff( "buff_noclip", BUFF, "buff_base" )

hook.Add( "SetupMove", "buff_noclip", function( ply, mv, cmd )
	if ply:hasBuff( "buff_noclip" ) then

		local speed = 650

		local vel = Vector( 0, 0, 0 )
		if mv:KeyDown( IN_FORWARD ) then
			vel = vel + ply:GetAimVector()*speed
		end

		if mv:KeyDown( IN_BACK ) then
			vel = vel - ply:GetAimVector()*speed
		end

		if mv:KeyDown( IN_JUMP ) then
			if ply:IsOnGround() then
				mv:SetOrigin( ply:GetPos() + Vector( 0, 0, 2 ) )
			end
			vel = vel + ply:GetUp()*speed
		end

		if mv:KeyDown( IN_MOVERIGHT ) then
			vel = vel + ply:GetRight()*speed
		end

		if mv:KeyDown( IN_MOVELEFT ) then
			vel = vel - ply:GetRight()*speed
		end

		if mv:KeyDown( IN_DUCK ) then
			vel = vel - ply:GetUp()*(speed/4)
		end

		mv:SetVelocity( vel )


	end
end)
