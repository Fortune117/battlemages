include( 'sh_battlemages.lua' )
include( 'shared.lua' )
include( "cl_battlemages.lua" )
include( 'sh_player.lua' )
include( 'sh_powers.lua' )
include( 'sh_buffs.lua' )
include( 'cl_hud.lua' )
include( 'cl_draw.lua' )
include( 'cl_powers.lua' )
include( "cl_halooverride.lua" )
include( "cl_classmenu.lua" )

surface.CreateFont( "BM_HUDLarge", { font = "Trebuchet18", size = 80, weight = 450, scanlines = true, antialias = true } )
surface.CreateFont( "BM_HUDLarge2", { font = "Trebuchet18", size = 60, weight = 450, scanlines = true, antialias = true } )
surface.CreateFont( "BM_HUDMedium", { font = "Trebuchet18", size = 46, weight = 450, scanlines = true, antialias = true } )
surface.CreateFont( "BM_HUDSmall", { font = "Trebuchet18", size = 36, weight = 450, scanlines = true, antialias = true } )
surface.CreateFont( "BM_HUDSmall2", { font = "Trebuchet18", size = 30, weight = 450, scanlines = true, antialias = true } )
surface.CreateFont( "BM_HUDSmall3", { font = "Trebuchet18", size = 24, weight = 450, scanlines = true, antialias = true } )

function GM:CalcView( ply, pos, ang, fov, nearZ, farZ )

	local view = {}

	view.origin = pos
	view.angles = ang
	view.fov = fov


	local t_Data = ply:getThirdPersonData()

	local b = t_Data.bool
	if b then
		local dist = t_Data.dist
		local start = t_Data.startTime
		local delay = t_Data.delay
		local drawDist = math.min( dist*( (CurTime()-start)/delay ), dist )
		ply.drawDist = drawDist
		view.origin = pos - (ang:Forward()*drawDist)
	elseif not b and (ply.drawDist or 0 ) > 0 then
		local dist = t_Data.dist
		local start = t_Data.startTime
		local delay = t_Data.delay
		local drawDist = math.max( dist*( 1 - (CurTime()-start)/delay ), 0 )
		ply.drawDist = drawDist
		view.origin = pos - (ang:Forward()*drawDist)
	end

	return view
end

function GM:ShouldDrawLocalPlayer()
	local ply = LocalPlayer()
	return ply:isThirdPerson() or (ply.drawDist or 0) > 0
end

local ENT = FindMetaTable( "Entity" )
function ENT:isVisible( ent )
	local pos = self:GetPos()
	if self:IsPlayer() then
		pos = self:GetShootPos()
	end
	local epos = ent:GetPos()
	local tr = util.QuickTrace( pos, (epos - pos):GetNormalized()*64000, { self } )
	if IsValid( tr.Entity ) then
		if tr.Entity == ent then
			return true
		end
	end
	return false
end
