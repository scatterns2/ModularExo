

local function HandleReturns(...)
    local n = select('#', ...)
    local t = { n = n }
    for i = 1, n do t[i] = select(i, ...) end
    return t, n
end
do
    VVV = (VVV or 0)+1
    local ver = VVV
    Event.Hook("Console_lp",function(...)
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
     
    Event.Hook("Console_lpl",function(...)
        if ver ~= VVV then return end
        local s = ...
        local f = assert(io.open("lua/"..s..".lua"))
        local res, err = loadstring(f:read("*a"))
        f:close()
        assert(res, err)()
    end)
end
