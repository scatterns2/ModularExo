

local exoConfigShorthandMap = {
    c = kExoModuleTypes.Claw,
    w = kExoModuleTypes.Welder,
    s = kExoModuleTypes.Shield,
    m = kExoModuleTypes.Minigun,
    r = kExoModuleTypes.Railgun,
    f = kExoModuleTypes.Flamethrower,
}
Event.Hook("Console_xxx", function(client, lm, rm)
    if true or Shared.GetCheatsEnabled() then
        local player = client:GetControllingPlayer()
        local extraValues = {
            leftArmModuleType  = shorthandMap[tostring(lm)] or kExoModuleTypes.Claw,
            rightArmModuleType = shorthandMap[tostring(rm)] or kExoModuleTypes.Minigun,
        }
        player:Replace("exo", player:GetTeamNumber(), false, nil, extraValues)
    end
end)
