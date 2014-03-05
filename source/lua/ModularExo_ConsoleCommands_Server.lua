

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


local function HandleReturns(...)
    local n = select('#', ...)
    local t = { n = n }
    for i = 1, n do t[i] = select(i, ...) end
    return t, n
end
do
    VVV = (VVV or 0)+1
    local ver = VVV
    Event.Hook("Console_ls",function(client, ...)
        if ver ~= VVV then return end
        local code = table.concat({...},' ')
        local func, err = loadstring(code)
        local res
        if func then
            res = HandleReturns(xpcall(
                function() return func() end,
                function(err)
                    return tostring(err).."\n"..tostring(debug.traceback())
                end
            ))
            if res[1] then
                Print("%s", table.concat(res, " ", 2, res.n))
            else
                Print("%s", tostring(res[2]))
            end
        else
            Print("%s", tostring(err))
        end
    end)
     
    Event.Hook("Console_lsl",function(client, ...)
        if ver ~= VVV then return end
        local s = ...
        local f = assert(io.open("lua/"..s..".lua"))
        local res, err = loadstring(f:read("*a"))
        f:close()
        assert(res, err)()
    end)
end
