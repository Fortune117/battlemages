
local ACTIVE = {}

ACTIVE.name 						= "FireNova"
ACTIVE.baseCooldown 				= 5

ACTIVE.cooldownType 				= COOLDOWN_ONFINISH
ACTIVE.delay 						= 2
ACTIVE.castType 					= CAST_DELAY

ACTIVE.animation 					= PLAYER_ATTACK1
ACTIVE.shouldPlayAnimation 			= true 

ACTIVE.minDamage 	= 120
ACTIVE.maxDamage 	= 400
ACTIVE.range 		= 500 
ACTIVE.force 		= 1000

function ACTIVE:init()
	self.range = self.range ^ 2 
end 

function ACTIVE:cast( ply )
	
	local dmginfo = DamageInfo()
	dmginfo:SetDamageType( DMG_BLAST )
	dmginfo:SetAttacker( ply )
	dmginfo:SetInflictor( ply )
	local plyPos = ply:GetPos()
	for k,v in pairs( player.GetAll() ) do
		if v ~= ply then 
			local tpos = v:GetPos()
			local dist = tpos:DistToSqr( plyPos )
			local p = dist/self.range 
			if p <= 1 then 
				dmginfo:SetDamage( math.max( self.minDamage, self.maxDamage*p ) )
				dmginfo:SetDamageForce( (tpos - plyPos):GetNormal()*(p*self.force) )
				v:TakeDamageInfo( dmginfo )
			end 
		end 
	end

	ply:setThirdPerson( false, 100, 0.3 )

	ply:Freeze( false )
end 

function ACTIVE:onBeginCasting( ply )
	ply:Freeze( true )
	ply:setThirdPerson( true, 100, 0.5 )
end

BM:addPower( "a_firenova", ACTIVE, "active_base" ) 