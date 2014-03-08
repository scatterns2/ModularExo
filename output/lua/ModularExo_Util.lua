
function AddToEnum(enum, key, value)
    if not rawget(enum, key) then
        value = value or #enum+1
        rawset(enum, value, key)
        rawset(enum, key, value)
    end
end

function GetLocal(originalFunction, name)
    local index = 1
    local foundIndex, foundValue = nil, nil
    while true do
        local n, v = debug.getupvalue(originalFunction, index)
        if not n then
            break
        end
        if n == name then
            return v
        end
        index = index + 1
    end
end

function intersectCircleAndLineSegment(pointA, pointB, centrePoint, radius)
    local lineDiff = pointB-pointA
    local circleDiff = centrePoint-pointA
    local dot = lineDiff:DotProduct(circleDiff)
    local proj = lineDiff*dot/lineDiff:GetLengthSquared()
    local closestPoint = pointA+proj
    local distToCenterSquared = (closestPoint-centrePoint):GetLengthSquared()
    if distToCenterSquared > radius^2 then
        return false, 0
    end
    if math.abs(distToCenterSquared-radius^2) < kEpsilon then
        return true, 1, closestPoint
    end
    local distToIntersection = (
            distToCenterSquared < kEpsilon and radius
        or  math.sqrt(radius^2-distToCenterSquared)
    )
    local t = 1/lineDiff:GetLength()
    local v = lineDiff*t*distToIntersection
    
    local sol1, sol1IsGood = closestPoint+v, false
    local sol2, sol2IsGood = closestPoint-v, false
    if v:DotProduct(sol1-pointA) > 0 and v:DotProduct(sol1-pointB) < 0 then sol1IsGood = true end
    if v:DotProduct(sol2-pointA) > 0 and v:DotProduct(sol2-pointB) < 0 then sol2IsGood = true end
    if sol1IsGood and sol2IsGood then
        return true, 2, sol1, sol2
    elseif sol1IsGood then
        return true, 1, sol1
    elseif sol2IsGood then
        return true, 1, sol2
    end
    return false, 0
end
