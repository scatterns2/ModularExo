
Script.Load("lua/LiveMixin.lua")

ShieldableMixin = CreateMixin(ShieldableMixin)
ShieldableMixin.type = "Shielded"

ShieldableMixin.kShieldedSearchDistance = 12

ShieldableMixin.expectedMixins = {
    LiveMixin = "Entity must be able to take damage to be shielded from taking damage.",
}
ShieldableMixin.expectedCallbacks = {
    GetIsShieldActive = "Returns true if entity's shield is currently active.",
    GetShieldProjectorCoordinates = "Returns coordinates representing the position and orientation of the shield PROJECTOR (i.e: the claw).",
    GetShieldDistance = "Returns the distance of the shield from the projector.",
    GetShieldAngleExtents = "Returns four angles representing extents: left, right, up, down.",
}
ShieldableMixin.optionalCallbacks = {
    
}

ShieldableMixin.networkVars = {
    shieldEntityId = "entityid",
}

function ShieldableMixin:__initmixin()
    self.shieldEntityId = Entity.invalidId
end

function ShieldableMixin:SetShieldEntity(ent)
    self.shieldEntityId = ent:GetId()
end
function ShieldableMixin:GetShieldEntity()
    return Shared.GetEntity(self.shieldEntityId)
end

function ShieldableMixin:
    
end
