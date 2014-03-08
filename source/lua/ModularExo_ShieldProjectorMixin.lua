
Script.Load("lua/LiveMixin.lua")

ShieldProjectorMixin = CreateMixin(ShieldProjectorMixin)
ShieldProjectorMixin.type = "ShieldProjectorMixin"

ShieldProjectorMixin.kShieldedSearchDistance = 12

ShieldProjectorMixin.expectedMixins = {
    --EntityChangeMixin = "For nearby shield entities.",
}
ShieldProjectorMixin.expectedCallbacks = {
    GetIsShieldActive = "Returns true if entity's shield is currently active.",
    GetShieldTeam = "Returns the index of the shielded team.",
    GetShieldProjectorCoordinates = "Returns coordinates representing the position and orientation of the shield PROJECTOR (i.e: the claw).",
    GetShieldDistance = "Returns the distance of the shield from the projector.",
    GetShieldAngleExtents = "Returns two angles representing angular extents left and right (use 180 for both for full circular shield).",
}
ShieldProjectorMixin.optionalCallbacks = {
    GetShieldableEntitySearchDistance = "Returns the distance to search for nearby shieldable entities.",
    GetShieldableEntitySearchInterval = "Returns the interval in which to search for nearby shieldable entities.",
}

ShieldProjectorMixin.networkVars = {
    
}

function IsEntityShielded(doer, entity)
    if entity.nearShieldCount and entity.nearShieldCount > 0 then
        for shieldI, shieldEntity in ipairs(entity.nearShieldList) do
            if shieldEntity:GetIsEntityShieldedFromDoer(entity, doer) then
                return true
            end
        end
    end
    return false
end

function ShieldProjectorMixin:__initmixin()
    if Server then
        self.lastSearchTime = 0
        self.nearbyShieldableEntityIdList = {}
        self.nearbyShieldableEntityIdMap = {}
    end
end
function ShieldProjectorMixin:OnDestroy()
    if Server then
        for nearbyEntityI, nearbyEntityId in ipairs(self.nearbyShieldableEntityIdList) do
            local nearbyEntity = Shared.GetEntity(nearbyEntityId)
            nearbyEntity.nearShieldCount = nearbyEntity.nearShieldCount-1
            local shieldI = nearbyEntity.nearShieldIdMap[self:GetId()]
            table.remove(nearbyEntity.nearShieldList, shieldI)
            nearbyEntity.nearShieldIdMap[self:GetId()] = nil
        end
    end
end

function ShieldProjectorMixin:GetShieldableEntitySearchDistance()
    return self:GetShieldDistance()*2 -- this must be bigger to account for fast moving objects
end
function ShieldProjectorMixin:GetShieldableEntitySearchInterval()
    return 0.2
end

function ShieldProjectorMixin:GetIsEntityShieldedFromDoer(entity, doer)
    if entity == self then return false end
    if self:GetIsShieldActive() then
        local projectorCoords = self:GetShieldProjectorCoordinates()
        Print("blah")
        if (projectorCoords.origin-entity:GetOrigin()):GetLength() < self:GetShieldDistance()*1.2 then
            local projectorDir2d = GetNormalizedVectorXZ(projectorCoords.zAxis)
            local projectorOrigin2d = projectorCoords.origin projectorOrigin2d.y = 0
            local doerOrigin2d = doer:GetOrigin() doerOrigin2d.y = 0
            local entityOrigin2d = entity:GetOrigin() entityOrigin2d.y = 0
            
            local doesIntersect, intersectCount, intersectPointA, intersectPointB = intersectCircleAndLineSegment(doerOrigin2d, entityOrigin2d, projectorOrigin2d, self:GetShieldDistance())
            Print("GetIsEntityShieldedFromDoer(%s, %s) -> %s", entity:GetClassName(), doer:GetClassName(), tostring(doesIntersect))
            if doesIntersect then
                local leftMaxAngle, rightMaxAngle = self:GetShieldAngleExtents()
                for intersectI = 1, intersectCount do
                    local intersectPoint = (intersectCount == 1 and intersectPointA or intersectPointB)
                    local dir = (intersectPoint-projectorOrigin2d):GetNormalized()
                    local isLeft = (projectorDir2d:CrossProduct(dir) > 0)
                    local maxAngle = (isLeft and leftMaxAngle or rightMaxAngle)
                    local isWithinAngle = projectorDir2d:DotProduct(dir) < math.cos(maxAngle)
                    Print("GetIsEntityShieldedFromDoer(%s, %s) -> %s, %s", entity:GetClassName(), doer:GetClassName(), isLeft and "left" or "right", tostring(isWithinAngle))
                    if isWithinAngle then
                        return true
                    end
                end
            end
        end
    end
end

function ShieldProjectorMixin:OnEntityChange(oldId)
    if Server and self.nearbyShieldableEntityIdMap[oldId] then
        Print("Entity %s out of range (deleted)", oldId)
        local entityI = self.nearbyShieldableEntityIdMap[oldId]
        table.remove(self.nearbyShieldableEntityIdList, entityI)
        self.nearbyShieldableEntityIdMap[oldId] = nil
    end
end

function ShieldProjectorMixin:UpdateShieldProjectorMixin(deltaTime)
    if Server then
        if Shared.GetTime() > self.lastSearchTime+self:GetShieldableEntitySearchInterval() then
            self.lastSearchTime = Shared.GetTime()
            local projectorCoords = self:GetShieldProjectorCoordinates()
            local nearbyEntityIdMap = {}
            local nearbyEntityList = GetEntitiesWithMixinForTeamWithinRange("Live", self:GetShieldTeam(), projectorCoords.origin, self:GetShieldableEntitySearchDistance())
            for nearbyEntityI, nearbyEntity in ipairs(nearbyEntityList) do
                if nearbyEntity:GetIsAlive() then
                    nearbyEntityIdMap[nearbyEntity:GetId()] = true
                    if not self.nearbyShieldableEntityIdMap[nearbyEntity:GetId()] then
                        Print("New entity %s (%s) in range", nearbyEntity:GetId(), nearbyEntity:GetClassName())
                        
                        local entityI = #self.nearbyShieldableEntityIdList+1
                        self.nearbyShieldableEntityIdList[entityI] = nearbyEntity:GetId()
                        self.nearbyShieldableEntityIdMap[nearbyEntity:GetId()] = entityI
                            
                        if not nearbyEntity.nearShieldCount then
                            nearbyEntity.nearShieldCount = 0
                            nearbyEntity.nearShieldList = {}
                            nearbyEntity.nearShieldIdMap = {}
                        end
                        nearbyEntity.nearShieldCount = nearbyEntity.nearShieldCount+1
                        local shieldI = #nearbyEntity.nearShieldList+1
                        nearbyEntity.nearShieldList[shieldI] = self
                        nearbyEntity.nearShieldIdMap[self:GetId()] = shieldI
                    end
                end
            end
            local nearbyEntityI = 1
            while nearbyEntityI <= #self.nearbyShieldableEntityIdList do
                local nearbyEntityId = self.nearbyShieldableEntityIdList[nearbyEntityI]
                local shouldRemove = false
                if not nearbyEntityIdMap[nearbyEntityId] then
                    local nearbyEntity = Shared.GetEntity(nearbyEntityId)
                    Print("Entity %s (%s) out of range", nearbyEntityId, nearbyEntity:GetClassName())
                    shouldRemove = true
                    
                    self.nearbyShieldableEntityIdMap[nearbyEntity:GetId()] = nil
                        
                    nearbyEntity.nearShieldCount = nearbyEntity.nearShieldCount-1
                    local shieldI = nearbyEntity.nearShieldIdMap[self:GetId()]
                    table.remove(nearbyEntity.nearShieldList, shieldI)
                    nearbyEntity.nearShieldIdMap[self:GetId()] = nil
                end
                if shouldRemove then
                    table.remove(self.nearbyShieldableEntityIdList, nearbyEntityI)
                else
                    nearbyEntityI = nearbyEntityI+1
                end
            end
        end
    end
end



