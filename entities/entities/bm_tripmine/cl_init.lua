
include('shared.lua')

net.Receive( "mineTriggered", function()
    local pos = net.ReadVector()
    drawMineWarning( 5, pos )
end)

net.Receive( "mineDestroyed", function()
    local pos = net.ReadVector()
    drawMineDestroyed( 5, pos )
end)


surface.CreateFont( "mineSmooth", { font = "Trebuchet18", size = 32, weight = 700, antialias = true } )

local mineHaloColor = Color( 25, 255, 20, 255 )
local dist = 12000^2
hook.Add( "PreDrawHalos", "drawMine", function()

    local ply = LocalPlayer()
    for k,v in pairs( ents.FindByClass( "bm_tripmine" ) ) do
        if v:GetOwner() == ply then
            local d = v:GetPos():DistToSqr( ply:GetPos() )
            local blur = 3*(d/dist) + math.Rand( -0.3, 0.3 )
            halo.Add( {v}, mineHaloColor, blur, blur, 2, true, true, fov )
        end
    end

end )

local up = 50
function drawMineWarning( dur, pos )

    local ply = LocalPlayer()
    local startTime = CurTime()
    local removeTime = CurTime() + dur
    local id = ply:SteamID64()
    hook.Add( "HUDPaint", id.."minewarning", function()

        local spos = ( pos + Vector( 0, 0, 45 ) ):ToScreen()
        local p = ((removeTime - CurTime())/dur)
        spos.y = spos.y + p*up
        surface.SetFont( "mineSmooth" )
        local w,h = surface.GetTextSize( "TRIGGERED" )

        surface.SetTextColor( Color( 180, 25, 25, 255*( p ) ) )
        surface.SetTextPos( spos.x - w/2, spos.y - h/2 )
        surface.DrawText("TRIGGERED")

        if CurTime() > removeTime then
            hook.Remove( "HUDPaint", id.."minewarning" )
        end

    end)

end

local up = 50
function drawMineDestroyed( dur, pos )

    local ply = LocalPlayer()
    local startTime = CurTime()
    local removeTime = CurTime() + dur
    local id = ply:SteamID64()
    hook.Add( "HUDPaint", id.."minedestroyed", function()

        local spos = ( pos + Vector( 0, 0, 45 ) ):ToScreen()
        local p = ((removeTime - CurTime())/dur)
        spos.y = spos.y + p*up
        surface.SetFont( "mineSmooth" )
        local w,h = surface.GetTextSize( "DESTROYED" )

        surface.SetTextColor( Color( 180, 25, 25, 255*( p ) ) )
        surface.SetTextPos( spos.x - w/2, spos.y - h/2 )
        surface.DrawText("DESTROYED")

        if CurTime() > removeTime then
            hook.Remove( "HUDPaint", id.."minedestroyed" )
        end

    end)

end
