-- Custom weapon base, used to derive from CS one, still very similar

AddCSLuaFile()

if CLIENT then
   SWEP.crossGapMax     = 60
   SWEP.DrawCrosshair   = true
   SWEP.ViewModelFOV    = 55
   SWEP.ViewModelFlip   = true
   SWEP.CSMuzzleFlashes = true
   SWEP.PrintName = "RNGun"
end


SWEP.HoldType = "ar2"
SWEP.ViewModelFlip = false
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/cstrike/c_rif_ak47.mdl"
SWEP.WorldModel = "models/weapons/w_rif_ak47.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = true

SWEP.Base = "weapon_bm_base"

SWEP.Category           = "Battle Mages"
SWEP.Spawnable          = false

SWEP.Weight             = 5
SWEP.AutoSwitchTo       = false
SWEP.AutoSwitchFrom     = false

SWEP.Primary.Sound              = Sound( "weapons/usp/usp1.wav" )
SWEP.Primary.DryFireSound       = "Weapon_Pistol.Empty" --Empty Clip Sound
SWEP.Primary.Recoil             = 0.25
SWEP.Primary.Damage             = 14
SWEP.Primary.NumShots           = 2
SWEP.Primary.NumShotsMax        = 9
SWEP.Primary.Cone               = 0.002
SWEP.Primary.ConeMax            = 0.2
SWEP.Primary.ConeScaleTime      = 0.5
SWEP.Primary.ConeScaleDownTime  = 0.3
SWEP.Primary.ConeDelay          = 0.1
SWEP.Primary.Delay              = 0.45

SWEP.Primary.ClipSize       = 12
SWEP.Primary.DefaultClip    = 64
SWEP.Primary.Automatic      = true
SWEP.Primary.Ammo           = "357"
SWEP.Primary.ClipMax        = 12

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


function SWEP:SetupDataTables()
   self.BaseClass.SetupDataTables( self )
end

function SWEP:Initialize()
   self.firstDeploy = true
   self.BaseClass.Initialize( self )
   self.scopeT = 0
   self.delayT = 0
end

function SWEP:Reload()
   if self:canReload() then
      local t = self:getReloadTime()*math.Rand( 0.3, 2 )
      local seq = self:SelectWeightedSequence( self.reloadAnim )
      local len = self:SequenceDuration( seq )

      local n = len/t

      self:SendWeaponAnim( self.reloadAnim )
      self.Owner:GetViewModel():SetPlaybackRate( n )

      self:setReloading( true, t )
   end
end

function SWEP:ShootBullet( dmg, recoil, numbul, cone )

   self:SendWeaponAnim( self.primaryAnim )

   self.Owner:MuzzleFlash()
   self.Owner:SetAnimation( PLAYER_ATTACK1 )

   if not IsFirstTimePredicted() then return end

   numbul = math.random( self.Primary.NumShots, self.Primary.NumShotsMax )
   cone   = math.Rand( self.Primary.Cone, self.Primary.ConeMax )

   local bullet = {}
   bullet.Num    = numbul
   bullet.Src    = self.Owner:GetShootPos()
   bullet.Dir    = self.Owner:GetAimVector()
   bullet.Spread = Vector( cone, cone, 0 )
   bullet.Tracer = self.Tracer or 4
   bullet.TracerName = self.TracerName or "Tracer"
   bullet.Force  = 10
   bullet.Damage = dmg
   if CLIENT then
      bullet.Callback = Sparklies
   end

   self.Owner:FireBullets( bullet )

   -- Owner can die after firebullets
   if (not IsValid(self.Owner)) or (not self.Owner:Alive()) or self.Owner:IsNPC() then return end

   if ((game.SinglePlayer() and SERVER) or
       ((not game.SinglePlayer()) and CLIENT and IsFirstTimePredicted())) then

      local eyeang = self.Owner:EyeAngles()
      eyeang.pitch = eyeang.pitch - recoil
      self.Owner:SetEyeAngles( eyeang )
   end

   local lastShoot = self:GetShootTime()
   local diff = math.min( CurTime() - lastShoot, self.Primary.Delay )
   local a = (diff/self.Primary.ConeScaleTime)*(self.Primary.ConeMax - self.Primary.Cone)
   local c = math.min( self:GetConeScale() + a, self.Primary.ConeMax )
   self:SetConeScale( cone )
   self:SetShootTime( CurTime() )

end

function SWEP:SecondaryAttack()
   return
end
