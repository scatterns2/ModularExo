
Script.Load("lua/Weapons/Marine/Grenade.lua")

local orig_Grenade_SetProjectileController = Grenade.SetProjectileController
function Grenade:SetProjectileController(controller, selfUpdate)
    orig_Grenade_SetProjectileController(controller, selfUpdate)
    self:SetControllerPhysicsMask(PhysicsMask.MarinePredictedProjectileGroup)
end
