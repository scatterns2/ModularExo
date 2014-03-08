
Script.Load("lua/Weapons/DotMarker.lua")

print("!!!")
local orig_DotMarker_OnUpdate = DotMarker.OnUpdate
function DotMarker:OnUpdate(deltaTime)
    if Server then
        if self.dotMarkerType == DotMarker.kType.Static and not self.isShieldImmuneConditionAdded then
            Print("APPLIED!")
            local currentImmuneCondition = self.immuneCondition
            self.immuneCondition = (
                    currentImmuneCondition and function(doer, entity) return (currentImmuneCondition(doer, entity) or IsEntityShielded(doer, entity)) end
                or  IsEntityShielded
            )
            self.isShieldImmuneConditionAdded = true
        end
    end
    
    return orig_DotMarker_OnUpdate(self, deltaTime)
end
