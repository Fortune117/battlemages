-- Custom weapon base, used to derive from CS one, still very similar

AddCSLuaFile()

if CLIENT then
   SWEP.DrawCrosshair   = false
   SWEP.ViewModelFOV    = 55
   SWEP.ViewModelFlip   = true
   SWEP.CSMuzzleFlashes = true

   SWEP.VElements =
   {
      ["body2"] = { type = "Model", model = "models/props_combine/combine_booth_short01a.mdl", bone = "v_weapon.m4_Parent", rel = "", pos = Vector(0.2, -4.676, -0.311), angle = Angle(162.468, -4, 180), size = Vector(0.019, 0.019, 0.019), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
      ["body4"] = { type = "Model", model = "models/props_combine/headcrabcannister01a.mdl", bone = "v_weapon.m4_Parent", rel = "", pos = Vector(0.3, -4.901, -10.91), angle = Angle(-90, -15, 0), size = Vector(0.1, 0.059, 0.046), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
      ["body1"] = { type = "Model", model = "models/props_combine/masterinterface_dyn.mdl", bone = "v_weapon.m4_Parent", rel = "", pos = Vector(0, -3.201, 4.675), angle = Angle(55, 85, 180), size = Vector(0.035, 0.035, 0.035), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
      ["body3"] = { type = "Model", model = "models/props_combine/combine_emitter01.mdl", bone = "v_weapon.m4_Parent", rel = "", pos = Vector(0, -3.3, -5.715), angle = Angle(-90, 90, 5), size = Vector(0.2, 0.2, 0.2), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
   }

    SWEP.PrintName = "Lazarus Rifle"
    function SWEP:drawScopeOverlay( x, y, w, h )

        surface.SetDrawColor( Color( 20, 20, 230, 12 ) )
        surface.DrawRect( 0, 0, w, h )

        local p = self.scopeT
        draw.Arc( w/2, h/2, (w/4), 20, 45 - 90*(1-p), -90 + 90*(1-p), 2, Color( 255, 255, 255, 255 ) )


    end

    SWEP.crossGapMax     = 2
    function SWEP:DrawHUD()

        if self:GetSights() then

             local scrw,scrh   = ScrW(),ScrH()

             self:drawScopeOverlay( 0, 0, scrw, scrh )

        else
            self.BaseClass.DrawHUD( self )
        end

    end

   function SWEP:AdjustMouseSensitivity()
      return self:GetSights() and 0.5 or 1
   end

end


SWEP.HoldType = "ar2"
SWEP.ViewModelFlip = false
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/cstrike/c_rif_m4a1.mdl"
SWEP.WorldModel = "models/weapons/w_rif_m4a1.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = true
SWEP.ViewModelBoneMods = {
   ["v_weapon.m4_Silencer"] = { scale = Vector(1, 1, 1.5), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
}

SWEP.Base = "weapon_bm_base"

SWEP.Category           = "Battle Mages"
SWEP.Spawnable          = false

SWEP.Weight             = 5
SWEP.AutoSwitchTo       = false
SWEP.AutoSwitchFrom     = false

SWEP.WElements = {
   ["body3"] = { type = "Model", model = "models/props_combine/combine_emitter01.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(15, 0.6, -5.1), angle = Angle(-10, 0, 180), size = Vector(0.3, 0.3, 0.3), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
   ["body1"] = { type = "Model", model = "models/props_combine/masterinterface_dyn.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(0.518, 0.6, -3.636), angle = Angle(-24.546, -180, -180), size = Vector(0.035, 0.035, 0.035), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
   ["body4"] = { type = "Model", model = "models/props_combine/headcrabcannister01a.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(10.909, 0, -4.676), angle = Angle(0, 0, 0), size = Vector(0.1, 0.059, 0.046), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

SWEP.Primary.Sound = Sound( "weapons/usp/usp1.wav" )
SWEP.Primary.DryFireSound = "Weapon_Pistol.Empty" --Empty Clip Sound
SWEP.Primary.Recoil         = 1
SWEP.Primary.Damage         = 90
SWEP.Primary.NumShots       = 1
SWEP.Primary.Cone           = 0.002
SWEP.Primary.ConeMax            = 0.002
SWEP.Primary.ConeScaleTime      = 0.5
SWEP.Primary.ConeScaleDownTime  = 1
SWEP.Primary.ConeDelay          = 0.4
SWEP.Primary.Delay          = 0.4

SWEP.Primary.ClipSize       = 15
SWEP.Primary.DefaultClip    = 60
SWEP.Primary.Automatic      = false
SWEP.Primary.Ammo           = "357"
SWEP.Primary.ClipMax        = 15

SWEP.Secondary.ClipSize     = -1
SWEP.Secondary.DefaultClip  = -1
SWEP.Secondary.Automatic    = false
SWEP.Secondary.Ammo         = "none"
SWEP.Secondary.ClipMax      = -1

SWEP.DeploySpeed            = 1

SWEP.primaryAnim            = ACT_VM_PRIMARYATTACK_SILENCED
SWEP.reloadAnim             = ACT_VM_RELOAD_SILENCED
SWEP.deployAnim             = ACT_VM_DRAW_SILENCED

SWEP.reloadTime             = 2

SWEP.Tracer                 = 1
SWEP.TracerName             = "AR2Tracer"


function SWEP:SetupDataTables()
   self:NetworkVar( "Bool", 3, "Sights" )
   self:NetworkVar( "Float", 3, "NextSights" )
   self.BaseClass.SetupDataTables( self )
end

function SWEP:Initialize()
   self.firstDeploy = true
   self.BaseClass.Initialize( self )
   self:SetNextSights( CurTime() )
   self.scopeT = 0
   self.delayT = 0
end

function SWEP:CanSecondaryAttack()
   return (CurTime() > self:GetNextSights()) and not self:GetReloading()
end

function SWEP:scope( b )
   if b then
      self.Owner:SetFOV( 40, 0.1 )
   else
      self.Owner:SetFOV( 0, 0.1 )
   end
   self:SetSights( b )
   self:SetNextSights( CurTime() + 0.15 )
end

function SWEP:SecondaryAttack()
   if SERVER and self:CanSecondaryAttack() then
      self:scope( not self:GetSights() )
   end
end

function SWEP:Reload()
   if self:canReload() then
      self:scope( false )
   end
   self.BaseClass.Reload( self )
end

local d = 0.05
function SWEP:Think()
    if CLIENT then
        if self:GetSights() then
            self.scopeT = Lerp( FrameTime(), self.scopeT, 1 )
        else
            self.scopeT = 0
        end
    end
    self.BaseClass.Think( self )
end
