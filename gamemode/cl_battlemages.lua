
function  BM:requestClassChange( ply, class, force )
    net.Start( "bm_requestClassChange" )
        net.WriteString( class )
        net.WriteBool( force )
    net.SendToServer()
end


net.Receive( "bm_syncClassChangeQue", function()
    BM.classChangeQue = net.ReadTable()
end)
