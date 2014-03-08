
Script.Load("lua/Weapons/Marine/ExoWeaponHolder.lua")

local networkVars = {
    
}

local orig_ExoWeaponHolder_GetViewModelName = ExoWeaponHolder.GetViewModelName
function ExoWeaponHolder:GetViewModelName()
    local player = self:GetParent()
    return player.viewModelName
end

local orig_ExoWeaponHolder_GetAnimationGraphName = ExoWeaponHolder.GetAnimationGraphName
function ExoWeaponHolder:GetAnimationGraphName()
    local player = self:GetParent()
    return player.viewModelGraphName
end

--Class_Reload("ExoWeaponHolder", networkVars)
