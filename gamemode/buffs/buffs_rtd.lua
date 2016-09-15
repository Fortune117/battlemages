
local BUFF = {}
BUFF.name 		= "RTD Infinite Ammo" 	-- Buff name.
BUFF.canStack 	= false 		-- Can the buff stack?
BUFF.duration 	= 10 			-- The duration of the buff.
function BUFF:onApply( ply ) -- Called when the buff is applied.
	local wep = ply:GetActiveWeapon()
	wep:SetClip1( 300 )
end
function BUFF:onRemove( ply ) -- Called when the buff is removed.
	local wep = ply:GetActiveWeapon()
	wep:SetClip1( wep.Primary.ClipMax )
	if wep.Base == "weapon_bm_base" then
		wep:SetReloading( false, 0 )
	end
end
BM:addBuff( "buff_rtd_infiniteammo", BUFF, "buff_base" )

local BUFF = {}
BUFF.name 		= "RTD Rapid Fire" 	-- Buff name.
BUFF.canStack 	= false 		-- Can the buff stack?
BUFF.duration 	= 10 			-- The duration of the buff.
function BUFF:onApply( ply ) -- Called when the buff is applied.
	local wep = ply:GetActiveWeapon()
	self.oldDelay = wep.Primary.Delay
	wep.Primary.Delay = 0.2
end
function BUFF:onRemove( ply ) -- Called when the buff is removed.
	local wep = ply:GetActiveWeapon()
	wep.Primary.Delay = self.oldDelay
end
BM:addBuff( "buff_rtd_rapidfire", BUFF, "buff_base" )

local BUFF = {}
BUFF.name 		= "RTD God Mode" 	-- Buff name.
BUFF.canStack 	= false 		-- Can the buff stack?
BUFF.duration 	= 10 			-- The duration of the buff.
function BUFF:onApply( ply ) -- Called when the buff is applied.
	ply:GodEnable()
end
function BUFF:onRemove( ply ) -- Called when the buff is removed.
	ply:GodDisable()
end
BM:addBuff( "buff_rtd_god", BUFF, "buff_base" )

local BUFF = {}
BUFF.name 		= "RTD Super Speed" 	-- Buff name.
BUFF.canStack 	= false 		-- Can the buff stack?
BUFF.duration 	= 10 			-- The duration of the buff.
function BUFF:onApply( ply ) -- Called when the buff is applied.
	ply:GodEnable()
end
function BUFF:onRemove( ply ) -- Called when the buff is removed.
	ply:GodDisable()
end
BM:addBuff( "buff_rtd_god", BUFF, "buff_base" )

local BUFF = {}
BUFF.name 		= "RTD Super Speed" 	-- Buff name.
BUFF.canStack 	= false 		-- Can the buff stack?
BUFF.duration 	= 10 			-- The duration of the buff.
BUFF.speedBoost = 0.6
function BUFF:onApply( ply ) -- Called when the buff is applied.
	ply:giveSpeedMultiplier( self.speedBoost, self.duration )
end
BM:addBuff( "buff_rtd_sspeed", BUFF, "buff_base" )

local BUFF = {}
BUFF.name 		= "RTD Low Gravity" 	-- Buff name.
BUFF.canStack 	= false 		-- Can the buff stack?
BUFF.duration 	= 10 			-- The duration of the buff.
function BUFF:onApply( ply ) -- Called when the buff is applied.
	ply:SetGravity( 0.4 )
end
function BUFF:onRemove( ply ) -- Called when the buff is removed.
	ply:SetGravity( 1 )
end
BM:addBuff( "buff_rtd_lowgrav", BUFF, "buff_base" )

local BUFF = {}
BUFF.name 		= "RTD Super Gun" 	-- Buff name.
BUFF.canStack 	= false 		-- Can the buff stack?
BUFF.duration 	= 10 			-- The duration of the buff.
function BUFF:onApply( ply ) -- Called when the buff is applied.
	self.oldWep = ply:GetActiveWeapon():GetClass()
	ply:StripWeapons()
	ply:Give( "weapon_bm_rtdsupergun" )
end
function BUFF:onRemove( ply ) -- Called when the buff is removed.
	ply:StripWeapons()
	ply:Give( self.oldWep )
end
BM:addBuff( "buff_rtd_supergun", BUFF, "buff_base" )

local BUFF = {}
BUFF.name 		= "RTD Vamparism" 	-- Buff name.
BUFF.canStack 	= false 		-- Can the buff stack?
BUFF.duration 	= 10 			-- The duration of the buff.
BUFF.vampRatio 	= 0.35
function BUFF:onDealDamage( ply, vic, dmginfo ) -- Called when the player deals damage.
	ply:heal( dmginfo:GetDamage()*self.vampRatio )
end
BM:addBuff( "buff_rtd_vamparism", BUFF, "buff_base" )

local BUFF = {}
BUFF.name 		= "RTD Taser Rounds" 	-- Buff name.
BUFF.canStack 	= false 		-- Can the buff stack?
BUFF.duration 	= 10 			-- The duration of the buff.
BUFF.jitter 	= 2
function BUFF:onDealDamage( ply, vic, dmginfo ) -- Called when the player deals damage.
	if vic:IsPlayer() then
		local ang = AngleRand()*self.jitter
		ang.r = 0
		vic:SetEyeAngles( vic:EyeAngles() + ang )
	end 
end
BM:addBuff( "buff_rtd_taser", BUFF, "buff_base" )

local BUFF = {}
BUFF.name 		= "RTD Instant Death" 	-- Buff name.
BUFF.canStack 	= false 		-- Can the buff stack?
BUFF.duration 	= 10 			-- The duration of the buff.
function BUFF:onApply( ply ) -- Called when the buff is applied.
	ply:Kill()
end
BM:addBuff( "buff_rtd_death", BUFF, "buff_base" )

local BUFF = {}
BUFF.name 		= "RTD Super Slow" 	-- Buff name.
BUFF.canStack 	= false 		-- Can the buff stack?
BUFF.duration 	= 10 			-- The duration of the buff.
BUFF.speedBoost = -0.6
function BUFF:onApply( ply ) -- Called when the buff is applied.
	ply:giveSpeedMultiplier( self.speedBoost, self.duration )
end
BM:addBuff( "buff_rtd_sslow", BUFF, "buff_base" )

local BUFF = {}
BUFF.name 		= "RTD Rubber Bullets" 	-- Buff name.
BUFF.canStack 	= false 		-- Can the buff stack?
BUFF.duration 	= 10 			-- The duration of the buff.
BUFF.dmgScale 	= 0.5
function BUFF:onDealDamage( ply, vic, dmginfo ) -- Called when the player deals damage.
	dmginfo:ScaleDamage( self.dmgScale )
end
BM:addBuff( "buff_rtd_rubberbullets", BUFF, "buff_base" )
