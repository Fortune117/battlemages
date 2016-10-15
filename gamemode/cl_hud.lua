
local scale 		= ScrW()/1920
local border 		= 30
local baseW 		= 140
local baseH 		= 140
local baseX 		= border
local baseY 		= ScrH() - border

local bAlpha 		= 220
local black 		= Color( 22, 22, 22, bAlpha  )

local cooldown1X	= baseX + baseW + 2
local cooldown1Y	= baseY - baseH/2 + 1

local cooldown2X	= baseX + baseW + 2
local cooldown2Y	= baseY - baseH

local cooldownSize	= baseW/2

local healthW 		= 200
local healthH 		= 30
local healthGap		= 2

local ultW = baseW
local ultH = cooldownSize/3
local ultY = baseY - baseH - ultH - 2

local chargeH = ultH*0.25
local gap = (ultH - chargeH)/2
local chargeW = ultW - gap

function drawPlus( x, y, sz, t )
	surface.DrawRect( x - sz/2, y - t/2, sz, t )
	surface.DrawRect( x - t/2, y - sz/2, t, sz )
end

local tFonts =
{
	"BM_HUDMedium",
	"BM_HUDSmall",
	"BM_HUDSmall2"
}

local function getTextFont( text, w, i )
	i = i or 1
	surface.SetFont( tFonts[ i ] )
	local cTextWidth,cTextHeight = surface.GetTextSize( text )
	if cTextWidth > w and i ~= #tFonts then
		return getTextFont( text, w, i + 1 )
	end
	return tFonts[ i ]
end

local lastHealStackWindow = 0.5
local lastHealTime 		= 0
local healNumColor 		= Color( 25, 255, 25, 255 )
local healNumDuration 	= 1.5
local healNumbers = {}
net.Receive( "bm_healNotify", function()
	if (CurTime() - lastHealTime) < lastHealStackWindow and #healNumbers > 0 then
		healNumbers[ #healNumbers ].amount = healNumbers[ #healNumbers ].amount + net.ReadInt( 16 )
	else
		table.insert( healNumbers, { amount = net.ReadInt( 16 ), startTime = CurTime(), color = Color( 25, 255, 25, 255 ) } )
	end
	lastHealTime = CurTime()
end)

function GM:drawHealth( ply )

	surface.SetDrawColor( black )
	surface.DrawRect( baseX, baseY - baseH, baseW, baseH )

	/* ---------------------------------- Cooldown 1 ---------------------------------- */

	surface.DrawRect( cooldown1X, cooldown1Y, cooldownSize, cooldownSize - 1 )
	local text = string.upper( input.LookupBinding( "speed" ) or "unbound" )
	local c1 = ply:GetCooldown1()
	if c1 > CurTime() then
		text = math.ceil( c1 - CurTime() )
	end
	local cooldownFont 	= getTextFont( text, cooldownSize )
	surface.SetFont( cooldownFont )
	local cTextWidth,cTextHeight = surface.GetTextSize( text )

	draw.DrawText( text, cooldownFont, cooldown1X + (cooldownSize - cTextWidth)/2, cooldown1Y + (cooldownSize - cTextHeight)/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT )

	/* ---------------------------------- Cooldown 2 ---------------------------------- */

	surface.DrawRect( cooldown2X, cooldown2Y, cooldownSize, cooldownSize - 1 )

	local text = string.upper( input.LookupBinding( "use" ) or "unbound" )
	local c2 = ply:GetCooldown2()
	if c2 > CurTime() then
		text = math.ceil( c2 - CurTime() )
	end

	local cooldownFont 	= getTextFont( text, cooldownSize )
	surface.SetFont( cooldownFont )
	local cTextWidth,cTextHeight = surface.GetTextSize( text )
	draw.DrawText( text, cooldownFont, cooldown2X + (cooldownSize - cTextWidth)/2, cooldown2Y + (cooldownSize - cTextHeight)/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT )

	/* ---------------------------------- End of Cooldowns ---------------------------------- */


	/*--------------------------------- Ultimate Ability -------------------------------------*/

	surface.DrawRect( baseX, ultY, ultW, ultH )

	local ultReady = ply:canUlt()
	local charge = ply:getUltCharge()
	local maxCharge = ply:getMaxUltCharge()
	local p = charge/maxCharge

	local cw = chargeW*p

	surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
	surface.DrawRect( baseX + ultW/2 - cw/2 + gap/2, ultY + ultH/2 - chargeH/2, cw - gap, chargeH )

	surface.SetDrawColor( Color( 0, 0, 0, 255 ) )
	surface.DrawRect( baseX + ultW/2 - chargeW/2 + gap/4, ultY + ultH/2 - chargeH/2, gap/4, chargeH )
	surface.DrawRect( baseX + ultW - gap - gap/4, ultY + ultH/2 - chargeH/2, gap/4, chargeH )

	/*--------------------------------- End of Ultimate Ability ------------------------------*/

	local health 		= ply:Health()
	local maxHealth 	= ply:GetMaxHealth()
	local healthP 		= health/maxHealth
	local healthFont 	= "BM_HUDLarge"
	local healthColor	= healthP > 0.5 and Color( 255, 255, 255, 255 ) or Color( 255, 50, 50, 255 )

	surface.SetFont( healthFont )
	local hTextWidth,hTextHeight = surface.GetTextSize( health )
	draw.DrawText( health, healthFont, baseX + ( baseW - hTextWidth)/2, baseY - (baseH + hTextHeight*1.25)/2, healthColor, TEXT_ALIGN_LEFT )

	if #healNumbers > 0 then
		for i = 1,#healNumbers do
			local hData = healNumbers[ i ]

			if hData then
				local hTextWidth,hTextHeight = surface.GetTextSize( hData.amount )
				local p = (CurTime() - hData.startTime)/healNumDuration
				draw.DrawText( hData.amount, healthFont, baseX + ( baseW - hTextWidth)/2, baseY - (baseH + hTextHeight)/2 + - 50 - 150*p, hData.color, TEXT_ALIGN_LEFT )

				if p > 1 then
					table.remove( healNumbers, i )
				end
			end

		end
	end

	local class = ply:getClassData().DisplayName
	local classFont = "BM_HUDSmall3"
	surface.SetFont( classFont )
	local cTextWidth,cTextHeight = surface.GetTextSize( class )
	draw.DrawText( class, classFont, baseX + ( baseW - cTextWidth)/2, baseY - cTextHeight*1.5 , Color( 255, 255, 255, 255), TEXT_ALIGN_LEFT )

end

local ammoX = ScrW() - baseX - baseW

function GM:drawAmmo( ply )
	local wep = ply:GetActiveWeapon()
	if IsValid( wep ) and (wep.Primary.ClipMax or 0) > 0 then
		surface.SetDrawColor( black )
		surface.DrawRect( ammoX, baseY - baseH, baseW, baseH )

		local clip = tostring( wep:Clip1() ).."/"..tostring( wep.Primary.ClipMax )
		local ammoFont = "BM_HUDLarge2"
		surface.SetFont( ammoFont )
		local aTextWidth,aTextHeight = surface.GetTextSize( clip )
		draw.DrawText( clip, ammoFont, ammoX + ( baseW - aTextWidth)/2, baseY - ( baseH + aTextHeight )/2, Color( 255, 255, 255, 255), TEXT_ALIGN_LEFT )

		local name = wep.PrintName
		local wepFont = "BM_HUDSmall3"
		surface.SetFont( wepFont )
		local wTextWidth,wTextHeight = surface.GetTextSize( name )
		draw.DrawText( name, wepFont, ammoX + ( baseW - wTextWidth)/2, baseY - wTextHeight*1.5, Color( 255, 255, 255, 255), TEXT_ALIGN_LEFT )
	end
end

function GM:HUDPaint()

	local ply = LocalPlayer()

	local wep = ply:GetActiveWeapon()
	if wep.GetSights and wep:GetSights() then
	else
		self:drawHealth( ply )
		self:drawAmmo( ply )
	end

end

local notDraw = { "CHudHealth", "CHudBattery", "CHudAmmo", "CHudSecondaryAmmo", "CHudVoiceStatus", "CHudCrosshair" }
function GM:HUDShouldDraw( name )

	for k, v in pairs( notDraw ) do

		if name == v then return false end

  	end

	if name == "CHudDamageIndicator" and not LocalPlayer():Alive() then

		return false

	end

	return true

end
