local sin = math.sin
local cos = math.cos
local floor = math.floor
local abs = math.abs
local max = math.max
local t_insert = table.insert
function surface.PrecacheArc(cx,cy,radius,thickness,startang,endang,roughness,bClockwise)
	local triarc = {}
	local deg2rad = math.pi / 180

	-- Correct start/end ang
	local startang,endang = startang or 0, endang or 0
	if bClockwise and (startang < endang) then
		local temp = startang
		startang = endang
		endang = temp
		temp = nil
	elseif (startang > endang) then
		local temp = startang
		startang = endang
		endang = temp
		temp = nil
	end


	-- Define step
	local roughness = max(roughness or 1, 1)
	local step = roughness
	if bClockwise then
		step = abs(roughness) * -1
	end


	-- Create the inner circle's points.
	local inner = {}
	local r = radius - thickness
	for deg=startang, endang, step do
		local rad = deg2rad * deg
		t_insert(inner, {
			x=cx+(cos(rad)*r),
			y=cy+(sin(rad)*r)
		})
	end


	-- Create the outer circle's points.
	local outer = {}
	for deg=startang, endang, step do
		local rad = deg2rad * deg
		t_insert(outer, {
			x=cx+(cos(rad)*radius),
			y=cy+(sin(rad)*radius)
		})
	end


	-- Triangulate the points.
	for tri=1,#inner*2 do -- twice as many triangles as there are degrees.
		local p1,p2,p3
		p1 = outer[floor(tri/2)+1]
		p3 = inner[floor((tri+1)/2)+1]
		if tri%2 == 0 then --if the number is even use outer.
			p2 = outer[floor((tri+1)/2)]
		else
			p2 = inner[floor((tri+1)/2)]
		end

		t_insert(triarc, {p1,p2,p3})
	end

	-- Return a table of triangles to draw.
	return triarc

end

local DrawPoly = surface.DrawPoly
function surface.DrawArc(arc)
	for k,v in ipairs(arc) do
		DrawPoly(v)
	end
end

local DrawArc = surface.DrawArc
function draw.Arc(cx,cy,radius,thickness,startang,endang,roughness,color,bClockwise)
	surface.SetDrawColor(color)
	DrawArc(surface.PrecacheArc(cx,cy,radius,thickness,startang,endang,roughness,bClockwise))
end

function draw.outlinedRectBold( x, y, w, h, t )
	t = t or 1
	for i = 1,t do
		surface.DrawOutlinedRect( x + (i-1), y + (i-1), w - 2*(i-1), h - 2*(i-1) )
	end
end

function draw.circleBold( x, y, r, color, t )
	t = t or 1
	for i = 1,t do
		surface.DrawCircle( x, y, r - i + 1, color )
	end
end
