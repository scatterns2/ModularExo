
Script.Load("lua/LiveMixin.lua")

ShieldProjectorMixin = CreateMixin(ShieldProjectorMixin)
ShieldProjectorMixin.type = "Shielded"

ShieldProjectorMixin.kShieldedSearchDistance = 12

ShieldProjectorMixin.expectedMixins = { }
ShieldProjectorMixin.expectedCallbacks = {
    GetIsShieldActive = "Returns true if entity's shield is currently active.",
    GetShieldProjectorCoordinates = "Returns coordinates representing the position and orientation of the shield PROJECTOR (i.e: the claw).",
    GetShieldDistance = "Returns the distance of the shield from the projector.",
    GetShieldAngleExtents = "Returns four angles representing extents: left, right, up, down. (0 to 180; return 180 for each for full coverage)",
}
ShieldProjectorMixin.optionalCallbacks = {
    
}

ShieldProjectorMixin.networkVars = {
    
}

function ShieldProjectorMixin:__initmixin()
    
end

