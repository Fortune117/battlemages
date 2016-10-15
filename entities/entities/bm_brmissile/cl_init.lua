
include('shared.lua')

function ENT:Draw()
    self:DrawModel()
end

local pillHaloColorE = Color( 255, 40, 40, 255 )
local pillHaloColorF = Color( 25, 255, 40, 255 )
local dist = 12000^2
hook.Add( "PreDrawHalos", "drawMine", function()

    local ply = LocalPlayer()
    for k,v in pairs( ents.FindByClass( "bm_grenadepill" ) ) do
        if v:isVisible( ply ) then
            local color = pillHaloColorE
            if v:GetOwner() == ply then
                color = pillHaloColorF
            end
            local d = v:GetPos():DistToSqr( ply:GetPos() )
            local blur = 3*(d/dist) + math.Rand( -0.3, 0.3 )
            --halo.Add( {v}, color, blur, blur, 2, true, true, fov )
        end
    end

end )
