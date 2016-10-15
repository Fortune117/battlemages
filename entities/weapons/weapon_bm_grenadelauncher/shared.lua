-- Custom weapon base, used to derive from CS one, still very similar

AddCSLuaFile()

if CLIENT then
   SWEP.DrawCrosshair   = true
   SWEP.ViewModelFOV    = 55
   SWEP.ViewModelFlip   = true
   SWEP.CSMuzzleFlashes = true
   SWEP.PrintName = "Grenade Launcher"

   SWEP.crossGapMax    = 2
   SWEP.scopeAnimTime  = 0.2
   function SWEP:DrawHUD()

        local w,h   = ScrW(),ScrH()

        surface.SetDrawColor( Color( 20, 20, 230, 24 ) )

        draw.Arc( w/2, h/2, 9, 3, 0, 360, 10, Color( 0, 0, 0, 255 ) )
        draw.Arc( w/2, h/2, 8, 1, 0, 360, 10, Color( 255, 255, 255, 255 ) )

    end

end


SWEP.HoldType = "ar2"
SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = true
SWEP.UseHands = true
SWEP.ViewModel	= "models/weapons/v_shot_m3super90.mdl"
SWEP.WorldModel	= "models/weapons/w_shot_m3super90.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = true


SWEP.Base = "weapon_base"

SWEP.Category           = "Battle Mages"
SWEP.Spawnable          = false

SWEP.Weight             = 5
SWEP.AutoSwitchTo       = false
SWEP.AutoSwitchFrom     = false

SWEP.Primary.Sound              = Sound( "weapons/grenade_launcher1.wav" )
SWEP.Primary.DryFireSound       = "Weapon_Pistol.Empty" --Empty Clip Sound
SWEP.Primary.Recoil             = -1
SWEP.Primary.Damage             = -1
SWEP.Primary.NumShots           = -1
SWEP.Primary.Cone               = -1
SWEP.Primary.Delay              = 0.75

SWEP.Primary.ClipSize       = 6
SWEP.Primary.DefaultClip    = 6
SWEP.Primary.Automatic      = true
SWEP.Primary.Ammo           = "none"
SWEP.Primary.ClipMax        = 6

SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic    = false
SWEP.Secondary.Ammo         = "none"
SWEP.Secondary.ClipMax      = -1

SWEP.DeploySpeed            = 1

SWEP.primaryAnim            = ACT_VM_PRIMARYATTACK
SWEP.reloadAnim             = ACT_VM_RELOAD
SWEP.deployAnim             = ACT_VM_DRAW

SWEP.reloadTime             = 2

SWEP.Tracer                 = 1
SWEP.TracerName             = "Tracer"

SWEP.projectile = "bm_grenadepill"
SWEP.damage     = 120
SWEP.blastRadius= 150
SWEP.projForce  = 3000
SWEP.sound = Sound( "weapons/grenade_launcher1.wav" )

function SWEP:Initialize()

    if self.SetHoldType then
       self:SetHoldType(self.HoldType or "pistol")
    end

    self.setReloading =
    function( self, b )
        self:SetReloading( b )
        self.firstLoad = b
        if not b then
            self:SetReloadCount( 0 )
        end
    end

    self:setReloading( false )

    self.isReloading = self.GetReloading

    self.pumpDelay = math.huge

    self.firstLoad = false

    self.barrageTime = 0
    self.barrageDelay = 0
    self.isDoingBarrage = false

end

function SWEP:SetupDataTables()
   self:NetworkVar( "Bool", 0, "Reloading" )
   self:NetworkVar( "Bool", 1, "FirstLoad" )
   self:NetworkVar( "Float", 0, "ReloadDelay" )
   self:NetworkVar( "Int", 0, "ReloadCount" )
end

function SWEP:Deploy()
    self:SendWeaponAnim( ACT_VM_DEPLOY )
end

function SWEP:fireProjectile( spread )

    spread = spread or 0
    local ply = self.Owner

    if SERVER then
        local pill = ents.Create( self.projectile )
        pill:SetPos( ply:GetShootPos() )
        pill:SetOwner( ply )
        pill:Spawn()

        local dir = ply:GetAimVector()
        local dirA = dir:Angle()
        local up = dirA:Up()
        local right = dirA:Right()
        local spreadVector = up*math.Rand( -spread, spread ) + right*math.Rand( -spread, spread ) + Vector( 0, 0, 0.03 )
        pill:fling( dir + spreadVector, self.projForce, self.damage, self.blastRadius )
    end

    self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
    self:MuzzleFlash()

    self.pumpDelay = CurTime() + self:SequenceDuration()*0.3

    self:TakePrimaryAmmo( 1 )

    if SERVER then
        self.Owner:EmitSound( self.Primary.Sound, self.Primary.SoundLevel )
        BM:onFireWeapon( self.Owner, self )
    end

end

function SWEP:barrage( delay )
    self.barrageDelay = delay
    self.isDoingBarrage = true
    self.barrageCount = self:Clip1()

    -- local n = self:Clip1()
    -- for i = 1,n do
    --     self:fireProjectile( 0.1 )
    -- end
    -- self:Reload()
end

function SWEP:PrimaryAttack(worldsnd)

   self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
   self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

   if not self:CanPrimaryAttack() then self:DryFire() return end

   if self:isReloading() then self:setReloading( false ) end

   self:fireProjectile()


end

function SWEP:DryFire()
   if CLIENT and LocalPlayer() == self.Owner then
      self:EmitSound( "Weapon_Pistol.Empty" )
   end

   self:Reload()
end

function SWEP:CanPrimaryAttack()
   if not IsValid(self.Owner) then return end
   if self:Clip1() <= 0 or self.isDoingBarrage then
      return false
   end
   return true
end

function SWEP:SecondaryAttack()
    return
end

function SWEP:getReloadTime()
   local mod = BM:getReloadMod( self.Owner )
   return self.reloadTime*mod
end

function SWEP:canReload()
    return (not self:isReloading()) and self:Clip1() < self.Primary.ClipSize and (not self.isDoingBarrage)
end

function SWEP:Reload()
    if self:canReload() then
        local diff = self.Primary.ClipSize - self:Clip1()
        self:SetReloadCount( diff )
        self:setReloading( true )
    end
end

function SWEP:getReloadAnim()
    local clip = self:Clip1()
    if self.firstLoad then
        return ACT_SHOTGUN_RELOAD_START
    elseif clip == (self.Primary.ClipSize) then
     return ACT_SHOTGUN_RELOAD_FINISH
    else
        return ACT_VM_RELOAD
    end
end

function SWEP:finishReload()
    local t = self:getReloadTime()/self.Primary.ClipSize
    self:SetReloadDelay( CurTime() + t )

    local anim = self:getReloadAnim()

    local seq = self:SelectWeightedSequence( anim )
    local len = self:SequenceDuration( seq )

    local n = len/t

    self:SendWeaponAnim( anim )
    self.Owner:GetViewModel():SetPlaybackRate( n )
end

function SWEP:Think()

    if self:isReloading() then

        if CurTime() > self:GetReloadDelay() then

            if self:GetReloadCount() <= 0 then
                self:setReloading( false )
                self:finishReload()
                return
            end

            local t = self:getReloadTime()/self.Primary.ClipSize
            self:SetReloadDelay( CurTime() + t )

            local anim = self:getReloadAnim()

            local seq = self:SelectWeightedSequence( anim )
            local len = self:SequenceDuration( seq )

            local n = len/t

            self:SendWeaponAnim( anim )
            self.Owner:GetViewModel():SetPlaybackRate( n )

            if self.firstLoad then
                self.firstLoad = false
            else
                self:SetClip1( self:Clip1() + 1 )
                self:SetReloadCount( self:GetReloadCount() - 1 )
            end


        end

    end

    if CurTime() > self.pumpDelay then
        self:EmitSound( "weapons/m3/m3_pump.wav" )
        self.pumpDelay = math.huge
    end

    if self.isDoingBarrage then
        if CurTime() > self.barrageTime then
            for i = 1,math.random( 1, 2 ) do
                self:fireProjectile( 0.1 )
            end
            self.barrageCount = self.barrageCount - 1
            if self.barrageCount <= 0 then
                self.isDoingBarrage = false
                self:Reload()
            end
            self.barrageTime = CurTime() + self.barrageDelay
        end
    end

end
