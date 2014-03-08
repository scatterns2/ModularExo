
Script.Load("lua/PhysicsGroups.lua")


--!!!

AddToEnum(PhysicsGroup, "ShieldGroup")

local masksThatShouldCollide = { Bullets = true, PredictedProjectileGroup = true }
for maskKey, maskValue in pairs(PhysicsMask) do
    if type(maskKey) == "string" and not masksThatShouldCollide[maskKey] then
        PhysicsMask[maskKey] = bit.band(maskValue, bit.bnot(bit.lshift(1, PhysicsGroup.ShieldGroup-1)))
    end
end

AddToEnum(PhysicsMask, "MarineBullets"                 , bit.band(PhysicsMask.Bullets                 , bit.bnot(bit.lshift(1, PhysicsGroup.ShieldGroup-1))))
AddToEnum(PhysicsMask, "MarinePredictedProjectileGroup", bit.band(PhysicsMask.PredictedProjectileGroup, bit.bnot(bit.lshift(1, PhysicsGroup.ShieldGroup-1))))

--!!!

