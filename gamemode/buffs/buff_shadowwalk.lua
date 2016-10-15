
local BUFF = {}

BUFF.name 		= "Shadow Walk"
BUFF.canStack 	= false
BUFF.duration 	= 6

BUFF.soundLoop = "ambient/atmosphere/ambience5.wav"
BUFF.speedBoost = 0.3
function BUFF:onApply( ply )

	self.wep = ply:GetActiveWeapon():GetClass()
	ply:StripWeapons()
	ply:Give( "weapon_bm_rangerknife" )
	ply:SetMaterial( "sprites/heatwave" )
	ply:GetActiveWeapon():SetMaterial( "sprites/heatwave" )
	ply:GetViewModel():SetMaterial( "sprites/heatwave" )
	ply:DrawShadow( false )
	ply:RemoveAllDecals()

	local filter = RecipientFilter()
	filter:AddPlayer( ply )
	self.shadowSound = CreateSound( ply, self.soundLoop, filter )
	self.shadowSound:Play()

	ply:giveSpeedMultiplier( self.speedBoost, self.duration )

end

function BUFF:onAbilityUsed( ply, ability )	-- Called when the player uses an ability.
	ply:setUltCharge( ply:getMaxUltCharge()*0.5 )
	self:remove()
end

function BUFF:onRemove( ply )

	if ply:Alive() then
		ply:StripWeapons()
		ply:Give( self.wep )
	end
	ply:SetMaterial( "" )
	ply:DrawShadow( true )

	self.shadowSound:FadeOut( 1 )

end

BM:addBuff( "buff_shadowwalk", BUFF, "buff_base" )

if CLIENT then
	local fadeTime = 0.5
	local tab =
	{
		["$pp_colour_addr"] = 0,
		["$pp_colour_addg"] = 0,
		["$pp_colour_addb"] = 0,
		["$pp_colour_brightness"] = 0,
		["$pp_colour_contrast"] = 1,
		["$pp_colour_colour"] = 0,
		["$pp_colour_mulr"] = 0,
		["$pp_colour_mulg"] = 0,
		["$pp_colour_mulb"] = 0
	}
	shadowWalkColor = 1
	hook.Add( "RenderScreenspaceEffects", "shadowwalkOverlay", function()
		local ply = LocalPlayer()
		if ply:hasBuff( "buff_shadowwalk" ) then
			shadowWalkColor = Lerp( FrameTime()*5, shadowWalkColor, 0 )
		else
			shadowWalkColor = Lerp( FrameTime()*5, shadowWalkColor, 1 )
		end
		tab[ "$pp_colour_colour" ] = shadowWalkColor
		if shadowWalkColor < 0.99 then
			DrawColorModify( tab )
		end
	end)
end
