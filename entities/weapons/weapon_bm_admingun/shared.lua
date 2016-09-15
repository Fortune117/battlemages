-- Custom weapon base, used to derive from CS one, still very similar

AddCSLuaFile()

if CLIENT then
   SWEP.crossGapMax     = 36
   SWEP.DrawCrosshair   = false
   SWEP.ViewModelFOV    = 55
   SWEP.ViewModelFlip   = true
   SWEP.CSMuzzleFlashes = true
   SWEP.PrintName = "Admin Gun"
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
SWEP.Primary.Damage             = 25
SWEP.Primary.NumShots           = 1
SWEP.Primary.Cone               = 0.002
SWEP.Primary.ConeMax            = 0.03
SWEP.Primary.ConeScaleTime      = 0.5
SWEP.Primary.ConeScaleDownTime  = 0.3
SWEP.Primary.ConeDelay          = 0.1
SWEP.Primary.Delay              = 0.07

SWEP.Primary.ClipSize       = 30
SWEP.Primary.DefaultClip    = 60
SWEP.Primary.Automatic      = true
SWEP.Primary.Ammo           = "357"
SWEP.Primary.ClipMax        = 30

SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic    = false
SWEP.Secondary.Ammo         = "none"
SWEP.Secondary.ClipMax      = -1

SWEP.DeploySpeed            = 1

SWEP.primaryAnim            = ACT_VM_PRIMARYATTACK
SWEP.reloadAnim             = ACT_VM_RELOAD
SWEP.deployAnim             = ACT_VM_DRAW

SWEP.reloadTime             = 1.8

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

function SWEP:SecondaryAttack()
   return
end
