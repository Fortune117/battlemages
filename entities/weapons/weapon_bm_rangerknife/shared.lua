-- Custom weapon base, used to derive from CS one, still very similar

AddCSLuaFile()

if CLIENT then
   SWEP.DrawCrosshair   = false
   SWEP.CSMuzzleFlashes = false
   SWEP.PrintName       = "Ban Hammer"
end


SWEP.HoldType = "knife"
SWEP.ViewModelFOV = 65
SWEP.ViewModelFlip = false
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/cstrike/c_knife_t.mdl"
SWEP.WorldModel = "models/weapons/w_knife_t.mdl"

SWEP.Base = "weapon_base"

SWEP.Category           = "Battle Mages"
SWEP.Spawnable          = false

SWEP.Weight             = 5
SWEP.AutoSwitchTo       = false
SWEP.AutoSwitchFrom     = false

SWEP.Primary.Sound              = Sound( "weapons/usp/usp1.wav" )
SWEP.Primary.DryFireSound       = "Weapon_Pistol.Empty" --Empty Clip Sound
SWEP.Primary.Recoil             = -1
SWEP.Primary.Damage             = -1
SWEP.Primary.NumShots           = -1
SWEP.Primary.Cone               = 0
SWEP.Primary.Delay              = -1

SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = false
SWEP.Primary.Ammo           = "none"
SWEP.Primary.ClipMax        = -1

SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic    = false
SWEP.Secondary.Ammo         = "none"
SWEP.Secondary.ClipMax      = -1

SWEP.DeploySpeed            = 1

SWEP.swingAnim            = ACT_VM_PRIMARYATTACK
SWEP.drawAnim             = ACT_VM_DRAW

SWEP.damage     = 200
SWEP.swingRate  = 0.4
SWEP.range      = 90
SWEP.swingForce = 25000
SWEP.downForce  = 50000
SWEP.swingSounds = { Sound( "weapons/knife/knife_slash1.wav" ), Sound( "weapons/knife/knife_slash2.wav" ) }
SWEP.hitSounds   =
{
    Sound( "weapons/knife/knife_stab.wav" )
}
function SWEP:canAttack()
    return CurTime() >= self.swingDelay
end

function SWEP:PrimaryAttack()
    if self:canAttack() then
        self:swing()
    end
end

function SWEP:Initialize()
    self.swingDelay = 0

    -- compat for gmod update
    if self.SetHoldType then
       self:SetHoldType(self.HoldType or "pistol")
    end
end

function SWEP:swing()

    self:EmitSound( tostring( table.Random( self.swingSounds ) ) )
    self.Owner:SetAnimation( PLAYER_ATTACK1 )
    self:SendWeaponAnim( self.swingAnim )

    self.Owner:LagCompensation( true )

        local tr = util.TraceLine( {
            start = self.Owner:GetShootPos(),
            endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.range,
            filter = self.Owner,
            mask = MASK_SHOT_HULL
        } )

        if ( !IsValid( tr.Entity ) ) then
            tr = util.TraceHull( {
                start = self.Owner:GetShootPos(),
                endpos = self.Owner:GetShootPos() + self.Owner:GetAimVector() * self.range,
                filter = self.Owner,
                mins = Vector( -8, -8, -7 ),
                maxs = Vector( 8, 8, 7 ),
                mask = MASK_SHOT_HULL
            } )
        end

        if ( tr.Hit && !( game.SinglePlayer() && CLIENT ) and tr.Entity:IsWorld() ) then
            local tr2 = util.QuickTrace( self.Owner:GetShootPos(), self.Owner:GetAimVector()*80, { self, self.Owner} )
            local Pos1 = tr2.HitPos - tr2.HitNormal
            local Pos2 = tr2.HitPos + tr2.HitNormal
            util.Decal( "Dark", Pos1, Pos2, true )
        end


        if SERVER then
            local ent = tr.Entity
            if IsValid( ent ) and not ent:IsWorld() and (ent:IsPlayer() or ent:IsNPC() or ent:Health() > 0) then
                local dmginfo = DamageInfo()
                dmginfo:SetAttacker( self.Owner )
                dmginfo:SetDamage( self.damage )
                dmginfo:SetInflictor( self )
                dmginfo:SetDamageForce( self.Owner:GetAimVector()*self.swingForce )
                ent:TakeDamageInfo( dmginfo )
                self.Owner:EmitSound( tostring( table.Random( self.hitSounds ) ) )
                self.used = true
            end
        end

    self.Owner:LagCompensation( false )

    self.swingDelay = CurTime() + self.swingRate

end

function SWEP:Think()
    if self.used and CurTime() > self.swingDelay then
        self.Owner:removeBuff( "buff_shadowwalk" )
    end
end

function SWEP:SecondaryAttack()
   return
end
