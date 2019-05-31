local function AntiBidla(ply)
    if ply.SpawnCooldown then return false end

    ply.SpawnCooldown = true

    timer.Simple(0.001, function()
        ply.SpawnCooldown = nil
    end)
end

hook.Add("PlayerGiveSWEP", "antibidla", AntiBidla)

function net.Incoming( len, client )
    local ply = client
    local count = ply.netvorksvsec or 0

    local i = net.ReadHeader()
    local strName = util.NetworkIDToString( i )

    if ( !strName ) then return end

    local func = net.Receivers[ strName:lower() ]
    if ( !func ) then return end

    ply.netvorksvsec = count + 1

    if count >= 999 then
        ply:Kick("[AntiBidla] Спам нетворками")
    end

    --
    -- len includes the 16 bit int which told us the message name
    --
    len = len - 16

    func( len, client )

end

timer.Create("netvorkvsec_obnul", 1, 0, function()
    for _, v in next, player.GetHumans() do
        v.netvorksvsec = 0
    end
end)