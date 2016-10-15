
concommand.Add( "bm_openclassmenu", function( ply )
	if not ply.classMenu then
		ply.classMenu = vgui.Create( "bm_classmenu" )
	elseif IsValid( ply.classMenu ) then
		ply.classMenu:Remove()
	end
end)

surface.CreateFont( "ClassSelectFont", {
	font = "Trebuchet18", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 50,
	weight = 250,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = true,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})

surface.CreateFont( "ClassSelectCloseButton", {
	font = "Trebuchet18", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
	extended = false,
	size = 90,
	weight = 1000,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false,
})


local bAlpha 			= 240
local black 			= Color( 22, 22, 22, bAlpha  )
local darkBlack 		= Color( 11, 11, 11, bAlpha  )
local white 			= Color( 220, 220, 220, 255  )
local darkBlue 			= Color( 0, 102, 200, 255 )

local gap = 2

local rad = 2*math.pi

local PANEL = {}
function PANEL:Init()

	local w, h = ScrW(), ScrH()
	local sw, sh = w*0.7, h*0.7
	self:SetSize( sw, sh )
	self:DoModal( true )
	self:Center()

	self.close = vgui.Create( "DButton", self )
	self.close:SetSize( sh*0.1, sh*0.1 )
	self.close:SetPos( sw - sh*0.1, -gap*2 )
	self.close:SetText( "" )
	self.close.color = white

	function self.close:DoClick()
		self:GetParent():Remove()
	end

	function self.close:Paint( w, h )
		surface.SetFont( "ClassSelectCloseButton" )
		surface.SetTextColor( self.color )
		local tw, th = surface.GetTextSize( "X" )
		surface.SetTextPos( ( w - tw)/2, ( h - th )/2 )
		surface.DrawText( "X" )
	end

	function self.close:Think()
		if self:IsHovered() then
			local a = self.color.a
			self.color = ColorAlpha( self.color, Lerp( FrameTime()*16, a, 255 ) )
		else
			local a = self.color.a
			self.color = ColorAlpha( self.color, Lerp( FrameTime()*16, a, 160 ) )
		end
	end

	local cols = 6
	local bw, bh =  sw, sh*0.9
	self.body = vgui.Create( "DGrid", self )
	self.body:SetSize( bw, bh )
	self.body:SetPos( 0, sh*0.1 )
	self.body:SetCols( cols )

	local colsz = bw/cols
	self.body:SetColWide( colsz )
	self.body:SetRowHeight( colsz )

	function self.body:addClass( class, classData )

		local but = vgui.Create( "DButton" )
		but:SetSize( colsz, colsz )
		but:SetText( "" )

		but.fontName = class.."_font"
		but.className = classData.DisplayName
		but.color = white
		but.pulseRate = 1
		but.pulseDelay = 0.2
		but.pulseColor = ColorAlpha( white, 100 )
		but.pulseSize = 0

		local len = #class
		local s = 36
		surface.CreateFont( but.fontName, {
			font = "Trebuchet18", -- Use the font-name which is shown to you by your operating system Font Viewer, not the file name
			extended = false,
			size = s,
			weight = 500,
			blursize = 0,
			scanlines = 0,
			antialias = true,
			underline = false,
			italic = false,
			strikeout = false,
			symbol = false,
			rotary = false,
			shadow = false,
			additive = false,
			outline = false,
		})

		function but:Paint( w, h )

			surface.SetDrawColor( black )
			surface.DrawRect( gap, 0, w - gap*2, h - gap*2 )

			if self:isSelectedClass() then
				surface.SetDrawColor( self.color )
				draw.outlinedRectBold( gap, 0, w - gap*2, h, 4 )
			elseif self:IsHovered() or self.pulseSize > 0 then
				self.pulseSize = math.min( (CurTime() - self.enterTime)/self.pulseRate, 1.1 )

				local p = self.pulseSize
				surface.SetDrawColor( self.pulseColor )
				draw.Arc( w/2, h/2, w*p, 3, 0, 360, 10, self.pulseColor )

				if p == 1.1 then
					self.enterTime = CurTime()
					self.pulseSize = 0
				end
			end

			surface.SetFont( self.fontName )
			surface.SetTextColor( self.color )
			local tw, th = surface.GetTextSize( self.className )
			surface.SetTextPos( ( w - tw )/2, ( h - th )/2 )
			surface.DrawText( self.className )

		end

		function but:OnCursorEntered()
			if self.pulseSize == 0 then
				self.enterTime = CurTime()
			end
		end

		function but:isSelectedClass()
			return LocalPlayer():getDisplayClass() == class
		end

		function but:Think()
			if self:IsHovered() or self:isSelectedClass() then
				local a = self.color.a
				self.color = ColorAlpha( self.color, Lerp( FrameTime()*16, a, 255 ) )
			else
				local a = self.color.a
				self.color = ColorAlpha( self.color, Lerp( FrameTime()*16, a, 90 ) )
			end
		end

		function but:DoClick()
			BM:requestClassChange( LocalPlayer(), class, false )
		end

		self:AddItem( but )

	end

	self:loadClasses()

	gui.EnableScreenClicker( true )

end

function PANEL:loadClasses()
	local classes = BM:getClasses()
	for k,v in pairs( classes ) do
		if string.sub( k, 1, 3 ) == "bm_" and k ~= "bm_base" then
			self.body:addClass( k, v )
		end
	end
end

function PANEL:OnRemove()
	gui.EnableScreenClicker( false )
	LocalPlayer().classMenu = false
end

local border = 8
local headerHScale = 0.1
local headerWScale = 1

local bodyHScale = 0.9
local bodyWScale = 1

function PANEL:Paint( w, h )

	local headerW, headerH = w*headerWScale, h*headerHScale
	surface.SetDrawColor( black )
	surface.DrawRect( gap, 0, headerW - gap*2, headerH - gap*2 )

	local bodyW, bodyH = w*bodyWScale, h*bodyHScale
	--surface.DrawRect( 0, headerH + gap, bodyW, bodyH )

	surface.SetFont( "ClassSelectFont" )
	surface.SetTextColor( white )
	local tw, th = surface.GetTextSize( "Class Selection" )
	surface.SetTextPos( gap*4, ( h*0.1 - th )/2 )
	surface.DrawText( "Class Selection" )


end

derma.DefineControl( "bm_classmenu", "Class Menu", PANEL, "DPanel" )
