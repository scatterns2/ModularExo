
Script.Load("lua/DamageTypes.lua")

--[[
local orig_GetDamageByType = GetDamageByType
function GetDamageByType(target, attacker, doer, damage, damageType, hitPoint, ...)
    
    return orig_GetDamageByType(target, attacker, doer, damage, damageType, hitPoint, ...)
end
]]
