-- Custom weapon base, used to derive from CS one, still very similar

AddCSLuaFile()

if CLIENT then
   SWEP.DrawCrosshair   = false
   SWEP.ViewModelFOV    = 82
   SWEP.ViewModelFlip   = true
   SWEP.CSMuzzleFlashes = true
   SWEP.crossWidth      = 1
   SWEP.crossHeight     = 10
   SWEP.crossGapMax     = 16
   function SWEP:DrawHUD()

      if self.DrawCrosshair then
          local w,h = ScrW(), ScrH()
          local x, y = w/2, h/2

          local c = self:GetConeScale()

          local gap = (c/self.Primary.ConeMax)*self.crossGapMax
          self.crossGap = Lerp( FrameTime()*18, self.crossGap, gap )
          surface.SetDrawColor( Color( 0, 0, 0, 255 ) )

          local x1, y1 = x - self.crossWidth/2, y - self.crossHeight - self.crossGap
          surface.DrawOutlinedRect( x1-1, y1-1, self.crossWidth+2, self.crossHeight+2 )

          local x2, y2 = x - self.crossWidth/2, y +  self.crossGap
          surface.DrawOutlinedRect( x2-1, y2-1, self.crossWidth+2, self.crossHeight+2 )

          local x3, y3 = x - self.crossHeight - self.crossGap, y - self.crossWidth/2
          surface.DrawOutlinedRect( x3-1, y3-1, self.crossHeight+2, self.crossWidth+2 )

          local x4, y4 = x + self.crossGap, y - self.crossWidth/2
          surface.DrawOutlinedRect( x4-1, y4-1, self.crossHeight+2, self.crossWidth+2 )

          surface.SetDrawColor( Color( 255, 255, 255, 255 ) )

          local x1, y1 = x - self.crossWidth/2, y - self.crossHeight - self.crossGap
          surface.DrawOutlinedRect( x1, y1, self.crossWidth, self.crossHeight )

          local x2, y2 = x - self.crossWidth/2, y +  self.crossGap
          surface.DrawOutlinedRect( x2, y2, self.crossWidth, self.crossHeight )

          local x3, y3 = x - self.crossHeight - self.crossGap, y - self.crossWidth/2
          surface.DrawOutlinedRect( x3, y3, self.crossHeight, self.crossWidth )

          local x4, y4 = x + self.crossGap, y - self.crossWidth/2
          surface.DrawOutlinedRect( x4, y4, self.crossHeight, self.crossWidth )
      end

   end

end

SWEP.Base = "weapon_base"

SWEP.Category           = "Battle Mages"
SWEP.Spawnable          = false

SWEP.Weight             = 5
SWEP.AutoSwitchTo       = false
SWEP.AutoSwitchFrom     = false


SWEP.ViewModel       = "models/weapons/cstrike/c_rif_ak47.mdl"
SWEP.WorldModel         = "models/weapons/w_rif_ak47.mdl"

SWEP.Primary.Sound              = Sound( "Weapon_AK47.Single" )
SWEP.Primary.DryFireSound       = "Weapon_Pistol.Empty" --Empty Clip Sound
SWEP.Primary.Recoil             = 0.8
SWEP.Primary.Damage             = 1
SWEP.Primary.NumShots           = 1
SWEP.Primary.Cone               = 0.02
SWEP.Primary.ConeMax            = 0.06
SWEP.Primary.ConeScaleTime      = 3
SWEP.Primary.ConeScaleDownTime  = 1
SWEP.Primary.ConeDelay          = 0.8
SWEP.Primary.Delay              = 0.15

SWEP.Primary.ClipSize       = -1
SWEP.Primary.DefaultClip    = -1
SWEP.Primary.Automatic      = false
SWEP.Primary.Ammo           = "none"
SWEP.Primary.ClipMax        = -1

SWEP.Secondary.ClipSize     = 1
SWEP.Secondary.DefaultClip  = 1
SWEP.Secondary.Automatic    = false
SWEP.Secondary.Ammo         = "none"
SWEP.Secondary.ClipMax      = -1


SWEP.primaryAnim           = ACT_VM_PRIMARYATTACK
SWEP.reloadAnim            = ACT_VM_RELOAD
SWEP.deployAnim            = ACT_VM_DRAW

SWEP.reloadTime            = 2.5


-- Shooting functions largely copied from weapon_cs_base
function SWEP:PrimaryAttack(worldsnd)

   self:SetNextSecondaryFire( CurTime() + self.Primary.Delay )
   self:SetNextPrimaryFire( CurTime() + self.Primary.Delay )

   if not self:CanPrimaryAttack() then return end

   if not worldsnd then
      self:EmitSound( self.Primary.Sound, self.Primary.SoundLevel )
   elseif SERVER then
      sound.Play(self.Primary.Sound, self:GetPos(), self.Primary.SoundLevel)
   end

   self:ShootBullet( self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self:GetConeScale() )

   self:TakePrimaryAmmo( 1 )

   if SERVER then
      BM:onFireWeapon( self.Owner, self )
   end

end

function SWEP:DryFire(setnext)
   if CLIENT and LocalPlayer() == self.Owner then
      self:EmitSound( "Weapon_Pistol.Empty" )
   end

   setnext(self, CurTime() + 0.2)

   self:Reload()
end

function SWEP:CanPrimaryAttack()
   if not IsValid(self.Owner) then return end
   if self:isReloading() then return false end

   if self:Clip1() <= 0 then
      self:DryFire(self.SetNextPrimaryFire)
      return false
   end
   return true
end

function SWEP:CanSecondaryAttack()
   if not IsValid(self.Owner) then return end

   if self:Clip2() <= 0 then
      self:DryFire(self.SetNextSecondaryFire)
      return false
   end
   return true
end

local function Sparklies(attacker, tr, dmginfo)
   if tr.HitWorld and tr.MatType == MAT_METAL then
      local eff = EffectData()
      eff:SetOrigin(tr.HitPos)
      eff:SetNormal(tr.HitNormal)
      util.Effect("cball_bounce", eff)
   end
end

function SWEP:ShootBullet( dmg, recoil, numbul, cone )

   self:SendWeaponAnim( self.primaryAnim )

   self.Owner:MuzzleFlash()
   self.Owner:SetAnimation( PLAYER_ATTACK1 )

   if not IsFirstTimePredicted() then return end

   numbul = numbul or 1
   cone   = cone   or 0.01

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
   self:SetConeScale( c )
   self:SetShootTime( CurTime() )

end

function SWEP:SecondaryAttack()
end

function SWEP:Deploy()
   self:SendWeaponAnim( self.deployAnim )
   self:setReloading( false )
   return true
end

function SWEP:getReloadTime()
   local mod = BM:getReloadMod( self.Owner )
   return self.reloadTime*mod
end

function SWEP:canReload()
   return not self:isReloading() and self:Clip1() < self.Primary.ClipMax
end

function SWEP:Reload()
   if self:canReload() then
      local t = self:getReloadTime()
      local seq = self:SelectWeightedSequence( self.reloadAnim )
      local len = self:SequenceDuration( seq )

      local n = len/t

      self:SendWeaponAnim( self.reloadAnim )
      self.Owner:GetViewModel():SetPlaybackRate( n )

      self:setReloading( true, t )
   end
end

local coneDelay = 0.05
function SWEP:Think()
   if self:isReloading() then
      if CurTime() > self:GetReloadDelay() then
         self:SetClip1( self.Primary.ClipMax )
         self:setReloading( false, 0 )
      end
   end

   if CurTime() > self.coneDelay then
       local c = self:GetConeScale()
       if c > self.Primary.Cone then
           local lastShoot = self:GetShootTime()
           local diff = CurTime() - lastShoot
           if diff > self.Primary.ConeDelay then
               local a = (coneDelay/self.Primary.ConeScaleDownTime)*(self.Primary.ConeMax - self.Primary.Cone)
               local b = math.max( c - a, self.Primary.Cone )
               self:SetConeScale( b )
           end
       end
       self.coneDelay = CurTime() + coneDelay
   end
end


function SWEP:Ammo1()
   return IsValid(self.Owner) and self.Owner:GetAmmoCount(self.Primary.Ammo) or 0
end


function SWEP:SetupDataTables()
   self:NetworkVar( "Bool", 0, "Reloading" )
   self:NetworkVar( "Float", 0, "ReloadDelay" )
   self:NetworkVar( "Float", 1, "ShootTime" )
   self:NetworkVar( "Float", 2, "ConeScale" )
end


/********************************************************
   SWEP Construction Kit base code
      Created by Clavus
   Available for public use, thread at:
      facepunch.com/threads/1032378


   DESCRIPTION:
      This script is meant for experienced scripters
      that KNOW WHAT THEY ARE DOING. Don't come to me
      with basic Lua questions.

      Just copy into your SWEP or SWEP base of choice
      and merge with your own code.

      The SWEP.VElements, SWEP.WElements and
      SWEP.ViewModelBoneMods tables are all optional
      and only have to be visible to the client.
********************************************************/

function SWEP:Initialize()

   self.setReloading =
   function( self, b, t )
      self:SetReloading( b )
      if b then
         self:SetReloadDelay( CurTime() + t )
      end
   end

   self:setReloading( false )

   self.isReloading = self.GetReloading

   self:SetShootTime( 0 )
   
   self:SetConeScale( self.Primary.Cone )

   self.coneDelay = 0

   self.crossGap = 0

   if CLIENT and self:Clip1() == -1 then
      self:SetClip1(self.Primary.DefaultClip)
   end

   self:SetDeploySpeed(self.DeploySpeed)

   -- compat for gmod update
   if self.SetHoldType then
      self:SetHoldType(self.HoldType or "pistol")
   end

   if CLIENT then

      // Create a new table for every weapon instance
      self.VElements = table.FullCopy( self.VElements )
      self.WElements = table.FullCopy( self.WElements )
      self.ViewModelBoneMods = table.FullCopy( self.ViewModelBoneMods )

      self:CreateModels(self.VElements) // create viewmodels
      self:CreateModels(self.WElements) // create worldmodels

      // init view model bone build function
      if IsValid(self.Owner) then
         local vm = self.Owner:GetViewModel()
         if IsValid(vm) then
            self:ResetBonePositions(vm)

            // Init viewmodel visibility
            if (self.ShowViewModel == nil or self.ShowViewModel) then
               vm:SetColor(Color(255,255,255,255))
            else
               // we set the alpha to 1 instead of 0 because else ViewModelDrawn stops being called
               vm:SetColor(Color(255,255,255,1))
               // ^ stopped working in GMod 13 because you have to do Entity:SetRenderMode(1) for translucency to kick in
               // however for some reason the view model resets to render mode 0 every frame so we just apply a debug material to prevent it from drawing
               vm:SetMaterial("Debug/hsv")
            end
         end
      end

   end

end

function SWEP:Holster()

   if CLIENT and IsValid(self.Owner) then
      local vm = self.Owner:GetViewModel()
      if IsValid(vm) then
         self:ResetBonePositions(vm)
      end
   end

   self:setReloading( false )

   return true
end

function SWEP:OnRemove()
   self:Holster()
end

if CLIENT then

   SWEP.vRenderOrder = nil
   function SWEP:ViewModelDrawn()

      local vm = self.Owner:GetViewModel()
      if !IsValid(vm) then return end

      if (!self.VElements) then return end

      self:UpdateBonePositions(vm)

      if (!self.vRenderOrder) then

         // we build a render order because sprites need to be drawn after models
         self.vRenderOrder = {}

         for k, v in pairs( self.VElements ) do
            if (v.type == "Model") then
               table.insert(self.vRenderOrder, 1, k)
            elseif (v.type == "Sprite" or v.type == "Quad") then
               table.insert(self.vRenderOrder, k)
            end
         end

      end

      for k, name in ipairs( self.vRenderOrder ) do

         local v = self.VElements[name]
         if (!v) then self.vRenderOrder = nil break end
         if (v.hide) then continue end

         local model = v.modelEnt
         local sprite = v.spriteMaterial

         if (!v.bone) then continue end

         local pos, ang = self:GetBoneOrientation( self.VElements, v, vm )

         if (!pos) then continue end

         if (v.type == "Model" and IsValid(model)) then

            model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
            ang:RotateAroundAxis(ang:Up(), v.angle.y)
            ang:RotateAroundAxis(ang:Right(), v.angle.p)
            ang:RotateAroundAxis(ang:Forward(), v.angle.r)

            model:SetAngles(ang)
            //model:SetModelScale(v.size)
            local matrix = Matrix()
            matrix:Scale(v.size)
            model:EnableMatrix( "RenderMultiply", matrix )

            if (v.material == "") then
               model:SetMaterial("")
            elseif (model:GetMaterial() != v.material) then
               model:SetMaterial( v.material )
            end

            if (v.skin and v.skin != model:GetSkin()) then
               model:SetSkin(v.skin)
            end

            if (v.bodygroup) then
               for k, v in pairs( v.bodygroup ) do
                  if (model:GetBodygroup(k) != v) then
                     model:SetBodygroup(k, v)
                  end
               end
            end

            if (v.surpresslightning) then
               render.SuppressEngineLighting(true)
            end

            render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
            render.SetBlend(v.color.a/255)
            model:DrawModel()
            render.SetBlend(1)
            render.SetColorModulation(1, 1, 1)

            if (v.surpresslightning) then
               render.SuppressEngineLighting(false)
            end

         elseif (v.type == "Sprite" and sprite) then

            local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
            render.SetMaterial(sprite)
            render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)

         elseif (v.type == "Quad" and v.draw_func) then

            local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
            ang:RotateAroundAxis(ang:Up(), v.angle.y)
            ang:RotateAroundAxis(ang:Right(), v.angle.p)
            ang:RotateAroundAxis(ang:Forward(), v.angle.r)

            cam.Start3D2D(drawpos, ang, v.size)
               v.draw_func( self )
            cam.End3D2D()

         end

      end

   end

   SWEP.wRenderOrder = nil
   function SWEP:DrawWorldModel()

      if (self.ShowWorldModel == nil or self.ShowWorldModel) then
         self:DrawModel()
      end

      if (!self.WElements) then return end

      if (!self.wRenderOrder) then

         self.wRenderOrder = {}

         for k, v in pairs( self.WElements ) do
            if (v.type == "Model") then
               table.insert(self.wRenderOrder, 1, k)
            elseif (v.type == "Sprite" or v.type == "Quad") then
               table.insert(self.wRenderOrder, k)
            end
         end

      end

      if (IsValid(self.Owner)) then
         bone_ent = self.Owner
      else
         // when the weapon is dropped
         bone_ent = self
      end

      for k, name in pairs( self.wRenderOrder ) do

         local v = self.WElements[name]
         if (!v) then self.wRenderOrder = nil break end
         if (v.hide) then continue end

         local pos, ang

         if (v.bone) then
            pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent )
         else
            pos, ang = self:GetBoneOrientation( self.WElements, v, bone_ent, "ValveBiped.Bip01_R_Hand" )
         end

         if (!pos) then continue end

         local model = v.modelEnt
         local sprite = v.spriteMaterial

         if (v.type == "Model" and IsValid(model)) then

            model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
            ang:RotateAroundAxis(ang:Up(), v.angle.y)
            ang:RotateAroundAxis(ang:Right(), v.angle.p)
            ang:RotateAroundAxis(ang:Forward(), v.angle.r)

            model:SetAngles(ang)
            //model:SetModelScale(v.size)
            local matrix = Matrix()
            matrix:Scale(v.size)
            model:EnableMatrix( "RenderMultiply", matrix )

            if (v.material == "") then
               model:SetMaterial("")
            elseif (model:GetMaterial() != v.material) then
               model:SetMaterial( v.material )
            end

            if (v.skin and v.skin != model:GetSkin()) then
               model:SetSkin(v.skin)
            end

            if (v.bodygroup) then
               for k, v in pairs( v.bodygroup ) do
                  if (model:GetBodygroup(k) != v) then
                     model:SetBodygroup(k, v)
                  end
               end
            end

            if (v.surpresslightning) then
               render.SuppressEngineLighting(true)
            end

            render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
            render.SetBlend(v.color.a/255)
            model:DrawModel()
            render.SetBlend(1)
            render.SetColorModulation(1, 1, 1)

            if (v.surpresslightning) then
               render.SuppressEngineLighting(false)
            end

         elseif (v.type == "Sprite" and sprite) then

            local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
            render.SetMaterial(sprite)
            render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)

         elseif (v.type == "Quad" and v.draw_func) then

            local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
            ang:RotateAroundAxis(ang:Up(), v.angle.y)
            ang:RotateAroundAxis(ang:Right(), v.angle.p)
            ang:RotateAroundAxis(ang:Forward(), v.angle.r)

            cam.Start3D2D(drawpos, ang, v.size)
               v.draw_func( self )
            cam.End3D2D()

         end

      end

   end

   function SWEP:GetBoneOrientation( basetab, tab, ent, bone_override )

      local bone, pos, ang
      if (tab.rel and tab.rel != "") then

         local v = basetab[tab.rel]

         if (!v) then return end

         // Technically, if there exists an element with the same name as a bone
         // you can get in an infinite loop. Let's just hope nobody's that stupid.
         pos, ang = self:GetBoneOrientation( basetab, v, ent )

         if (!pos) then return end

         pos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
         ang:RotateAroundAxis(ang:Up(), v.angle.y)
         ang:RotateAroundAxis(ang:Right(), v.angle.p)
         ang:RotateAroundAxis(ang:Forward(), v.angle.r)

      else

         bone = ent:LookupBone(bone_override or tab.bone)

         if (!bone) then return end

         pos, ang = Vector(0,0,0), Angle(0,0,0)
         local m = ent:GetBoneMatrix(bone)
         if (m) then
            pos, ang = m:GetTranslation(), m:GetAngles()
         end

         if (IsValid(self.Owner) and self.Owner:IsPlayer() and
            ent == self.Owner:GetViewModel() and self.ViewModelFlip) then
            ang.r = -ang.r // Fixes mirrored models
         end

      end

      return pos, ang
   end

   function SWEP:CreateModels( tab )

      if (!tab) then return end

      // Create the clientside models here because Garry says we can't do it in the render hook
      for k, v in pairs( tab ) do
         if (v.type == "Model" and v.model and v.model != "" and (!IsValid(v.modelEnt) or v.createdModel != v.model) and
               string.find(v.model, ".mdl") and file.Exists (v.model, "GAME") ) then

            v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
            if (IsValid(v.modelEnt)) then
               v.modelEnt:SetPos(self:GetPos())
               v.modelEnt:SetAngles(self:GetAngles())
               v.modelEnt:SetParent(self)
               v.modelEnt:SetNoDraw(true)
               v.createdModel = v.model
            else
               v.modelEnt = nil
            end

         elseif (v.type == "Sprite" and v.sprite and v.sprite != "" and (!v.spriteMaterial or v.createdSprite != v.sprite)
            and file.Exists ("materials/"..v.sprite..".vmt", "GAME")) then

            local name = v.sprite.."-"
            local params = { ["$basetexture"] = v.sprite }
            // make sure we create a unique name based on the selected options
            local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
            for i, j in pairs( tocheck ) do
               if (v[j]) then
                  params["$"..j] = 1
                  name = name.."1"
               else
                  name = name.."0"
               end
            end

            v.createdSprite = v.sprite
            v.spriteMaterial = CreateMaterial(name,"UnlitGeneric",params)

         end
      end

   end

   local allbones
   local hasGarryFixedBoneScalingYet = false

   function SWEP:UpdateBonePositions(vm)

      if self.ViewModelBoneMods then

         if (!vm:GetBoneCount()) then return end

         // !! WORKAROUND !! //
         // We need to check all model names :/
         local loopthrough = self.ViewModelBoneMods
         if (!hasGarryFixedBoneScalingYet) then
            allbones = {}
            for i=0, vm:GetBoneCount() do
               local bonename = vm:GetBoneName(i)
               if (self.ViewModelBoneMods[bonename]) then
                  allbones[bonename] = self.ViewModelBoneMods[bonename]
               else
                  allbones[bonename] = {
                     scale = Vector(1,1,1),
                     pos = Vector(0,0,0),
                     angle = Angle(0,0,0)
                  }
               end
            end

            loopthrough = allbones
         end
         // !! ----------- !! //

         for k, v in pairs( loopthrough ) do
            local bone = vm:LookupBone(k)
            if (!bone) then continue end

            // !! WORKAROUND !! //
            local s = Vector(v.scale.x,v.scale.y,v.scale.z)
            local p = Vector(v.pos.x,v.pos.y,v.pos.z)
            local ms = Vector(1,1,1)
            if (!hasGarryFixedBoneScalingYet) then
               local cur = vm:GetBoneParent(bone)
               while(cur >= 0) do
                  local pscale = loopthrough[vm:GetBoneName(cur)].scale
                  ms = ms * pscale
                  cur = vm:GetBoneParent(cur)
               end
            end

            s = s * ms
            // !! ----------- !! //

            if vm:GetManipulateBoneScale(bone) != s then
               vm:ManipulateBoneScale( bone, s )
            end
            if vm:GetManipulateBoneAngles(bone) != v.angle then
               vm:ManipulateBoneAngles( bone, v.angle )
            end
            if vm:GetManipulateBonePosition(bone) != p then
               vm:ManipulateBonePosition( bone, p )
            end
         end
      else
         self:ResetBonePositions(vm)
      end

   end

   function SWEP:ResetBonePositions(vm)

      if (!vm:GetBoneCount()) then return end
      for i=0, vm:GetBoneCount() do
         vm:ManipulateBoneScale( i, Vector(1, 1, 1) )
         vm:ManipulateBoneAngles( i, Angle(0, 0, 0) )
         vm:ManipulateBonePosition( i, Vector(0, 0, 0) )
      end

   end

   /**************************
      Global utility code
   **************************/

   // Fully copies the table, meaning all tables inside this table are copied too and so on (normal table.Copy copies only their reference).
   // Does not copy entities of course, only copies their reference.
   // WARNING: do not use on tables that contain themselves somewhere down the line or you'll get an infinite loop
   function table.FullCopy( tab )

      if (!tab) then return nil end

      local res = {}
      for k, v in pairs( tab ) do
         if (type(v) == "table") then
            res[k] = table.FullCopy(v) // recursion ho!
         elseif (type(v) == "Vector") then
            res[k] = Vector(v.x, v.y, v.z)
         elseif (type(v) == "Angle") then
            res[k] = Angle(v.p, v.y, v.r)
         else
            res[k] = v
         end
      end

      return res

   end

end
