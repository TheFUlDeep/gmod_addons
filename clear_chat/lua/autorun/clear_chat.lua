hook.Add( "PlayerInitialSpawn", "Privet", function(ply) 
    timer.Simple(1, function()
    for i = 1, 100 do
        ply:SendLua([[chat.AddText( Color( 100, 100, 255 ), ]]..[[ "")]])
    end
    end)
    timer.Simple(1, function()
        --ply:ChatPrint("Ты на проект WelsorRP. Развлекася")
    end)
 end)