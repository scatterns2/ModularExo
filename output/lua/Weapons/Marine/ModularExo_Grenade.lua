
Script.Load("lua/Weapons/Marine/Grenade.lua")

local orig_Grenade_OnCreate = Grenade.OnCreate
function Grenade:OnCreate()
    orig_Grenade_OnCreate(self)
    self:SetControllerPhysicsMask(PhysicsMask.MarinePredictedProjectileGroup)
end
