
local BUFF = {}

BUFF.name 			= "Smokebomb"
BUFF.canStack 		= false 
BUFF.duration 		= 5
BUFF.speedBoost 	= 0.3
BUFF.reloadSpeed 	= 0.65
function BUFF:init()
	self.invis 	= false 
	self.invisDelay = 0 
end 

function BUFF:setInvis( b )
	self.invis = b 
end 

function BUFF:isInvis()
	return self.invis 
end 

function BUFF:onApply( ply )
	self:turnInvis( ply )
end 

function BUFF:onRemove( ply )
	self:goVisible( ply )
end 

function BUFF:turnInvis( ply )

	ply:SetRenderMode( RENDERMODE_TRANSALPHA )
	ply:SetColor( Color( 255, 255, 255, 0 ) )

	ply:giveSpeedMultiplier( self.speedBoost, self.duration )

	local wep = ply:GetActiveWeapon()
	wep:SetRenderMode( RENDERMODE_TRANSALPHA )
	wep:SetColor( Color( 255, 255, 255, 0 ) )

	self.invisWep = wep 
	self:setInvis( true )


	local ef = EffectData()
	ef:SetOrigin( ply:GetPos() )
	ef:SetEntity( ply )
	util.Effect( "smokebomb", ef, true, true )

end 

function BUFF:goVisible( ply )
	ply:SetColor( Color( 255, 255, 255, 255 ) )
	if IsValid( self.invisWep ) then 
		self.invisWep:SetColor( Color( 255, 255, 255, 255 ) )
	end 
	self:setInvis( false )
	ply:removeSpeedMultiplier( self )
end 

function BUFF:reloadMod()
	return self.reloadSpeed 
end 

function BUFF:onFireWeapon()
	self:remove()
end 

BM:addBuff( "buff_invis", BUFF, "buff_base" )