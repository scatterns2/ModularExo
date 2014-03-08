
Script.Load("lua/LiveMixin.lua")

ShieldedMixin = CreateMixin(ShieldedMixin)
ShieldedMixin.type = "Shielded"

ShieldedMixin.kShieldedSearchDistance = 12

ShieldedMixin.expectedMixins = {
    LiveMixin = "Entity must be able to take damage to be shielded from taking damage.",
}
ShieldedMixin.expectedCallbacks = {
    GetIsShieldActive = "Returns true if entity's shield is currently active.",
    GetShieldProjectorCoordinates = "Returns coordinates representing the position and orientation of the shield PROJECTOR (i.e: the claw).",
    GetShieldDistance = "Returns the distance of the shield from the projector.",
    GetShieldAngleExtents = "Returns four angles representing extents: left, right, up, down.",
}
ShieldedMixin.optionalCallbacks = {
    
}

ShieldedMixin.networkVars = {
    shieldEntityId = "entityid",
}

function ShieldedMixin:__initmixin()
    self.shieldEntityId = Entity.invalidId
end

function ShieldedMixin:SetShieldEntity(ent)
    self.shieldEntityId = ent:GetId()
end
function ShieldedMixin:GetShieldEntity()
    return Shared.GetEntity(self.shieldEntityId)
end

function ShieldedMixin:
    
end
