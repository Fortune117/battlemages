
local ACTIVE = {}

ACTIVE.name 						= "Bomb Dash"
ACTIVE.baseCooldown 				= 8

ACTIVE.cooldownType 				= COOLDOWN_INSTANT
ACTIVE.castType 					= CAST_INSTANT

ACTIVE.animation 					= PLAYER_ATTACK1
ACTIVE.shouldPlayAnimation 			= false

ACTIVE.damage = 120
ACTIVE.radius = 150

ACTIVE.dashForce 					= 300
ACTIVE.upForce 						= 700

function ACTIVE:init()
	self.radius = self.radius^2
end

function ACTIVE:cast( ply )

	local effect = EffectData()
	effect:SetStart(ply:GetPos())
	effect:SetOrigin(ply:GetPos())
	effect:SetScale(1)
	effect:SetRadius(1)
	effect:SetMagnitude(1)
	util.Effect("Explosion", effect, true, true)

	local pos = ply:GetPos()
	for k,v in pairs( player.GetAll() ) do
		if not v:Alive() then continue end
		if v == ply then continue end
		local vpos = v:GetPos()
		local dist = vpos:DistToSqr( pos )
		if dist <= self.radius and v:Visible( ply ) then
			local dmginfo = DamageInfo()
			dmginfo:SetDamageType( DMG_BLAST )
			dmginfo:SetDamage( self.damage )
			dmginfo:SetDamageForce( ( vpos - pos ):GetNormalized()*300 )
			dmginfo:SetInflictor( ply )
			dmginfo:SetAttacker( ply )
			v:TakeDamageInfo( dmginfo )
		end
	end

	ply:SetVelocity( ply:GetAimVector()*self.dashForce + Vector( 0, 0, self.upForce ) )

end

BM:addPower( "a_bombdash", ACTIVE, "active_base" )
